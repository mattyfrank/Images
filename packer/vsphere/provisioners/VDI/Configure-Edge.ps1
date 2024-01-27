$ErrorActionPreference = "Stop"

#Configure MS Edge
try{
    #Disable Edge Update Helper
    Write-Output "`nStopping EdgeUpdate"
    $UpdateService = Get-Service edgeupdate | Stop-Service
    $UpdateMService = Get-Service edgeupdatem | Stop-Service

    Write-Output "`nDisabling EdgeUpdate"
    $UpdateService | Set-Service -StartupType Disabled
    $UpdateMService | Set-Service -StartupType Disabled

    #Remove Edge Update tasks
    Write-Output "`nRemove Edge Update Scheduled Tasks"
    $schtasks = (Get-ScheduledTask -TaskName "MicrosoftEdgeUpdate*")
    Write-Output $schtasks.TaskName
    $schtasks | % {Write-Output "Disable Task: $($_.TaskName)" ; Disable-ScheduledTask -TaskName $_.TaskName}
    # Unregister-ScheduledTask -TaskName MicrosoftEdgeUpdateTaskMachineCore* -Confirm:$false
    # Unregister-ScheduledTask -TaskName MicrosoftEdgeUpdateTaskMachineUA -Confirm:$false
    # Unregister-ScheduledTask -TaskName MicrosoftEdgeUpdateBrowserReplacementTask -Confirm:$false

    #Configure Update policies, will only apply to Domain Joined Computer
    Write-Output "`nConfigure Edge Update Policies"
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" -Name "InstallDefault" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" -Name "UpdateDefault" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" -Name "Install{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" -Name "Update{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}" -Type DWord -Value 0
    Write-Output "`nConfigure WebView2 Update Policies"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" -Name "Install{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" -Name "Update{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" -Type DWord -Value 0

}catch{$_;break}