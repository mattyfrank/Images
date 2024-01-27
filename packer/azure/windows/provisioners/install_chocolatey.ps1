## Install and configure chocolatey ##

Start-Transcript -Path "$env:temp\install_chocolatey.ps1.txt"
Write-Output "INSTALL-CHOCOLATEY: Installing..."

try {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1")) | Out-File -FilePath "$env:temp\install_chocolatey.log"
}
catch {
    Write-Output "INSTALL-CHOCOLATEY: Error occurred...exiting"
    Exit 1
}

Write-Output "INSTALL-CHOCOLATEY: Done"

Stop-Transcript
