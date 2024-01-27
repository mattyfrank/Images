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
#Convert Packer VM to Template
variable "convert_to_template" {
  type    = bool
  default = true
}
##Build specific vars
variable "vm_name" {
  type = map(string)
  default = {
    win10 = "win10_22H2"
    win11 = "win11_22H2"
    srv19 = "winsrv2019"
    srv22 = "winsrv2022"
  }
}
variable "guest_os_type" {
  type = map(string)
  default = {
    win_os = "windows9_64Guest"
    srv_os = "windows9Server64Guest"
  }
}
variable "disk" {
  type = map(number)
  default = {
    win_disk = "51200"
    srv_disk = "102400"
  }
}
variable "disk_controller" {
  type = map(string)
  default = {
    pvscsi   = "pvscsi"
    lsilogic = "lsilogic-sas"
  }
}
variable "cpu" {
  type = map(number)
  default = {
    win_cpu = 2
    srv_cpu = 4
  }
}
variable "cpu_cores" {
  type    = number
  default = 2
}
variable "ram" {
  type = map(number)
  default = {
    win_ram = 6144
    srv_ram = 16384
  }
}
variable "video_ram" {
  type = map(number)
  default = {
    win_vid = 79872
    srv_vid = 102400
  }
}
variable "network_card" {
  type    = string
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
variable "folder" {
}
variable "network" {
}
variable "snapshot" {
}
variable "snapshot_name" {
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