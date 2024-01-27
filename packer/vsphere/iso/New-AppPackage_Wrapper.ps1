#Wrapper for New-AppPackage_AppVol.ps1
param(
    [Parameter(Mandatory=$true)][string][ValidateSet(
        "Oracle-Java",
        "Google",
        "Office",
        "TeamsV1",
		"MS-Teams",
        "PowerBI",
        "KeePass",
        "Adobe-Reader",
        "Notepad-PP"
    )]$AppPackage
)
$NewAppPackage = "\\nas\share\AppVol\New-AppPackage_AppVol.ps1"

& $NewAppPackage -AppPackage $AppPackage