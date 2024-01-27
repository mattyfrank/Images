$ErrorActionPreference = "Stop"

$installer = "C:\Temp\MicrosoftEdgeWebview2Setup.exe"
$title = "Edge Web View2 Runtime Setup"
$URL = "https://go.microsoft.com/fwlink/p/?LinkId=2124703"

Start-Transcript "C:\Temp\Install-WebView2.txt"
Write-Output `n"Install $title"

Write-Output "Download $title"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
(New-Object System.Net.WebClient).DownloadFile($url, "$installer")
Start-Sleep -s 30

if(!(Test-Path $installer)){
    $msg="Missing File: $installer"; Write-Output $msg; Write-Error $msg; break
}else{
    Write-Output "Try to install $title" 
    try{
        Write-Output "Install $title"
        Start-Process -Wait -FilePath $installer -ArgumentList "/silent /install"
    }catch{$msg="Failed to Install: $installer"; Write-Output $msg; Write-Error $msg}
}
start-sleep -s 30
Write-Output "Delete $installer"
try {Remove-Item $installer -Force -Confirm:$false}catch{Write-Output "Delete Failed: $($installer)"}
Stop-Transcript
#END