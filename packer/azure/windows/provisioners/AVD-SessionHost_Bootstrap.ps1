## Powershell Script for AVD IMG
## Deploy Windows 10 MultiSession w/o Office
## Mount NetworkDrive, and Execute Script

##Install chocolatey
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Set-ExecutionPolicy Bypass -Scope Process -Force;Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1")) | Out-File -FilePath "$env:temp\install_chocolatey.log"
choco upgrade chocolatey -y
choco upgrade chocolatey-core.extension -y

##Install Free Apps
#choco upgrade firefoxesr -packageParameters "MaintenanceService=false" -y
choco upgrade firefoxesr -y
choco upgrade googlechrome -y
choco upgrade microsoft-edge -y
choco upgrade notepadplusplus -y 
choco upgrade 7zip -y
choco upgrade imageglass -y

##Install FSLogix
choco upgrade fslogix -y

##Install Office365 Enterprise Apps Semi-Annual Channel Release
#$o365ConfigPath = "\\Domain\NAS\VDI\Golden Image\WVD-General-Office365-Configuration.xml" 
choco upgrade office365proplus --params "/ConfigPath:https://deploymentconfigstorage.blob.core.windows.net/deploymentconfig/UNIQUE_ID" -y

##Install OneDrive
choco upgrade onedrive -y

##Install Teams WebSocket
#$websocket = "\\Domain\NAS\VDI\Golden Image\wvd-source-files\MsRdcWebRTCSvc_HostSetup_1.0.2006.11001_x64.msi"
#msiexec /passive /i $websocket
choco install microsoft-teams-websocket-plugin

##Install Teams
choco install microsoft-teams.install --install-arguments="'ALLUSERS=1'" -

##Install Licensed Apps
choco upgrade adobeacrobat-fr -y --skip-virus-check

##Get all choco apps installed
choco list --l

##Install CSR Admin (SysAdmin) Tools
#choco upgrade winscp.install -y
#choco upgrade securecrt -y
#choco upgrade rdm -y
#choco upgrade vscode.install -y
#choco upgrade powershell-core -y
#choco upgrade python -y
#choco upgrade PowerBi -y
#choco upgrade gt-sccm-console -y

##Enable RSAT Capability
#DISM.exe /Online /add-capability /CapabilityName:Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 /CapabilityName:Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0 /CapabilityName:Rsat.CertificateServices.Tools~~~~0.0.1.0 /CapabilityName:Rsat.DHCP.Tools~~~~0.0.1.0 /CapabilityName:Rsat.Dns.Tools~~~~0.0.1.0 /CapabilityName:Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0 /CapabilityName:Rsat.FileServices.Tools~~~~0.0.1.0 /CapabilityName:Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0 /CapabilityName:Rsat.IPAM.Client.Tools~~~~0.0.1.0 /CapabilityName:Rsat.LLDP.Tools~~~~0.0.1.0 /CapabilityName:Rsat.NetworkController.Tools~~~~0.0.1.0 /CapabilityName:Rsat.NetworkLoadBalancing.Tools~~~~0.0.1.0 /CapabilityName:Rsat.RemoteAccess.Management.Tools~~~~0.0.1.0 /CapabilityName:Rsat.RemoteDesktop.Services.Tools~~~~0.0.1.0 /CapabilityName:Rsat.ServerManager.Tools~~~~0.0.1.0 /CapabilityName:Rsat.Shielded.VM.Tools~~~~0.0.1.0 /CapabilityName:Rsat.StorageReplica.Tools~~~~0.0.1.0 /CapabilityName:Rsat.VolumeActivation.Tools~~~~0.0.1.0 /CapabilityName:Rsat.WSUS.Tools~~~~0.0.1.0 /CapabilityName:Rsat.StorageMigrationService.Management.Tools~~~~0.0.1.0 /CapabilityName:Rsat.SystemInsights.Management.Tools~~~~0.0.1.0

##Delete Desktop Icons
Remove-Item "c:\Users\*\Desktop\Firefox.lnk" -force
Remove-Item "c:\Users\*\Desktop\Google Chrome.lnk" -force
Remove-Item "c:\Users\*\Desktop\Microsoft Edge.lnk" -force
Remove-Item "c:\Users\*\Desktop\Adobe Acrobat DC.lnk" -force
Remove-Item "c:\Users\*\Desktop\ImageGlass.lnk" -force
Remove-Item "c:\Users\*\Desktop\Visual Studio Code.lnk" -force
Remove-Item "c:\Users\*\Desktop\Power BI Desktop.lnk" -force
Remove-Item "c:\Users\*\Desktop\WinSCP.lnk" -force
Remove-Item "c:\Users\*\Desktop\SecureCRT 8.7.lnk" -force

##Set Time to Eastern Time Zone
tzutil /s "Eastern Standard Time"
 
##Disable Auto-Updates
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f

##TimeZone Redirection 
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fEnableTimeZoneRedirection /t REG_DWORD /d 1 /f

##Disable Storage Sense
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v 01 /t REG_DWORD /d 0 /f

##Regedit to optimize Teams for WVD
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Teams" /v IsWVDEnvironment /t REG_DWORD /d 1 /f

##Regedit to add in Web Socket Redirector
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\AddIns\WebRTC Redirector" /v "WebRTC Redirector Enabled" /t REG_DWORD /d 1 /f

##Set Files for Post Deployment
$localpath = "C:\installs"
$remotepath = "\\DOMAIN\NAS\VDI\Golden Image\wvd-source-files"

##Create C:\installs
Write-Output "Creating Directory: " $localpath 
New-Item $localpath -ItemType Directory

##Copy Post Deploy Script to C:\installs
Write-Output "Copy Post Deployment Script to " $localpath
Get-Item "$remotepath\post-deploy.ps1" | Copy-Item -Destination $localpath

##Copy WVD Optimization Script to C:\installs
Write-Output "Copy Windows Virtual desktop Optimization to " $localpath
Get-Item "$remotepath\Virtual-Desktop-Optimization-Tool-master.zip" | Copy-Item -Destination $localpath

##Expand WVD Optimization Files
Write-Output "Expand Zipped Files"
Expand-Archive $LocalPath\'Virtual-Desktop-Optimization-Tool-master.zip' -DestinationPath $localpath

##Copy ADM to C:\Installs
#Write-Output "Copy ADML 7 ADMX Files to " $localpath
#Get-Item "$remotepath\ADM Files.zip" | Copy-Item -Destination $localpath

##Copy ADML/ADMX files
#Write-Output "Copy ADML and ADMX files"
#Get-ChildItem "$localpath\ADM Files\*.admx" | Copy-Item -Destination "C:\Windows\PolicyDefinitions"
#Get-ChildItem "$localpath\ADM Files\en-US" | Copy-Item -Destination "C:\Windows\PolicyDefinitions\en-US"

##Cleanup
Start-Sleep -Seconds 60
Write-Output "Cleanup files in " $localpath
Get-Item "$LocalPath\Virtual-Desktop-Optimization-Tool-master.zip" | Remove-Item -Force -Confirm:$false
#Get-Item $LocalPath\'ADM Files.zip' | Remove-Item -Force -Confirm:$false
#Get-Item $LocalPath\'ADM Files' | Remove-Item -Recurse -Force -Confirm:$false

##Reboot
& shutdown -r -t 300

##After Reboot - 
##SysPrep and ShutDown.
#C:\Windows\system32\sysprep\sysprep.exe /generalize /shutdown /oobe



