param(
    $path = "E:"
)
# Setup Credential File and Copy VM Optimization Tool from Network Share
$Temp = "C:\Temp"
if(!(Test-Path $Temp)){Write-Output "Creating $($Temp)";New-Item -Type Directory -Path $Temp|Out-Null}
Write-Output `n"Copy files"
#VMWare Optimization Tool
Copy-Item -Path "$path\VMwareOSOptimizationTool.exe" -Destination $Temp
#Copy-Item -Path "$path\Windows 10 and Server 2016 or later.xml" -Destination $Temp
#Button-Up
#Copy-Item -Path "$path\Button-Up.ps1" -Destination $Temp
