# Optimize
param(
    $Optimizer = "E:\Optimize\VMwareHorizonOSOptimizationTool-x86_64-1.2.2303.21510536.exe",
    $Template = "E:\Optimize\Windows 10, 11 and Server 2019, 2022.xml"
)

if(!(Test-Path $Optimizer)){Write-Error "Optimizer Missing!" -ErrorAction Stop}

Write-Output "Optimizer Tool: '$($optimizer)'"
Write-Output "Optimizer Template: '$($Template)'"

Write-Output `n"Optimize $(Get-Date)"
Start-Process -FilePath $Optimizer -ArgumentList "-o -t `"$Template`" -v" -Wait -PassThru -RedirectStandardOutput C:\Temp\Optimize.log

Write-Output "End Optimize"

#disabled in packer
#Write-Output "Rebooting in 30 seconds, shutdown /a to abort."; shutdown /r /t 30
