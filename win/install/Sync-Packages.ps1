<#
.SYNOPSIS
  Export/import Winget apps, plus list non-winget, non-system programs for manual install.

.DESCRIPTION
  - Without parameters, shows usage.
  - -Dump     exports Winget apps to JSON, then writes a TXT of everything not in Winget, excluding Windows system and Microsoft-published apps.
  - -Install  installs apps from that JSON manifest, silently.
  - You can override paths with -File or -ManualFile.

.PARAMETER Dump
  Export Winget apps + list non-winget programs.

.PARAMETER Install
  Install Winget apps from the JSON manifest (unattended).

.PARAMETER File
  (Optional) Path to the Winget-export JSON. Defaults to `<script-folder>\installed-packages.json`.

.PARAMETER ManualFile
  (Optional) Path to the manual list TXT. Defaults to `<script-folder>\manual-installed-programs.txt`.

.EXAMPLE
  # Dump everything
  .\Sync-Packages.ps1 -Dump

  # Install Winget apps only
  .\Sync-Packages.ps1 -Install
#>

[CmdletBinding()]
param(
    [switch]$Dump,
    [switch]$Install,
    [string]$File,
    [string]$ManualFile
)

function Show-Usage {
    @"
Usage:
  Sync-Packages.ps1 -Dump     # Export Winget apps + generate manual list
  Sync-Packages.ps1 -Install  # Install Winget apps from the manifest

Options:
  -File <path>        Override default Winget-export JSON.
  -ManualFile <path>  Override default manual list TXT.
"@ | Write-Host
    exit 1
}

# 1) Determine script directory
$ScriptPath = $MyInvocation.MyCommand.Definition
if ($ScriptPath) {
    $ScriptDir = Split-Path -Path $ScriptPath -Parent
}
elseif ($PSScriptRoot) {
    $ScriptDir = $PSScriptRoot
}
else {
    $ScriptDir = (Get-Location).ProviderPath
}

# 2) Set defaults if none provided
if (-not $File)       { $File = Join-Path $ScriptDir 'installed-packages.json' }
if (-not $ManualFile) { $ManualFile = Join-Path $ScriptDir 'manual-installed-programs.txt' }

# 3) Must pick an action
if (-not ($Dump -or $Install)) {
    Show-Usage
}

# 4) Ensure winget is available
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget not found. Please install App Installer from the Microsoft Store."
    exit 1
}

if ($Dump) {
    Write-Host "→ Exporting Winget apps to:`n    $File`n"
    try {
        winget export --output $File --accept-source-agreements --disable-interactivity
        Write-Host "✅ Winget export complete."
    }
    catch {
        Write-Error "Failed to export Winget apps: $_"
        exit 1
    }

    Write-Host "`n→ Scanning registry for installed programs (excluding system/Microsoft)…"
    $uninstallPaths = @(
      'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
      'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
      'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )

    $allPrograms = foreach ($path in $uninstallPaths) {
        Get-ItemProperty $path -ErrorAction SilentlyContinue |
          Where-Object {
            # must have a display name,
            # and either no SystemComponent flag or SystemComponent != 1,
            # and not published by Microsoft
            $_.DisplayName -and
            (
              ($_.PSObject.Properties['SystemComponent'] -eq $null) -or
              ($_.PSObject.Properties['SystemComponent'].Value -ne 1)
            ) -and
            ($_.Publisher -notmatch 'Microsoft')
          } |
          Select-Object @{n='Name';e={$_.DisplayName}},
                        @{n='Version';e={$_.DisplayVersion}},
                        @{n='Publisher';e={$_.Publisher}}
    }

    # Load Winget-exported PackageNames
    try {
        $manifest    = Get-Content $File -Raw | ConvertFrom-Json
        $wingetNames = $manifest.Packages | ForEach-Object { $_.PackageName }
    }
    catch {
        Write-Error "Could not parse JSON manifest: $_"
        exit 1
    }

    # Filter out anything Winget covers
    $manual = $allPrograms |
      Where-Object { $wingetNames -notcontains $_.Name } |
      Sort-Object Name -Unique

    # Write manual list
    Write-Host "→ Writing manual list to:`n    $ManualFile`n"
    $manual | ForEach-Object {
        "{0} | {1} | {2}" -f $_.Name, ($_.Version -or 'n/a'), ($_.Publisher -or 'n/a')
    } | Out-File -FilePath $ManualFile -Encoding UTF8

    Write-Host "✅ Manual list complete: $($manual.Count) entries."
    exit
}

if ($Install) {
    Write-Host "→ Installing Winget apps from manifest:`n    $File`n"
    if (-not (Test-Path $File)) {
        Write-Error "Manifest not found: $File"
        exit 1
    }
    try {
        winget import --import-file $File `
            --accept-package-agreements --accept-source-agreements --disable-interactivity
        Write-Host "`n✅ Import/install complete."
    }
    catch {
        Write-Error "Failed to import/install: $_"
        exit 1
    }
    exit
}

