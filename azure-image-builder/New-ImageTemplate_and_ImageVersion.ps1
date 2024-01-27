######################################################################
param(
    [Parameter(Mandatory=$true)][ValidateSet("nonprod","prod")][string]$env,
    [Parameter(Mandatory=$true)][ValidateSet("dev","evd","w11","evd_v2")][string]$ImageType
)

#Region Vars

#AZSubscripton
#NonProd-CorporateServices-VDI   
if($env -eq "nonprod"){$subID = "####"}
#Prod-CorporateServices-VDI 
if($env -eq "prod"){$subID = "####"}

#Windows Source Image
if($ImageType -eq "evd"){$ImageSKU = "win10-22h2-avd"; $ImageOffer = "windows-10"}
#Generation 2 VMs
if($ImageType -eq "dev"){$ImageSKU = "win10-22h2-ent-g2"; $ImageOffer = "windows-10"}
if($ImageType -eq "w11"){$ImageSKU = "win11-22h2-avd"; $ImageOffer = "windows-11"}
if($ImageType -eq "evd-v2"){$ImageSKU = "win10-22h2-avd-g2"; $ImageOffer = "windows-10"}


#Location (see possible locations in main docs)
$location="westus2"

$avdURL = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_04-24-2023.zip"

#Destination image resource group
$imageResourceGroup= "rg-$env-images-$location"

#Template Config File
$jsonTemplate= ".\arm-it-avd-images.json"              #Generalized JSON

#Azure Image Template Name
# $imageTemplateName="it-test-$ImageType"
$imageTemplateName="it-$env-$ImageType-$location-$(Get-Date -f dd.MMM.yyyy)"

# Connect-AzAccount -AccountId UserName@YourDomain.com
Set-AzContext -Subscription $subID | Out-null

#Get Subnet ID
$vnet   = Get-AzVirtualNetwork -Name "internal-network"  
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "internal-infra-01"

#Get Azure Image Gallery ID
$galleryImage = Get-AzGalleryImageDefinition `
    -ResourceGroupName "rg-$env-images-$location" `
    -GalleryName "gal_avd_$($env)_$($location)" `
    -Name "img-$($env)-$($ImageType)-$($location)" 

#Get Managed Identity ID
$ManagedID = Get-AzUserAssignedIdentity -Name "user-$($env)-aib-$($location)" -ResourceGroupName "rg-$($env)-mgmt-$($location)"

#EndRegion Vars
#########################################################

#Deploy JSON Template to Azure Image ResourceGroup as an Azure Image Template file
New-AzResourceGroupDeployment `
    -ResourceGroupName $imageResourceGroup `
    -TemplateFile $jsonTemplate `
    -imageTemplateName $imageTemplateName `
    -env $env `
    -subnetId $subnet.Id `
    -galleryImageId $galleryImage.Id `
    -userAssignedIdentities $ManagedID.Id `
    -ImageOffer $ImageOffer `
    -ImageSKU $ImageSKU #`
    #-avdAgentURL $avdURL

#Create new image version from image template(runs json customizations at this step)
Invoke-AzResourceAction `
    -ResourceName $imageTemplateName `
    -ResourceGroupName $imageResourceGroup `
    -ResourceType Microsoft.VirtualMachineImages/imageTemplates `
    -Action Run `
    -Force

#end