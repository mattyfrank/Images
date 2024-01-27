#create Custom ISO using oscdimg from Windows ADK.
#.\CreateISO\Create-ISO.ps1

param(
    [string]$oscdimgPath = ".\CreateISO\Oscdimg",
    [string]$ISO_Source = ".\GoldenImage",
    [string]$ISO_Target = "Horizon_Sources.iso"
)

# Make ISO
Write-Output "Create ISO..."
& $oscdimgPath\oscdimg.exe -u1 $ISO_Source $ISO_Target