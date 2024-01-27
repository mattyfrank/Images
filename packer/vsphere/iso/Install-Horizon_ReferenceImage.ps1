#Does NOT Install Horizon Agent
[CmdletBinding(SupportsShouldProcess=$True)]
Param(
    [Parameter(Mandatory=$true)]$DEMprofiler,$AppVolInstaller,$DEMServer,$AppVolServer
)
$ErrorActionPreference = "Stop"

#Install Arguments
$AppVolArgs = "/qn MANAGER_ADDR=$AppVolServer MANAGER_PORT=443 EnforceSSLCertificateValidation=0 Reboot=R"

Start-Transcript "c:\temp\Install-Horizon-$(Get-Date -F yyyy-MM-dd_hh-mm).txt"

#add "`" to encapsulate var in quotes
#Install VMware App Volume Agent
if(!(Test-Path $AppVolinstaller)){Write-Error "Missing AppVol Installer";break}
try{
    Write-Output "`nInstall App Volumes"
    Write-Output "AppVol Installer: $($AppVolinstaller)"
    Write-Output "AppVol Arguments: $($AppVolArgs)"    
    Start-Process msiexec -ArgumentList "/i `"$AppVolinstaller`" $AppVolArgs" -PassThru -Wait
}
catch {Write-error $error[0];break}

#Install VMware DEM Application Profiler
if(!(Test-Path $DEMprofiler)){Write-Error "Missing DEM Installer";break}
try {
    Write-Output "`nInstall DEM Application Profiler"
    Write-Output "DEM Profiler Installer: $($DEMprofiler)"
    Start-Process msiexec -ArgumentList "/i `"$DEMprofiler`" /passive" -PassThru -Wait
}
catch {Write-Error $Error[0];break}

#APP Volume Registry Post Install
Write-Output "`nDelay values for AppVol"
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\svdriver\Parameters" /v "DelayRegistryReverseReplication" /t REG_DWORD /d '90' /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\svdriver\Parameters" /v "FirewallReloadDelay" /t REG_DWORD /d '180' /f

Write-Output "`nTime Out values for AppVol"
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\svservice\Parameters" /v "VolWaitTimeout" /t REG_DWORD /d '30' /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\svservice\Parameters" /v "VolMountConfirmationReqFrequency" /t REG_DWORD /d '10' /f

# Write-Output "`nDisable SSL Validation"
# Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\svservice\Parameters" -Name "EnforceSSLCertificateValidation" -Value 0

Write-Output "`nVerify SSL Validation is Disabled"
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\svservice\Parameters" -Name "EnforceSSLCertificateValidation"

Stop-Transcript

#ReBoot.
Write-Output "rebooting in 10 seconds"; shutdown /r /t 10
