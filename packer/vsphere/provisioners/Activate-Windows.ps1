## Activate Windows ##
param($KMS_FQDN)
#Start-Transcript -Path "$env:temp\activate_windows.ps1.txt"
Start-Transcript -Path "C:\Temp\activate_windows.ps1.txt"

try{
    Write-Output `n"ACTIVATE-WINDOWS: Clearing kms..."
    Start-Process -Wait -FilePath "$env:windir\System32\cscript.exe" -ArgumentList "$env:windir\System32\slmgr.vbs /ckms"

    Write-Output "ACTIVATE-WINDOWS: Setting kms server to $($KMS_FQDN)..."
    Start-Process -Wait -FilePath "$env:windir\System32\cscript.exe" -ArgumentList "$env:windir\System32\slmgr.vbs /skms $($KMS_FQDN):1688"

    Write-Output "ACTIVATE-WINDOWS: Activating Windows..."
    Start-Process -Wait -FilePath "$env:windir\System32\cscript.exe" -ArgumentList "$env:windir\System32\slmgr.vbs /ato"

}catch{
    Write-Output "ACTIVATE-WINDOWS: Error occurred...exiting"
    Exit 1
}

Write-Output "ACTIVATE-WINDOWS: Done"
Stop-Transcript
