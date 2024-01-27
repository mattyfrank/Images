#Join Computer to Domain under specific OU.
param($NewHostName,$Domain)
#If Computer Name does not match standard naming scheme rename and reboot.
if($env:computername -notlike "VDI-*"){
    Write-Output "Rename Computer and Reboot"
    if(!$NewHostName){$NewHostName=Read-Host "Enter New Computer Name"}
    Rename-Computer -NewName $NewHostName -Force -Restart
}else{
    $cred = Get-Credential -Message "Domain\UserName"
    #OU not needed if computer obj is pre-created.
    $OU = "OU=VDI,OU=Workstations,DC=$($Domain.split('.')[0]),DC=$($Domain.split('.')[1])"
    Write-Output "Join Computer to Domain."
    if(!$NewHostName){Add-Computer -DomainName $domain -ComputerName $($env:computername) -Credential $cred -OuPath $OU -Force -Restart}
    else{Add-Computer -DomainName $domain -ComputerName $($env:computername) -NewName $NewHostName -Credential $cred -OuPath $OU -Force -Restart}
}
