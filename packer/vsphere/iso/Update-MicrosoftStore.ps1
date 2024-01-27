param([int]$Wait=600)
$ErrorActionPreference = "Stop"

Start-Transcript "C:\Temp\Update-MsStore_$(Get-Date -f hh.mm).txt"

Write-Output `n"Create Scheduled Task 'Update-MsStore'"
Start-Process -FilePath "schtasks.exe" -ArgumentList '/create /tn Update-MsStore /tr "powershell.exe & start ms-windows-store://downloadsandupdates; (Get-WmiObject -Namespace "root\cimv2\mdm\dmmap" -Class "MDM_EnterpriseModernAppManagement_AppManagement01").UpdateScanMethod()" /sc ONCE /st 00:00 /ru Administrator'
Start-Sleep -s 5
Write-Output "Run Scheduled Task 'Update-MsStore'"
Start-Process -FilePath "C:\Windows\System32\schtasks.exe" -ArgumentList '/run /tn Update-MsStore /i'
Write-Output "MS Store Update Finished, wait for $($wait) seconds. Current Time - $(get-date -f hh:mm:ss)"`n
start-sleep -s $Wait 

Write-Output "Delete Scheduled Task 'Update-MsStore'"
schtasks.exe /delete /tn "Update-MsStore" /f
$schTask = (Get-ScheduledTask "Update-MsStore" -ErrorAction SilentlyContinue)
if(@($schTask)){Unregister-ScheduledTask -TaskName $($schTask.TaskName) -confirm:$false -AsJob}

Stop-Transcript

#(Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | Invoke-CimMethod -MethodName UpdateScanMethod)
#Get-WmiObject -Namespace 'root\\cimv2\\mdm\\dmmap' -Class 'MDM_EnterpriseModernAppManagement_AppManagement01').UpdateScanMethod()

#Start-Process -FilePath "schtasks.exe" -ArgumentList '/create /tn Update-MsStore /tr "powershell.exe & start ms-windows-store://downloadsandupdates; (Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | Invoke-CimMethod -MethodName UpdateScanMethod); start-sleep -s 5; exit" /sc ONCE /st 00:00 /ru Administrator'
#Start-Process -FilePath "C:\Windows\System32\schtasks.exe" -ArgumentList '/create /tn Update-MsStore /tr "cmd.exe /c start ms-windows-store://downloadsandupdates" /sc ONCE /st 00:00 /ru Administrator'

#Reset Windows Store
#wsreset.exe
#Get-AppXPackage *WindowsStore* -AllUsers | % {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}