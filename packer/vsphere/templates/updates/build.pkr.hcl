//Install Windows into VM, Run Windows Updates, Run Cleanup, Convert to template, or Export OVF.
packer {
  required_plugins {
    vsphere = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/vsphere"
    }
    windows-update = {
      version = "0.14.3"
      source  = "github.com/rgl/windows-update"
    }
  }
}
locals {
  date      = formatdate("YYYY.MMM.D", timeadd(timestamp(), "-8h"))
  date_time = formatdate("YYMMDD_hh.mm.ss", timeadd(timestamp(), "-8h"))
}
#WindowsServer2019
build {
  name = "srv2019"
  sources = [
    "source.vsphere-iso.srv2019"
  ]
  provisioner "powershell" {
    inline       = ["Write-Output 'PWSH Restart:' $(Get-Date); Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true"
    ]
    update_limit = 25
  }
  provisioner "powershell" {
    inline       = ["Write-Output 'PWSH Restart:' $(Get-Date); Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  } //pause for 10 mins to allow windows updates to complete. 
  provisioner "powershell" {
    script       = "provisioners/Cleanup-Disk.ps1"
    pause_before = "10m"
  }
  provisioner "powershell" {
    inline       = ["Write-Output \"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "powershell" {
    script       = "provisioners/Cleanup-ScheduledTask.ps1"
    pause_before = "30s"
  }
  post-processor "manifest" {
    output = "manifests/manifest-${var.vm_name.srv19}-${local.date_time}.json"
  }
}
#WindowsServer2022
build {
  name = "srv2022"
  sources = [
    "source.vsphere-iso.srv2022"
  ]
  provisioner "powershell" {
    inline       = ["Write-Output 'PWSH Restart:' $(Get-Date); Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true"
    ]
    update_limit = 25
  }
  provisioner "powershell" {
    inline       = ["Write-Output 'PWSH Restart:' $(Get-Date); Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  } //pause for 10 mins to allow windows updates to complete. 
  provisioner "powershell" {
    script       = "provisioners/Cleanup-Disk.ps1"
    pause_before = "10m"
  }
  provisioner "powershell" {
    inline       = ["Write-Output \"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "powershell" {
    script       = "provisioners/Cleanup-ScheduledTask.ps1"
    pause_before = "30s"
  }
  post-processor "manifest" {
    output = "manifests/manifest-${var.vm_name.srv22}-${local.date_time}.json"
  }
}
#Windows10
build {
  name = "win10"
  sources = [
    "source.vsphere-iso.win10"
  ]
  provisioner "powershell" {
    inline       = ["Write-Output \"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true"
    ]
    update_limit = 25
  }
  provisioner "powershell" {
    inline       = ["Write-Output \"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "powershell" {
    script       = "provisioners/Cleanup-Disk.ps1"
    pause_before = "5m"
  }
  provisioner "powershell" {
    inline       = ["Write-Output \"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "powershell" {
    script       = "provisioners/Cleanup-ScheduledTask.ps1"
    pause_before = "30s"
  }
  post-processor "manifest" {
    output = "manifests/manifest-${var.vm_name.win10}-${local.date_time}.json"
  }
}
#Windows11
build {
  name = "win11"
  sources = [
    "source.vsphere-iso.win11"
  ]
  provisioner "powershell" {
    inline       = ["Write-Output \"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true"
    ]
    update_limit = 25
  }
  provisioner "powershell" {
    inline       = ["Write-Output \"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "powershell" {
    script       = "provisioners/Cleanup-Disk.ps1"
    pause_before = "5m"
  }
  provisioner "powershell" {
    inline       = ["Write-Output \"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "powershell" {
    script       = "provisioners/Cleanup-ScheduledTask.ps1"
    pause_before = "30s"
  }
  post-processor "manifest" {
    output = "manifests/manifest-${var.vm_name.win11}-${local.date_time}.json"
  }
}