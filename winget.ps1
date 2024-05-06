# List of packages to install
$packages = @(
    "Balena.Etcher",
    "Debian.Debian",
    "Lenovo.DockManager",
    "Lenovo.SystemUpdate",
    "Logitech.GHUB",
    "Logitech.OptionsPlus",
    "Microsoft.WindowsTerminal",
    "RaspberryPiFoundation.RaspberryPiImager",
    "TortoiseSVN.TortoiseSVN",
    "WhatsApp.WhatsApp",
    "Eugeny.Tabby"
)

# Loop through each package and install it
foreach ($package in $packages) {
    winget install -e --id $package
}
