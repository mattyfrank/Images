[CmdletBinding(SupportsShouldProcess=$true)]
param 
(
    [Parameter()][string] $creds
)
New-PSDrive -Name "FileShare" -Root '\\DOMAIN\NAS\VDI\Golden Image' -PSProvider "FileSystem" -Credential $Cred
