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

# Loop through each package and install it
foreach ($package in $packages) {
    winget install -e --id $package
}

# Upgrade all installed packages
winget upgrade --all
