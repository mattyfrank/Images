variable "username" {
  default   = null
  sensitive = true
}
variable "password" {
  default   = null
  sensitive = true
}
variable "insecure_connection" {
  type    = bool
  default = true
}
variable "winrm_username" {
  default   = "winrmAdmin"
  sensitive = true
}
variable "winrm_password" {
  default   = null
  sensitive = true
}
variable "winrm_insecure" {
  type    = bool
  default = true
}
variable "winrm_use_ssl" {
  type    = bool
  default = false
}
##Build specific vars
variable "vm_name" {
  type    = string
  default = null
}
variable "guest_os_type" {
  default = "windows9_64Guest"
}
variable "disk_controller" {
  type = map(string)
  default = {
    pvscsi   = "pvscsi"
    lsilogic = "lsilogic-sas"
  }
}
variable "disk" {
  type    = number
  default = "51200"
}
variable "cpu" {
  type    = number
  default = 2
}
variable "cpu_cores" {
  type    = number
  default = 2
}
variable "ram" {
  type    = number
  default = 6144
}
variable "video_ram" {
  type    = number
  default = 79872
}
variable "network_card" {
  default = "vmxnet3"
}
##var Files *pkrvars.hcl
variable "win10_iso" {
}
variable "win11_iso" {
}
variable "srv2019_iso" {
}
variable "srv2022_iso" {
}
variable "horizon_iso" {
}
variable "vcenter_server" {
}
variable "datacenter" {
}
variable "cluster" {
}
variable "datastore" {
}
variable "network" {
}
variable "dev_network" {
}
variable "snapshot" {
}
variable "snapshot_name" {
}
variable "folder" {
}
variable "ref_folder" {
}
variable "base_folder" {
}
variable "appvolserver" {
}
variable "demserver" {
}
# variable "host" {
# }
# variable "resource_pool" {
#   default = "Normal Resource Pool"
# }