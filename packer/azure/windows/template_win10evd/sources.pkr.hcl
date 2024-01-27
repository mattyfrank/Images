source "azure-arm" "Win10-image" {

  #subscription_id = "${var.az_subscription_id}"
  subscription_id = ""
  #tenant_id = "${var.az_tenant_id}"
  tenant_id = ""

  #client_id                 = "${var.az_client_id}"     #AD service principal associated with your builder
  #client_secret             = "${var.az_client_secret}" #Password or secret for Service Principal
  #client_cert_path          = ""                        #PEM file containing cert and private key for service principal
  #client_cert_token_timeout = "30m"                     #duration for token created when using client_cert_path

  image_publisher = "${var.image_publisher}" #name of publisher for your base image
  image_offer     = "${var.image_offer}"     #name of publisher's offer for base image
  image_sku       = "${var.image_sku}"       #sku of the image offer for base image

  os_type = "${var.os_type}" #Linux/Windows to handle authentication (windows WinRM cert)
  vm_size = "${var.vm_size}" #Size of VM used for building

  #managed_image_name = "${var.managed_image_name}" #managed image name that is result of packer build
  managed_image_name = "${var.managed_image_name}_${formatdate("YYYYMMDD", timeadd(timestamp(), "-5h"))}"
  managed_image_resource_group_name = "${var.managed_image_resource_group_name}" #RG name where packer build will be saved

  #temp_resource_group_name = "Packer-Temp" #Temporary RG that is deleted at end of Packer Build
  #location = "eastus" #AZ datacenter; Must be defined if you create RG

  build_resource_group_name = "${var.build_resource_group_name}" #existing resource group to build in

  #shared_image_gallery = "WVDImages" #source for this build.

  virtual_network_name                = "${var.virtual_network_name}"                #pre-existing virtual network for build
  virtual_network_subnet_name         = "${var.virtual_network_subnet_name}"         #Required if virtual_newtork_name is set
  virtual_network_resource_group_name = "${var.virtual_network_resource_group_name}" #Required if virtual_newtork_name is set

  communicator   = "winrm"  #mechanism to configure OS.
  winrm_insecure = true     #bool; if TRUE do not check cert chain and hostname
  winrm_timeout  = "30m"    #duration to wait for WinRM to become available (defaults to 30m)
  winrm_use_ssl  = true     #bool; if TRUE then HTTPS
  winrm_username = "packer" #User Name for WinRM
}
