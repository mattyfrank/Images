#$VerbosePreference = 'Continue'
$ErrorActionPreference = "Stop"

Start-Transcript -Path "c:\Temp\Cleanup_SchTask.txt"

#Register Scheduled Task (powershell shutdown)
$shutdown_task = {
Start-Transcript "C:\Windows\panther\packer-shutdown.txt"
Write-Output `n"Delete WinRM Account"
Remove-LocalUser -Name "winrmAdmin"
$LocalProfile = (Get-CimInstance -Class Win32_UserProfile | ? {$_.LocalPath -like "C:\Users\winrmAdmin"})
if(@($LocalProfile)){Remove-CimInstance -InputObject $LocalProfile -Confirm:$false}
Write-Output `n"Delete setup log files"
gci C:\Temp\* -include *.txt, *.log | Remove-Item -Force -ErrorAction SilentlyContinue
Write-Output `n"Clear IP Settings"
Ipconfig /flushdns; Ipconfig /release
Write-Output `n"Delete scheduled task 'packer-shutdown'"
schtasks.exe /delete /tn "packer-shutdown" /f
start-sleep -s 5
$schTask = (Get-ScheduledTask "packer-shutdown" -ErrorAction SilentlyContinue)
if(@($schTask)){Unregister-ScheduledTask -TaskName $($schTask.TaskName) -confirm:$false -AsJob}
Write-Output `n"Shutdown: Image Ready"
Stop-Transcript
shutdown /s /t 5 /f /d p:4:1 /c "Image Ready"
}

<#PowerShell
Write-Output "Disable WinRM Service"
Set-Service -Name winrm -StartupType Disabled

Write-Output "Delete WinRM listener"
winrm delete winrm/config/Listener?Address=*+Transport=HTTP

Write-Output "Disable WinRM Firewall Rule"
Set-NetFirewallRule -DisplayGroup "Windows Remote Management" -Enabled False

Write-Output "Disable PsRemoting"
Disable-PSRemoting -Force

Write-Output "Enable Remote UAC access token filtering"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name LocalAccountTokenFilterPolicy -Value 0

Write-Output "Enable UAC"
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name EnableLUA -Value 1
#>

try {
    Write-Output "CLEANUP: Create batch file: C:\Windows\panther\packer-shutdown.ps1"
    $shutdown_task | Out-File -FilePath C:\Windows\panther\packer-shutdown.ps1 -Force
    Start-Sleep 5
    Write-Output "CLEANUP: Create scheduled task: packer-shutdown"
    Start-Process -FilePath "C:\Windows\System32\schtasks.exe" -ArgumentList '/create /tn packer-shutdown /tr "powershell.exe -file C:\Windows\panther\packer-shutdown.ps1" /sc ONCE /st 00:00 /ru SYSTEM'
    Start-Sleep 3
    Write-Output "CLEANUP: packer-shutdown task state is $((Get-ScheduledTask -TaskName "packer-shutdown").State)"
}catch{
    Write-Output "CLEANUP: Error occurred trying to register task. Exiting..."
    Exit 1
}
Write-Output "CLEANUP: Scheduled task registered."

#Write-Output "Shutting Down";shutdown /s /t 5 /c "Image Ready"

Stop-Transcript

#End