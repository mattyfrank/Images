[CmdletBinding(SupportsShouldProcess=$True)]
Param(
    [Parameter(Mandatory=$true)]$HorizonInstaller,$DEMinstaller,$AppVolInstaller,$DEMServer,$AppVolServer
)
$ErrorActionPreference = "Stop"

#Install Arguments
$HorizonArgs = '/s /v"/qn REBOOT=R RDP_CHOICE=1 ADDLOCAL=Core,USB,RTAV,NGVC,V4V,ScannerRedirection,VmwVaudio,GEOREDIR,PerfTracker,HelpDesk"'   
$DEMargs = "/passive COMPENVCONFIGFILEPATH=\\$DEMserver\DEM_Config$\Config\general COMPENVMAXCONFIGFILEPATHWAIT=120"
$AppVolArgs = "/qn MANAGER_ADDR=$AppVolServer MANAGER_PORT=443 EnforceSSLCertificateValidation=0 Reboot=R"

Start-Transcript "c:\temp\Install-Horizon-$(Get-Date -F yyyy-MM-dd_hh-mm).txt"
Write-Output "DEM Server: $DEMServer"
Write-Output "AppVolume Server: $AppVolServer"

#Install Horizon Agent 
if(!(Test-Path $HorizonInstaller)){Write-Error "Missing Horizon Agent Installer";break}
try {
    Write-Output "Install Horizon Agent"
    Write-Output "Horizon Installer: $($HorizonInstaller)"
    Write-Output "Horizon Arguments: $($HorizonArgs)"
    Start-Process -Wait $HorizonInstaller -ArgumentList $HorizonArgs
}
catch {Write-Error $Error[0];break}

#add "`" to encapsulate var in quotes
#Install VMware Dynamic Environment Manager
if(!(Test-Path $DEMinstaller)){Write-Error "Missing DEM Installer";break}
try {
    Write-Output "`nInstall DEM Agent"
    Write-Output "DEM Installer: $($DEMinstaller)"
    Write-Output "DEM Arguments: $($DEMargs)"
    Start-Process msiexec -ArgumentList "/i `"$DEMinstaller`" $DEMargs" -PassThru -Wait
}
catch {Write-Error $Error[0];break}


#Install VMware App Volume Agent
if(!(Test-Path $AppVolInstaller)){Write-Error "Missing AppVol Installer";break}
try{
    Write-Output "`nInstall App Volumes"
    Write-Output "AppVol Installer: $($AppVolInstaller)"
    Write-Output "AppVol Arguments: $($AppVolArgs)" 
    Start-Process msiexec -ArgumentList "/i `"$AppVolInstaller`" $AppVolArgs" -PassThru -Wait
}
catch {Write-error $error[0];break}

#APP Volume Registry Post Install
Write-Output "`nDelay values for AppVol"
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\svdriver\Parameters" /v "DelayRegistryReverseReplication" /t REG_DWORD /d '90' /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\svdriver\Parameters" /v "FirewallReloadDelay" /t REG_DWORD /d '180' /f

Write-Output "`nTime Out values for AppVol"
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\svservice\Parameters" /v "VolWaitTimeout" /t REG_DWORD /d '30' /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\svservice\Parameters" /v "VolMountConfirmationReqFrequency" /t REG_DWORD /d '10' /f

#Write-Output "`nDisable SSL Validation"
#Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\svservice\Parameters" -Name "EnforceSSLCertificateValidation" -Value 0

Write-Output "`nVerify SSL Validation is Disabled"
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\svservice\Parameters" -Name "EnforceSSLCertificateValidation"

Stop-Transcript

#ReBoot.
Write-Output "rebooting in 10 seconds"; shutdown /r /t 10
