# List of packages to install
$packages = @(
    "Balena.Etcher",
    "Bitwarden.Bitwarden",
    "Datronicsoft.SpacedeskDriver.Server",
    "Debian.Debian",
    "Docker.DockerDesktop",
    "Eugeny.Tabby",
    "Figma.Figma",
    "GitHub.GitHubDesktop",
    "Google.AndroidStudio",
    "Google.Chrome",
    "JetBrains.PyCharm.Professional",
    "JetBrains.Rider",
    "JetBrains.Toolbox",
    "Lenovo.DockManager",
    "Lenovo.SystemUpdate",
    "Logitech.GHUB",
    "Logitech.OptionsPlus",
    "Meld.Meld",
    "Microsoft.VisualStudioCode",
    "Microsoft.WindowsTerminal",
    "MullvadVPN.MullvadVPN",
    "Notepad++.Notepad++",
    "Prusa3D.PrusaSlicer",
    "RaspberryPiFoundation.RaspberryPiImager",
    "Termius.Termius",
    "TortoiseSVN.TortoiseSVN",
    "VideoLAN.VLC",
    "VMware.WorkstationPro",
    "WhatsApp.WhatsApp",
    "ZeroTier.ZeroTierOne"
)

# Remove duplicates and sort the packages alphabetically
$packages = $packages | Sort-Object -Unique

# Get the manufacturer of the device
$manufacturer = (Get-WmiObject -Class Win32_ComputerSystem).Manufacturer

# Loop through each package and install it
foreach ($package in $packages) {
    # Check if the package is a Lenovo package and the manufacturer is Lenovo
    if ($package -like "*Lenovo.*" -and $manufacturer -like "*Lenovo*") {
        winget install -e --id $package
    }
    elseif ($package -notlike "*Lenovo.*") {
        winget install -e --id $package
    }
}

# Upgrade all installed packages
winget upgrade --all
