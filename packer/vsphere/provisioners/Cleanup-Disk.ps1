Start-Transcript "C:\Temp\cleanup.ps1.txt"

Write-Output `n"Cleanup Windows"
$ngenPath = @(
    'C:\Windows\Microsoft.NET\Framework\',
    'C:\Windows\Microsoft.NET\Framework64\'
)
$ngenPath | % {
    Write-Output "Compile NGEN '$($_)'"
    Set-Location "$_"; Get-ChildItem -Filter 'v4.0*' | Set-Location; ./ngen update /force /queue |out-null; ./ngen executequeueditems |out-null
}

Write-Output `n"DISM Component Cleanup"
Dism /online /cleanup-image /startcomponentcleanup /resetbase

#Set all CleanMgr VolumeCache keys to StateFlags. 2 to allow cleanup; 0 will prevent cleanup
$Enable_List= @(
    'Active Setup Temp Folders',
    'Downloaded Program Files',
    'Internet Cache Files',
    'Old ChkDsk Files',
    'Previous Installations',
    'Recycle Bin',
    'Setup Log Files',
    'System error memory dump files',
    'System error minidump files',
    'Temporary Files',
    'Temporary Setup Files',
    'Upgrade Discarded Files',
    'Windows Upgrade Log Files',
    "Thumbnail Cache",
    "Windows Defender"
) 
$PropertyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
Write-Output `n"Enable Volume Cache Cleanup"
$Enable_List | % {
    Write-Output "$PropertyPath\$_"
    if(!(Test-Path "$PropertyPath\$_")){Write-Output "Path not found!`nPath: $PropertyPath\$_"}
    else{New-ItemProperty -Path "$PropertyPath\$_" -Name StateFlags0100 -Value 2 -PropertyType DWord -Confirm:$false}
}

$Laundry_List= @(
 "%USERPROFILE%\AppData\Local\Microsoft\Windows\WER\ReportArchive\*",
 "%USERPROFILE%\AppData\Local\Microsoft\Windows\WER\ReportQueue\*",
 "%ALLUSERSPROFILE%\Microsoft\Windows\WER\ReportArchive\*",
 "%ALLUSERSPROFILE%\Microsoft\Windows\WER\ReportQueue\*",
 "%ALLUSERSPROFILE%\Microsoft\Windows\WER\Temp\*",
 "%ProgramData%\Microsoft\Diagnosis\EventTranscript\*",
 "%TEMP%\*",
 "%WINDIR%\Temp\*",
 "%WINDIR%\Logs\*",
 "%WINDIR%\System32\LogFiles\*",
 "%WINDIR%\Windows\msdownld.tmp\*.tmp",
 "%ProgramData%\Microsoft\Windows\RetailDemo\*",
 "%WINDIR%\setup*.log",
 "%WINDIR%\setup*.old",
 "%WINDIR%\setuplog.txt",
 "%WINDIR%\winnt32.log",
 "%WINDIR%\*.dmp",
 "%WINDIR%\minidump\*.dmp",
 "%ProgramData%\Microsoft\Windows Defender\LocalCopy\*",
 "%ProgramData%\Microsoft\Windows Defender\Support\*"
)
Write-Output `n"Cleanup Files"
$Laundry_List | % {
    Write-Output "Cleanup Path '$($_)'"
    Remove-Item -Path "$_" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
}

Write-Output `n"Disk Clean Up"
Start-Process -FilePath 'cleanmgr.exe' -ArgumentList '/sagerun:101' #-Wait

Write-Output `n"Clear Event Logs"
Get-EventLog -LogName * | % {Clear-EventLog $_.Log}

Write-Output `n"SDelete zero free space"
try{Copy-Item -Path "E:\sdelete64.exe" -Destination "c:\Windows\System32" -Force -Confirm:$false}
catch{$msg="Error: Missing sDelete.exe!"; Write-Output $msg; Write-Error $msg; exit}
start-sleep -s 5
Start-Process -FilePath "c:\Windows\System32\sdelete64.exe" -ArgumentList '/accepteula -z C:' -wait

Stop-Transcript
#End#