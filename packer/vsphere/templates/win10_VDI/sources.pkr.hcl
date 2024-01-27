source "vsphere-iso" "win10_base" {
  #vm_name = "Win10_Base_22H2_23.06a"
  vm_name = "${local.base_vm_name}${local.version}${local.build_name}"

  convert_to_template = true
  create_snapshot     = var.snapshot
  snapshot_name       = var.snapshot_name
  guest_os_type       = var.guest_os_type

  username            = var.username
  password            = var.password
  insecure_connection = var.insecure_connection

  vcenter_server = var.vcenter_server
  datacenter     = var.datacenter
  cluster        = var.cluster
  datastore      = var.datastore
  folder         = var.base_folder
  #resource_pool = var.resource_pool

  CPUs                 = var.cpu
  cpu_cores            = var.cpu_cores
  RAM                  = var.ram
  video_ram            = var.video_ram
  disk_controller_type = [var.disk_controller.lsilogic, var.disk_controller.lsilogic] #pvscsi
  storage {
    disk_size             = var.disk
    disk_thin_provisioned = true
    disk_controller_index = 0
  }

  network_adapters {
    #mac_address = var.mac_address.win10
    network      = var.network
    network_card = var.network_card
    passthrough  = false
  }

  floppy_files = [
    "boot/unattend/vdi/win10/AutoUnattend.xml",
    "boot/init/Install-VMtools_VDI.ps1",
    "boot/init/Enable-WinRM.ps1",
    #"boot/init/Enable-WinRMs.ps1",
    "boot/init/Set-LocalAdmin.ps1"
  ]
  floppy_dirs = ["boot/drivers"]
  //requires oscdimg on the system running packer.
  cd_files = ["./iso/*"]
  iso_paths = [
    var.win10_iso,
    #var.horizon_iso
  ]
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
  #   options = ["extraconfig"]
  # }
}
source "vsphere-iso" "win11_base" {
  vm_name = "Win11_Base_23H2_${local.version}${local.build_name}"

  convert_to_template = true
  create_snapshot     = var.snapshot
  snapshot_name       = var.snapshot_name
  guest_os_type       = var.guest_os_type

  username            = var.username
  password            = var.password
  insecure_connection = var.insecure_connection

  vcenter_server = var.vcenter_server
  datacenter     = var.datacenter
  cluster        = var.cluster
  datastore      = var.datastore
  folder         = var.base_folder

  CPUs                 = var.cpu
  cpu_cores            = var.cpu_cores
  RAM                  = 8192
  video_ram            = var.video_ram
  disk_controller_type = [var.disk_controller.pvscsi, var.disk_controller.pvscsi] #lsilogic
  storage {
    disk_size             = var.disk
    disk_thin_provisioned = true
    disk_controller_index = 0
  }

  network_adapters {
    #mac_address = var.mac_address.win10
    network      = var.network
    network_card = var.network_card
    passthrough  = false
  }

  floppy_files = [
    "boot/unattend/vdi/win11/AutoUnattend.xml",
    "boot/init/Install-VMtools_VDI.ps1",
    "boot/init/Enable-WinRM.ps1",
    "boot/init/Set-LocalAdmin.ps1"
  ]
  floppy_dirs = ["boot/drivers"]
  //requires oscdimg on the system running packer.
  cd_files = ["./iso/*"]
  iso_paths = [
    var.win11_iso,
    #var.horizon_iso
  ]
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
  #   options = ["extraconfig"]
  # }
}
source "vsphere-iso" "win10_ref" {
  #vm_name = "REF-TEMPLATE-23.06a"
  vm_name = "${local.ref_vm_name}${local.version}${local.build_name}"

  convert_to_template = true
  create_snapshot     = var.snapshot
  snapshot_name       = var.snapshot_name
  guest_os_type       = var.guest_os_type

  username            = var.username
  password            = var.password
  insecure_connection = var.insecure_connection

  vcenter_server = var.vcenter_server
  datacenter     = var.datacenter
  cluster        = var.cluster
  datastore      = var.datastore
  folder         = var.ref_folder

  CPUs                 = var.cpu
  cpu_cores            = var.cpu_cores
  RAM                  = var.ram
  video_ram            = var.video_ram
  disk_controller_type = [var.disk_controller.lsilogic] #pvscsi
  storage {
    disk_size             = var.disk
    disk_thin_provisioned = true
    disk_controller_index = 0
  }

  network_adapters {
    network      = var.network
    network_card = var.network_card
    passthrough  = false
  }

  floppy_files = [
    "boot/unattend/vdi/win10/AutoUnattend.xml",
    "boot/init/Install-VMtools_VDI.ps1",
    "boot/init/Enable-WinRM.ps1",
    #"boot/init/Enable-WinRMs.ps1",
    "boot/init/Set-LocalAdmin.ps1"
  ]
  floppy_dirs = ["boot/drivers"]
  cd_files    = ["./iso/*"]
  iso_paths = [
    var.win10_iso,
    #var.horizon_iso
  ]
  remove_cdrom = true

  configuration_parameters = {
    "devices.hotplug" : "false"
    "svga.numDisplays" : "2"
  }

  notes = "Created: ${formatdate("MMM.DD.YYYY", timeadd(timestamp(), "-8h"))}"

  communicator      = "winrm"
  winrm_username    = var.winrm_username
  winrm_password    = var.winrm_password
  winrm_use_ssl     = var.winrm_use_ssl
  winrm_insecure    = var.winrm_insecure
  winrm_timeout     = "20m"
  ip_settle_timeout = "2m"

  shutdown_command = "cmd.exe /c schtasks /run /tn packer-shutdown /i"
  shutdown_timeout = "45m"

  # export {
  #   output_directory = "./output"
  # }
}
source "vsphere-iso" "win10_dev" {
  vm_name = "${local.dev_temp_name}${local.version}${local.build_name}"

  convert_to_template = true
  create_snapshot     = false
  snapshot_name       = null
  guest_os_type       = var.guest_os_type

  username            = var.username
  password            = var.password
  insecure_connection = var.insecure_connection

  vcenter_server = var.vcenter_server
  datacenter     = var.datacenter
  cluster        = var.cluster
  datastore      = var.datastore
  folder         = var.base_folder

  CPUs                 = 4
  cpu_cores            = 4
  RAM                  = 10240
  video_ram            = var.video_ram
  disk_controller_type = [var.disk_controller.lsilogic] #pvscsi
  storage {
      disk_size             = 131072
      disk_thin_provisioned = true
      disk_controller_index = 0
  }
  storage {
      disk_size             = 131072
      disk_thin_provisioned = true
      disk_controller_index = 0
  }
  
  network_adapters {
    network      = var.dev_network
    network_card = var.network_card
    passthrough  = false
  }

  floppy_files = [
    "boot/unattend/vdi/win10/AutoUnattend.xml",
    "boot/init/Install-VMtools_VDI.ps1",
    "boot/init/Enable-WinRM.ps1",
    #"boot/init/Enable-WinRMs.ps1",
    "boot/init/Set-LocalAdmin.ps1"
  ]
  floppy_dirs = ["boot/drivers"]
  cd_files    = ["./iso/*"]
  iso_paths = [
    var.win10_iso,
    #var.horizon_iso
  ]
  remove_cdrom = true

  configuration_parameters = {
    "devices.hotplug" : "false"
    "svga.numDisplays" : "2"
  }

  notes = "Created: ${formatdate("MMM.DD.YYYY", timeadd(timestamp(), "-8h"))}"

  communicator      = "winrm"
  winrm_username    = var.winrm_username
  winrm_password    = var.winrm_password
  winrm_use_ssl     = var.winrm_use_ssl
  winrm_insecure    = var.winrm_insecure
  winrm_timeout     = "20m"
  ip_settle_timeout = "2m"

  shutdown_command = "cmd.exe /c schtasks /run /tn packer-shutdown /i"
  shutdown_timeout = "45m"

  # export {
  #   output_directory = "./output"
  # }
}