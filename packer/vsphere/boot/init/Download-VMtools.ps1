## Installs VMware tools
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Start-Transcript -Path "$env:temp\install-vmwaretools.ps1.txt"
$vmwaretools_arguments = '/s /v "/qn REBOOT=R"'

try{
    Write-Output "INSTALL-VMWARETOOLS: Downloading VMware tools..."
    $url = 'https://packages.vmware.com/tools/releases/latest/windows/x64/'
    $site = Invoke-WebRequest "$url" -UseBasicParsing
    $filename = $site.links | Where-Object {$_.href -match ".exe"}

    (New-Object System.Net.WebClient).DownloadFile("$url$($filename.href)", "$env:temp\vmwaretools_setup.exe")
    Start-Sleep -Seconds 5

    Write-Output "INSTALL-VMWARETOOLS: Installing VMware tools..."
    Start-Process -Wait -FilePath "$env:temp\vmwaretools_setup.exe" -ArgumentList $vmwaretools_arguments
    Start-Sleep -Seconds 20

}catch{
    Write-Output "INSTALL-VMWARETOOLS: VMware tools error occurred...exiting"
    Exit 1
}

Stop-Transcript
