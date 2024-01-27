#Installs VMware tools locally - Designed for Horizon
param($ToolsInstaller = "E:\VMware-tools-12.3.5-22544099-x86_64.exe")

$ToolsArgs = '/s /v "/qn REBOOT=R"'

Start-Transcript -Path "C:\Temp\Install-VMwareTools.txt"

Write-Output "VMware Tool Installer: $($ToolsInstaller)"
Write-Output "VMware Tool Arguments: $($ToolsArgs)"

if(!(Test-Path $ToolsInstaller)){
    Write-Output "Missing Tools"
    $ToolsInstaller = $(Read-Host "Provide the VMware Tools path here ")
}

try{
    Write-Output "Installing VMware tools..."
    Start-Process -Wait -FilePath $ToolsInstaller -ArgumentList $ToolsArgs
    Start-Sleep -Seconds 20

}catch{
    Write-Output "VMware tools error occurred...exiting"
    Exit 1
}

Stop-Transcript
#Write-Output "Rebooting in 30 seconds, shutdown /a to abort."; shutdown /r /t 30
