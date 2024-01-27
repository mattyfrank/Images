# Pre-optimize (this allows using the additional command line switches that are not available when using a custom template)
param(
    $Optimizer = "E:\Optimize\VMwareHorizonOSOptimizationTool-x86_64-1.2.2303.21510536.exe",
    $Template = "E:\Optimize\Windows 10, 11 and Server 2019, 2022.xml"
)

if(!(Test-Path $Optimizer)){Write-Error "Optimizer Missing!" -ErrorAction Stop}

Write-Output "Optimizer Template: '$($Template)'"
Write-Output "Optimizer Tool: '$($Optimizer)'"

Write-Output `n"PreOptimize $(Get-Date)"
Start-Process -FilePath $Optimizer -ArgumentList "-o -t `"$Template`" -notification enable -storeapp remove-all --exclude ScreenSketch Calculator StickyNotes Photos -v" -Wait -PassThru -RedirectStandardOutput C:\Temp\Pre-Optimize.log

Write-Output "End Pre-Optimize"

#disabled in packer
#Write-Output "Rebooting in 30 seconds, shutdown /a to abort."; shutdown /r /t 30