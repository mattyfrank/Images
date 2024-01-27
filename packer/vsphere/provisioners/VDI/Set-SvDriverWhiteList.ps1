#https://kb.vmware.com/s/article/81246
Write-Output `n"Add spoolsv to svdriver WhiteList"
$Value = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\svdriver\Parameters -Name HookInjectionWhitelist
$Update = $Value.HookInjectionWhitelist + '*\spoolsv.exe||*'
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\svdriver\Parameters -Name HookInjectionWhitelist $Update -Type MultiString

#Write-Output $(Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\svdriver\Parameters -Name HookInjectionWhitelist).HookInjectionWhitelist
