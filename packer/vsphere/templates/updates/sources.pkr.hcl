source "vsphere-iso" "srv2019" {
  vm_name             = "${var.vm_name.srv19}-${local.date}"
  guest_os_type       = var.guest_os_type.srv_os
  convert_to_template = var.convert_to_template

  username            = var.username
  password            = var.password
  insecure_connection = var.insecure_connection

  vcenter_server = var.vcenter_server
  datacenter     = var.datacenter
  cluster        = var.cluster
  datastore      = var.datastore
  folder         = var.folder
  #resource_pool = var.resource_pool

  CPUs                 = var.cpu.srv_cpu
  cpu_cores            = var.cpu_cores
  RAM                  = var.ram.srv_ram
  video_ram            = var.video_ram.srv_vid
  disk_controller_type = [var.disk_controller.pvscsi]
  storage {
    disk_size             = var.disk.srv_disk
    disk_thin_provisioned = true
  }

  network_adapters {
    #mac_address = var.mac_address.srv2019
    network      = var.network
    network_card = var.network_card
    passthrough  = false
  }

  floppy_files = [
    "boot/unattend/oobe/srv2019/AutoUnattend.xml",
    "boot/init/Install-VMtools.ps1",
    "boot/init/Enable-WinRM.ps1",
    "boot/init/Set-LocalAdmin.ps1"
  ]
  floppy_dirs = ["boot/drivers"]
  iso_paths   = [var.srv2019_iso]
  //requires oscdimg on the system running packer.
  cd_files = ["iso/sdelete64.exe", "iso/VVMware-tools-12.3.5-22544099-x86_64.exe"]

  //Remove CDROM 
  remove_cdrom = true

  //Advanced Settings
  configuration_parameters = {
    "devices.hotplug" : "false"
    "svga.numDisplays" : "2"
  }

  notes = "Created: ${formatdate("MMM.DD.YYYY", timeadd(timestamp(), "-8h"))}"

  //https://www.packer.io/docs/communicators/winrm#configuring-winrm-in-vmware
  communicator      = "winrm"
  winrm_username    = var.winrm_username
  winrm_password    = var.winrm_password
  winrm_use_ssl     = var.winrm_use_ssl
  winrm_insecure    = var.winrm_insecure
  winrm_timeout     = "20m"
  ip_settle_timeout = "2m"

  #shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Image Ready\""
  shutdown_command = "cmd.exe /c schtasks /run /tn packer-shutdown /i"
  shutdown_timeout = "45m"

  # export {
  #   output_directory = "./output"
  # }
}
source "vsphere-iso" "srv2022" {
  vm_name             = "${var.vm_name.srv22}-${local.date}"
  guest_os_type       = var.guest_os_type.srv_os
  convert_to_template = var.convert_to_template

  username            = var.username
  password            = var.password
  insecure_connection = var.insecure_connection

  vcenter_server = var.vcenter_server
  datacenter     = var.datacenter
  cluster        = var.cluster
  datastore      = var.datastore
  folder         = var.folder
  #resource_pool = var.resource_pool

  CPUs                 = var.cpu.srv_cpu
  cpu_cores            = var.cpu_cores
  RAM                  = var.ram.srv_ram
  video_ram            = var.video_ram.srv_vid
  disk_controller_type = [var.disk_controller.pvscsi]
  storage {
    disk_size             = var.disk.srv_disk
    disk_thin_provisioned = true
  }

  network_adapters {
    #mac_address = var.mac_address.srv2022
    network      = var.network
    network_card = var.network_card
    passthrough  = false
  }

  floppy_files = [
    "boot/unattend/oobe/srv2022/AutoUnattend.xml",
    "boot/init/Install-VMtools.ps1",
    "boot/init/Enable-WinRM.ps1",
    "boot/init/Set-LocalAdmin.ps1"
  ]
  floppy_dirs = ["boot/drivers"]
  iso_paths   = [var.srv2022_iso]
  //requires oscdimg on the system running packer.
  cd_files = ["iso/sdelete64.exe", "iso/VMware-tools-12.3.5-22544099-x86_64.exe"]

  //Remove CDROM 
  remove_cdrom = true

  //Advanced Settings
  configuration_parameters = {
    "devices.hotplug" : "false"
    "svga.numDisplays" : "2"
  }

  notes = "Created: ${formatdate("MMM.DD.YYYY", timeadd(timestamp(), "-8h"))}"

  //https://www.packer.io/docs/communicators/winrm#configuring-winrm-in-vmware
  communicator      = "winrm"
  winrm_username    = var.winrm_username
  winrm_password    = var.winrm_password
  winrm_use_ssl     = var.winrm_use_ssl
  winrm_insecure    = var.winrm_insecure
  winrm_timeout     = "20m"
  ip_settle_timeout = "2m"

  #shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Image Ready\""
  shutdown_command = "cmd.exe /c schtasks /run /tn packer-shutdown /i"
  shutdown_timeout = "45m"

  # export {
  #   output_directory = "./output"
  # }
}
source "vsphere-iso" "win10" {
  vm_name             = "${var.vm_name.win10}-${local.date}"
  guest_os_type       = var.guest_os_type.win_os
  convert_to_template = var.convert_to_template

  username            = var.username
  password            = var.password
  insecure_connection = var.insecure_connection

  vcenter_server = var.vcenter_server
  datacenter     = var.datacenter
  cluster        = var.cluster
  datastore      = var.datastore
  folder         = var.folder
  #resource_pool = var.resource_pool

  CPUs                 = var.cpu.win_cpu
  cpu_cores            = var.cpu_cores
  RAM                  = var.ram.win_ram
  video_ram            = var.video_ram.win_vid
  disk_controller_type = [var.disk_controller.pvscsi]
  storage {
    disk_size             = var.disk.win_disk
    disk_thin_provisioned = true
  }

  network_adapters {
    #mac_address = var.mac_address.win10
    network      = var.network
    network_card = var.network_card
    passthrough  = false
  }

  floppy_files = [
    "boot/unattend/oobe/win10/AutoUnattend.xml",
    "boot/init/Install-VMtools.ps1",
    "boot/init/Enable-WinRM.ps1",
    "boot/init/Set-LocalAdmin.ps1"
  ]
  floppy_dirs = ["boot/drivers"]
  iso_paths   = [var.win10_iso]
  //requires oscdimg on the system running packer.
  cd_files = ["iso/sdelete64.exe", "iso/VMware-tools-12.3.5-22544099-x86_64.exe"]

  #remove cdrom 
  remove_cdrom = true

  #Advanced Settings
  configuration_parameters = {
    "devices.hotplug" : "false"
    "svga.numDisplays" : "2"
  }

  notes = "Created: ${formatdate("MMM.DD.YYYY", timeadd(timestamp(), "-8h"))}"

  //https://www.packer.io/docs/communicators/winrm#configuring-winrm-in-vmware
  communicator      = "winrm"
  winrm_username    = var.winrm_username
  winrm_password    = var.winrm_password
  winrm_use_ssl     = var.winrm_use_ssl
  winrm_insecure    = var.winrm_insecure
  winrm_timeout     = "20m"
  ip_settle_timeout = "2m"

  #shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Image Ready\""
  shutdown_command = "cmd.exe /c schtasks /run /tn packer-shutdown /i"
  shutdown_timeout = "45m"

  # export {
  #   output_directory = "./output"
  # }
}
source "vsphere-iso" "win11" {
  vm_name             = "${var.vm_name.win11}-${local.date}"
  guest_os_type       = var.guest_os_type.win_os
  convert_to_template = var.convert_to_template

  username            = var.username
  password            = var.password
  insecure_connection = var.insecure_connection

  vcenter_server = var.vcenter_server
  datacenter     = var.datacenter
  cluster        = var.cluster
  datastore      = var.datastore
  folder         = var.folder
  #resource_pool = var.resource_pool

  CPUs                 = var.cpu.win_cpu
  cpu_cores            = var.cpu_cores
  RAM                  = var.ram.win_ram
  video_ram            = var.video_ram.win_vid
  disk_controller_type = [var.disk_controller.pvscsi]
  storage {
    disk_size             = var.disk.win_disk
    disk_thin_provisioned = true
  }

  network_adapters {
    #mac_address = var.mac_address.win11
    network      = var.network
    network_card = var.network_card
    passthrough  = false
  }

  floppy_files = [
    "boot/unattend/oobe/win11/AutoUnattend.xml",
    "boot/init/Install-VMtools.ps1",
    "boot/init/Enable-WinRM.ps1",
    "boot/init/Set-LocalAdmin.ps1"
  ]
  floppy_dirs = ["boot/drivers"]
  iso_paths   = [var.win11_iso]
  //requires oscdimg on the system running packer.
  cd_files = ["iso/sdelete64.exe", "iso/LGPO.exe", "iso/VMware-tools-12.3.5-22544099-x86_64.exe"]

  #remove cdrom 
  remove_cdrom = true

  #Advanced Settings
  configuration_parameters = {
    "devices.hotplug" : "false"
    "svga.numDisplays" : "2"
  }

  notes = "Created: ${formatdate("MMM.DD.YYYY", timeadd(timestamp(), "-8h"))}"

  //https://www.packer.io/docs/communicators/winrm#configuring-winrm-in-vmware
  communicator      = "winrm"
  winrm_username    = var.winrm_username
  winrm_password    = var.winrm_password
  winrm_use_ssl     = var.winrm_use_ssl
  winrm_insecure    = var.winrm_insecure
  winrm_timeout     = "20m"
  ip_settle_timeout = "2m"

  #shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Image Ready\""
  shutdown_command = "cmd.exe /c schtasks /run /tn packer-shutdown /i"
  shutdown_timeout = "45m"

  # export {
  #   output_directory = "./output"
  # }
}

