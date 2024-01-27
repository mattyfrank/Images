#FinalizedScheduledTask For Vmware OSOT.
param($optimizer)
$ErrorActionPreference = "Stop"

$PackerShutdown = "packer-shutdown"
$Transcript     = "C:\Windows\panther\$PackerShutdown.txt"
$Script         = "C:\Windows\panther\$PackerShutdown.ps1"

Start-Transcript -Path "c:\Temp\Finalize_SchTask.txt"
Write-Output "`nFinalize $(Get-Date)"
Write-Output "Finalize Transcript: '$($Transcript)'"
Write-Output "Finalize Script File: '$($Script)'"
Write-Output "Optimizer Tool: '$($optimizer)'"

#Define Finalize Script
$shutdown_task = 
{
param($optimizer)
$TaskName = "packer-shutdown"
Start-Transcript "C:\Windows\panther\$TaskName.txt"
Write-Output `n"Delete WinRM Account"
Remove-LocalUser -Name "winrmAdmin"
Get-CimInstance -Class Win32_UserProfile | ? {$_.LocalPath -eq 'C:\Users\winrmAdmin'} | Remove-CimInstance
Write-Output `n"Delete setup log files"
gci C:\Temp\* -include *.txt, *.log | Remove-Item -Force -ErrorAction SilentlyContinue
Write-Output "Optimizer Tool: '$($optimizer)'"
Write-Output `n"Finalize"
Start-Process -FilePath $optimizer -ArgumentList "-f 0 1 2 3 4 5 6 9 10 11 -v" `
-Wait -PassThru -RedirectStandardOutput C:\Windows\panther\Finalize.txt
Write-Output `n"SDelete zero free space"
sdelete64.exe /accepteula -z C:
Write-Output `n"Delete scheduled task '$TaskName'"
schtasks.exe /delete /tn "$TaskName" /f
start-sleep -s 5
$schTask = (Get-ScheduledTask "$TaskName" -ErrorAction SilentlyContinue)
if(@($schTask)){Unregister-ScheduledTask -TaskName $($schTask.TaskName) -confirm:$false -AsJob}
Write-Output `n"Shutdown: Image Ready"
shutdown /s /t 5 /f /d p:4:1 /c "Image Ready"
}

#Write-Output `n"Disable Firewall Rule"
#Set-NetFirewallRule -DisplayGroup "Windows Remote Management" -Enabled False

#Output Script Block as Script File, Create Scheduled Task using Script File
try {
    Write-Output "Create PowerShell script file: '$($Script)'"
    $shutdown_task | Out-File -FilePath $Script -Force
    Start-Sleep 5
    Write-Output "Create scheduled task: '$PackerShutdown'"
    Start-Process -FilePath schtasks.exe -ArgumentList "/create /tn `"$PackerShutdown`" /tr `"powershell.exe -file $($Script) -optimizer $($optimizer)`" /sc ONCE /st 00:00 /ru SYSTEM"
    Start-Sleep 3
    Write-Output "Scheduled Task is '$((Get-ScheduledTask -TaskName "$PackerShutdown").State)'"
}catch{
    Write-Output "Error occurred trying to register task. Exiting..."
    Exit 1
}
Write-Output "Scheduled task registered."

Write-Output `n"Stop & Disable Trusted Installer"
$UpdateTIService = Get-Service TrustedInstaller | Stop-Service
$UpdateTIService | Set-Service -StartupType Disabled

#Write-Output "Shutting Down";shutdown /s /t 5 /c "Image Ready"

Stop-Transcript
#End