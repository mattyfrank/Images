##Clone Base Template to Golden Image.
##Clone Reference Template to Reference VMs.
##Join Domain, and Snapshot. 

<# Usage examples:

New-VMs.ps1 -reftemplate "REF-TEMPLATE-$(Get-Date -f yy.MM)-A" -RefVMPrefix "Win10-RM-$(Get-Date -f MMM)-A" -BaseTemplate "Win10_Base_$(Get-Date -f yy.MM)_A" -GoldenImage "Win10_GI_$(Get-Date -f yy.MM)-A"

#>


param(
    $RefTemplate= "REF-TEMPLATE-$(Get-Date -f yy.MM)a",
    $RefVMPrefix= "VDI-RM-$(Get-Date -f yy-MM)a-",
    $BaseTemplate= "Win10_22H2_$(Get-Date -f yy.MM)a",
    $GoldenImage= "VDI-GI-$(Get-Date -f yy.MM)a",
    $Domain=$ENV:USERDNSDOMAIN,
    $vCenter = "vCenter01.$($Domain)",
    $VMhost = "ESX001.$($Domain)"
)

# if (!(Get-Module Vmware.PowerCLI)) {
    #     Install-Module -Name Vmware.PowerCLI -Force -Confirm:$false | Out-Null
    #     Write-Output "Import VMware Module"
    #     Import-Module -Name Vmware.PowerCLI | Out-Null
# }

function New-ReferenceMachine {
    Param(
        [Parameter(Mandatory=$true)][string] $VMName,
        [Parameter(Mandatory=$true)][string] $Template,
        [Parameter(Mandatory=$false)][string] $VMFolder= "Reference Machines", 
        [Parameter(Mandatory=$false)][string] $Cluster = "cl0319vdivsanp001",
        [Parameter(Mandatory=$false)][string] $vmHost = "h0319vdi15p003.$($domain).net",
        [Parameter(Mandatory=$false)][string] $Datastore = "dsps21vdip003_s001"
    )   
    if (@(Get-Folder $VMFolder -ErrorAction SilentlyContinue).Count) {
        Write-Output "VM Folder is '$($VMFolder)'." 
        try {
            Get-VM $VMName -ErrorAction Stop
            Write-Error "VM named '$($VMName)' already exists."; return
        } 
        catch {
            Write-Output "VM named '$($VMName)' not found. Creating in folder '$($VMFolder)'."
            $NewVM = (New-VM -Name $VMName -Template $Template -Location $VMFolder -Datastore $Datastore -VMHost $VMhost)
            while (!(Get-VM $NewVM -ErrorAction SilentlyContinue)) {
                Write-Output "Waiting on VM creation..." ; Start-Sleep -Seconds 45
            }
            Write-Output "$($NewVM.name) was successfully created."
            Start-Sleep -Seconds 2
        } 
    }
    $NewVM = (Get-Vm -Name $VMName)
}
function New-GoldenImage {
    Param(
        [Parameter(Mandatory=$true)][string] $ImageName,
        [Parameter(Mandatory=$true)][string] $BaseTemplate,
        [Parameter(Mandatory=$false)][string] $VMFolderId= "Folder-group-v507088", 
        [Parameter(Mandatory=$false)][string] $Cluster = "cl0319vdivsanp001",
        [Parameter(Mandatory=$false)][string] $vmHost = "$($VMhost)",
        [Parameter(Mandatory=$false)][string] $Datastore = "dsps21vdip003_s001"
    ) 
    $vmFolder = (Get-Folder -Id $vmFolderId) #990 Folder 'Folder-group-v2623330'
    if (@(Get-Folder -Id $vmFolder.Id -ErrorAction SilentlyContinue).Count) {
        Write-Output "VM Folder Id:'$($VMFolder.Id)'." 
        Write-Output "VM Folder Name:'$($VMFolder.Name)'."
        try {
            Get-VM $ImageName -ErrorAction Stop
            Write-Error "VM named '$($ImageName)' already exists."; return
        } 
        catch {
            Write-Output "VM named '$($ImageName)' not found. Creating in folder '$($VMFolder.Name)'."
            $NewVM = (New-VM -Name $ImageName -Template $BaseTemplate -Location $vmFolder -Datastore $Datastore -VMHost $VMhost)
            while (!(Get-VM $NewVM -ErrorAction SilentlyContinue)) {
                Write-Output "Waiting on VM creation..." ; Start-Sleep -Seconds 45
            }
            Write-Output "$($NewVM.name) was successfully created."
            Start-Sleep -Seconds 2
        } 
    }else{Write-Output "No VM Folder Found"}
    $NewVM = (Get-Vm -Name $ImageName)
    return $NewVM
}
function New-Snap{
    [CmdletBinding(SupportsShouldProcess=$true)]param(
        [Parameter(Mandatory=$true)][string] $VMName,
        [Parameter(Mandatory=$true)][string] $SnapName
    )
    $VM = (Get-VM $VMName)
    if(!($VM)){Write-Error "Missing VM";break}
    #verify VM exists & power off before snapshot
    if ((Get-VM $VMName).ExtensionData.Runtime.PowerState -like "PoweredOn"){
        Write-Output "VM is Powered On, Shutting Down VM"
        Shutdown-VMGuest -VM $VMName -Confirm:$false | Out-Null
        while((Get-VM $VMName).PowerState -eq 'PoweredOn'){
            Write-Output "Wait for VM to shutdown"
            Start-Sleep 10
        }
    }
    if ((Get-VM $VMName).ExtensionData.Runtime.PowerState -like "PoweredOff") {
        Write-Output "$($VMName) is powered off, taking snapshot."
    }
    New-Snapshot -VM $VMName -Name $SnapName | Out-Null
    $Snapshot = (Get-VM $VMName | Get-Snapshot) 
    Write-Output "$($VMName) has a snapshot '$($Snapshot.Name)'"
}

#Region Main
Write-Output "Connect to vCenter"
connect-viserver $Vcenter | Out-Null

Write-Output "Create Golden Image from Base VM"
Write-Output "Base Template Name: $($BaseTemplate)"
Write-Output "Golden Image Name: $($GoldenImage)"
New-GoldenImage -ImageName $GoldenImage -BaseTemplate $BaseTemplate
New-Snap -VMname $GoldenImage -SnapName "All IC Pools"

$iso = "[$($DataStore)] 00000 - ISOs/Horizon/Horizon_Sources.iso"

Write-Output "Attach ISO"
# $drives = Get-VM -Name $GoldenImage | Get-CDDrive
# $drive = $drives[0]
$cd = New-CDDrive -VM $GoldenImage -IsoPath $iso -StartConnected

Write-Output "Create Reference VMs from Template"
$RefVMs = "$($RefVMPrefix)1", "$($RefVMPrefix)2"
foreach ($refVM in $RefVMs){
    New-ReferenceMachine -VMName $refVM -Template $RefTemplate
    Write-Output "Take Snapshot Before Domain"
    New-Snap -VMname $refVM -SnapName "Before_Domain"
    Write-Output "Start VM $refVM"
    Start-VM $refVM
}

Write-Output "Start the Golden Image VM"
Start-VM -VM $GoldenImage
Write-Output "`nInstall ThinScale on Golden Image."
Write-Output "Run the script 'D:\Apps\ThinScale\Install-Thinscale.ps1'"
Write-Output "`nJoin Each Reference VM to the Domain."
Write-Output "Run the script 'C:\Temp\Join-Domain.ps1'."

$UserInput = (Read-Host "Enter 'y' to proceed...")
if ($UserInput -like "y"){
    if ((Get-VM $GoldenImage).ExtensionData.Runtime.PowerState -like "PoweredOn"){
        Write-Output "$GoldenImage is Powered On, Shutting Down VM"
        Shutdown-VMGuest -VM $GoldenImage -Confirm:$false | Out-Null
        while((Get-VM $GoldenImage).PowerState -eq 'PoweredOn'){
            Write-Output "Wait for VM to shutdown"
            Start-Sleep 5
        }
    }
    Write-Output "Remove CD Drive"
    Remove-CDDrive -CD $cd -Confirm:$false
    Write-Output "Taking snapshot"
    New-Snap -VMname $GoldenImage -SnapName "VDA"
    $RefVMs | % {New-Snap -VMname $_ -SnapName "Ready"}
}else {Write-Output "Exiting without taking snapshot..."}

Write-Output "Disconnect from $vCenter"
Disconnect-VIServer $vCenter -Force -Confirm:$false



#EndRegion Main


#Region Scratch
<#
function New-ReferenceTemplate {
    Param(
        [Parameter(Mandatory=$true)][string] $SourceVM,
        [Parameter(Mandatory=$true)][string] $TemplateName,
        [Parameter(Mandatory=$false)][string] $VMFolder= "Reference Machines", 
        [Parameter(Mandatory=$false)][string] $Datastore = "dsps21vdip003_s001"
    )   
    if (@(Get-Folder $VMFolder -ErrorAction SilentlyContinue).Count) {
        Write-Output "VM Folder is '$($VMFolder)'." 
        try {
            Get-VM $SourceVM -ErrorAction Stop
            New-Template -VM $SourceVM -Name $TemplateName -Location $VMFolder -Datastore $Datastore 
        } 
        catch {Write-Error "Template Failed:"$Error[0]} 
    }
    $Template = (Get-Template -Name $TemplateName)
    return $Template
}

function New-Computer {
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param(
        [Parameter(Mandatory=$True)][ValidateLength(4,15)][string] $ComputerName,
        [Parameter(Mandatory=$True)][string] $OU
    )
    if(!($ComputerName)){Write-Error "Missing Computer Name"; break}
    if (!($OU)) {Write-Error "Missing OU";break}
    
    #Verify the computer object does not exist
    try {
        Get-ADComputer $ComputerName -ErrorAction SilentlyContinue | Out-Null
        Write-Warning `n"Warning!!!`nComputer Object '$($ComputerName)' already exists."
        Write-Warning "If you proceed, it will break the existing computer's domain trust."`n
        $userinput = $(Write-Output -ForegroundColor Green "Do you want to override this Computer Name? (y)es/(n)o: " -NoNewline; Read-Host)
        switch ($userinput){
            y { Write-Output "'$($ComputerName)' is set."; break} 
            n {
                Write-Output "Please select a new computer name."
                [ValidateLength(4,15)][string] $ComputerName = $(Write-Output "Enter the new Computer Name: " -ForegroundColor Green -NoNewline; Read-Host) 
                Write-Output "New Computer Name is '$($ComputerName)'"
                break
            }
        }#End Switch
    } catch {
        Write-Output "'$($ComputerName)' was not found in the domain."
        Write-Output "Creating New Computer Object '$($ComputerName)' in OU '$($OU)'"
        New-ADComputer -Name $ComputerName -SamAccountName $ComputerName -Path $OU
    }
    return $ComputerName
}

function New-VMcustomization {
    Param([Parameter(Mandatory=$True)][string]$VMName)
    $domainCreds = $(Get-Credential -Message "Domain)\UserName")
    $NewCS = $VMName
    $ComputerName = $VMName
    if ((Get-OSCustomizationSpec -Name $NewCS -ErrorAction SilentlyContinue).Count) 
        {Write-Error "Customization '$($NewCS)' already exists!";break} 
    else{   
        Write-Output "Customization'$($NewCS)' not found, creating CustomizationSpec"

        # $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($local_creds.Password)
        # $PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  
        #Clone CustomSpec as NonPersistent. NonPersistent will auto delete
        #Get-OSCustomizationSpec -Name $SourceCS | New-OSCustomizationSpec -Name $NewCS -Type NonPersistent | Out-Null

        #new CustomSpec
        New-OSCustomizationSpec -Name $NewCS `
                                -Type Persistent `
                                -FullName "$($domain.split(',')[0])" `
                                -OrgName "$($domain.split(',')[0])" `
                                -NamingScheme "fixed" `
                                -NamingPrefix $ComputerName `
                                -Domain "$($domain)" `
                                -DomainCredentials $domainCreds `
                                -ChangeSid `
                                -AdminPassword $([securestring]::new()) `
                                -AutoLogonCount "2" | Out-Null

        #Configure NIC
        $nic = Get-OSCustomizationSpec $NewCS | Get-OSCustomizationNicMapping
        Set-OSCustomizationNicMapping -OSCustomizationNicMapping $nic -IpMode UseDhcp | Out-Null
        #Set-OSCustomizationNicMapping -OSCustomizationNicMapping $nic -IpAddress "" -SubnetMask "" -DefaultGateway "" -Dns ""

        # #CustomSpec properties
         $osspecArgs = @{
             GuiRunOnce = "cmd.exe /C Powershell.exe –ExecutionPolicy Bypass -command 'Set-LocalUser -Name Administrator -Password ([securestring]::new())'"
             #"cmd.exe /C Powershell.exe –ExecutionPolicy Bypass -file C:\installs\Expand-Partition.ps1",
             #"cmd.exe /C NET USER $($local_creds.UserName) $PlainPassword /add",
             #"cmd.exe /C NET LOCALGROUP Administrators $($local_creds.UserName) /add",
             #"cmd.exe /C NET LOCALGROUP Administrators $Administrators /add",
             #"net user administrator /active:no"  
         }
        # #set above values
         Set-OSCustomizationSpec $NewCS @osspecArgs | Out-Null 
    }
    return $NewCS                                      
}

function Set-VMCustomization{
    param([Parameter(Mandatory=$True)][string]$VMName)
    $NewCS = $VMName
    #Customize Windows OS
    Write-Output "Apply OS Customization to '$($VMName)'"
    Set-VM -VM $VMName -OSCustomizationSpec $NewCS -confirm:$false | Out-Null
    Start-Sleep -Seconds 1
             
    #Power On VM and Wait for CustomSpec to apply. VM join domain on successful deployment. 
    #Write-Output "Starting VM '$($VMName)'"
    #Start-VM -VM $VMName | Out-Null
    #Write-Output "Waiting on VM to start..."
    #Start-Sleep -Seconds 60
    #$VM = (Get-VM $VMName)
    #while ($VM.Guest.HostName -notlike "$VMName.$($domain)") {
    #    $VM = (Get-VM $VMName) 
    #    Write-Output "Waiting on VM to join domain..."
    #    Start-Sleep -Seconds 60 
    #}
    #Write-Output "$($VM.Guest.HostName) is online."
}
Write-Output "Create Computer Objects in $($domain) domain"
$OU = "OU=VDI,OU=CorpClient,OU=Workstations,DC=$($domain.split(',')[0]),DC=$($domain.split(',')[1])"
New-Computer -ComputerName $refVM1 -OU $OU
New-Computer -ComputerName $refVM2 -OU $OU

Write-Output "Create VM Customization Specification file"
#Customization Specification to Rename Guest OS and Join Domain. 

#!! Customization will set the local admin password, and it cannot be blank!!
#!! VMs created from Template were not sysprepped and share the same hostname. 
#!! Suggest renamed and rebooted before join domain,

 New-VMcustomization -VMName $refVM1 
 New-VMcustomization -VMName $refVM2 

Write-Output "Apply Customization to VM"
 Set-VMCustomization -VMName $refVM1 
 Set-VMCustomization -VMName $refVM2

Write-Output "Power On VMs"
Start-VM -VM $refVM1
Start-VM -VM $refVM2


#Manually Rename and Reboot, then Join Domain and Reboot.
#From the VM's guest OS "C:\Temp\join-domain.ps1"

# Write-Output "Shutdown VM"
# Shutdown-VMGuest $refVM1 -Confirm:$false
# Shutdown-VMGuest $refVM2 -Confirm:$false
#>
#EndRegion
