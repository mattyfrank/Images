variable "az_client_id" {
  type    = string
  default = "${env("AZ_CLIENT_ID")}"
}

variable "az_client_secret" {
  type    = string
  default = "${env("AZ_CLIENT_SECRET")}"
}

#Azure Subscription ID
variable "az_subscription_id" {
  type = string
  default = ""
  #default = "${env("AZ_SUBSCRIPTION_ID")}"
}

#Azure AD Tenant ID
variable "az_tenant_id" {
  type = string
  default = ""
  #default = "${env("AZ_TENANT_ID")}"
}

##Virtual Machine Size
variable "vm_size" {
  type    = string
  default = "Standard_DS3_v4"
}

## Allow insecure connection
variable "insecure_connection" {
  type    = bool
  default = false
}

##Resource Group Name
variable "build_resource_group_name" {
  type    = string
  default = "AVD-Images"
}

##OS Type
variable "os_type" {
  type    = string
  default = "Windows"
}

##Image Offer
variable "image_offer" {
  type    = string
  default = "Windows-10"
}

##Image Publisher
variable "image_publisher" {
  type    = string
  default = "MicrosoftWindowsDesktop"
}

##Image Sku
variable "image_sku" {
  type    = string
  default = "20h2-ent"
}

##Managed Image Name
variable "managed_image_name" {
  type    = string
  default = "Packer-Win10-Image"
}

##Managed Image Resource Group
variable "managed_image_resource_group_name" {
  type    = string
  default = "AVD-Images"
}

##Virtual Network Name
variable "virtual_network_name" {
  type    = string
  default = "VDI-WestUS"
}

##Virtual Network Resource Group Name
variable "virtual_network_resource_group_name" {
  type    = string
  default = "network-infra"
}

##Virtual Network Subnet Name
variable "virtual_network_subnet_name" {
  type    = string
  default = "AVD-SessionHosts"
}

