param($WinRM_UserName="winrmAdmin")
$ErrorActionPreference = "stop"
Start-Transcript -Path "C:\Temp\Set-LocalAdmin.txt"

$Expire = $(Get-Date).AddHours(4)
Write-Output "Account Name: $WinRM_UserName"
Write-Output "Account Expires: $Expire"

Set-LocalUser $WinRM_UserName -AccountExpires $Expire

# Write-Output `n"Create User Account: $($WinRM_UserName)"
# $SecureString = ConvertTo-SecureString $WinRM_Password -AsPlainText -Force
# New-LocalUser $WinRM_UserName -Password $SecureString -Description "temp provisioning account for winRM." -AccountExpires $Expire 

# Write-Output "Add $($WinRM_UserName) to local Administrators"
# Add-LocalGroupMember -Group "Administrators" -Member $WinRM_UserName

Stop-Transcript