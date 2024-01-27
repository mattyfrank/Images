param(
    $GPO_GUID,
    $Path = "E:",
    $WinSrc = "D:\sources\sxs"
)
$ErrorActionPreference = "Stop"

Write-Output "Set Time to Pacific Time Zone (-8)"
tzutil /s "Pacific Standard time"
#Set-TimeZone -Name "Pacific Standard Time"

Write-Output `n"Enable Window Features"
if (!(Test-Path $WinSrc)){Write-Output "Missing sxs sources"; break}
try{
    Write-Output "`nEnable .Net3"
    DISM /Online /Quiet /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:$WinSrc
    Write-Output "`nEnable MSMQ AD Integration and HTTP."
    DISM /Online /Quiet /Enable-Feature /FeatureName:MSMQ-ADIntegration /All /LimitAccess /Source:$WinSrc
    DISM /Online /Quiet /Enable-Feature /FeatureName:MSMQ-HTTP /All /LimitAccess /Source:$WinSrc
}
catch{Write-Error $_;break}

Write-Output "`nInstall VisualC++ 2005"
$vc2005 = "$Path\vcredist_x86_2005SP1.exe" 
if(!(Test-Path $vc2005)){Write-Error "Missing VisualC2005 installer."; break}
try{Start-Process -FilePath `"$vc2005`" -ArgumentList "/q" -PassThru -Wait}
catch{Write-Error $_ ; break}

Write-Output "`nInstall VisualC++ 2008"
$vc2008 = "$Path\vcredist_x86_2008SP1.exe" 
if(!(Test-Path $vc2008)){Write-Error "Missing VisualC2008 installer."; break}
try{Start-Process -FilePath `"$vc2008`" -ArgumentList "/q" -PassThru -Wait}
catch{Write-Error $_ ; break}

Write-Output "`nCopy sDelete"
$sdelete = "$Path\sdelete64.exe"
if(!(Test-Path $sdelete)){Write-Error "missing sDelete.exe!"; break}
try{Copy-Item -Path $sdelete -Destination "c:\Windows\System32"}
catch{Write-Error $_; break}

$MenuLayout = "$Path\StartLayout.xml"
if(!(Test-Path $MenuLayout)){Write-Error "Missing Start Menu Layout xml"; break}
Write-Output "`nStart Menu Layout"
try{Import-StartLayout -LayoutPath $MenuLayout -MountPath $env:SystemDrive\}
catch{Write-Error $_ }

[int]$MaxSize = 8192
[int]$MinSize = 8192
$computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges;
$computersys.AutomaticManagedPagefile = $False;
Write-Output "`nAutomatically Manage Page File = $($computersys.AutomaticManagedPagefile)"
$computersys.Put() | Out-Null;
$pagefile = Get-WmiObject -Query "Select * From Win32_PageFileSetting Where Name like '%pagefile.sys'";
$pagefile.InitialSize = $MinSize;
$pagefile.MaximumSize = $MaxSize;
$pagefile.Put() | Out-Null;
Write-Output "Page File Initial Size is set to: $($MinSize)"
Write-Output "Page File Maximum Size is set to: $($MaxSize)"

Write-Output `n"Import Group Policies"
try{
    Start-Process -Wait $Path\LGPO.exe -ArgumentList "/g $Path\{$GPO_GUID}"
    #Start-Process mmc.exe -argumentlist "gpedit.msc"
}catch{$_; break}
