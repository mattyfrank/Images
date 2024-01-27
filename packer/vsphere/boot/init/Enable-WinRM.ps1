##Enable WinRM and PS Remoting
param(
    $WinRM_UserName = "winrmAdmin",
    $WinRM_Password = "PackerPassword+"
)
$ErrorActionPreference = "stop"
Start-Transcript -Path "C:\Temp\Enable-WinRM.txt"

Write-Output `n"Set Network Connection to Private"
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

##Enable WinRM and PS Remoting
Write-Output `n"Enable PSRemoting"
Enable-PSRemoting -Force -SkipNetworkProfileCheck

write-output `n"Setup WinRM"
winrm quickconfig -q

write-output `n"Transport HTTP"
winrm quickconfig -transport:http

write-output `n"Allow Unencrypted Service"
winrm set "winrm/config/service" '@{AllowUnencrypted="true"}'

write-output `n"Allow Basic Auth"
winrm set "winrm/config/service/auth" '@{Basic="true"}'

write-output `n"Port 5985"
winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'

# Make sure appropriate firewall port openings exist
write-output `n"Enable FW Rule Windows Remote Management (HTTP-In)"
Set-NetFirewallRule -DisplayGroup "Windows Remote Management" -Enabled True -Action Allow -RemoteAddress Any

Write-Output `n"Auto(Delayted) Start"
$result = sc.exe config WinRM start= delayed-auto
if ($result -ne '[SC] ChangeServiceConfig SUCCESS') {
    throw "sc.exe config failed with $result"
}

Stop-Transcript