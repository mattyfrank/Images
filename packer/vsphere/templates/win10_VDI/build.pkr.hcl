//Two Builds Golden Image and Reference Template
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
//Use LocalVars as Parameters for InLine Provisioners. Provisioner must be local to GuestOS to accept params.
locals {
  build_name    = "A"
  base_vm_name  = "Win10_Base_22H2_"
  ref_vm_name   = "REF-TEMPLATE-"
  dev_temp_name = "VDI-DEV-IMG-"
  version       = formatdate("YY.MM", timeadd(timestamp(), "-8h"))
  time          = formatdate("YYMMDD_hh.mm.ss", timeadd(timestamp(), "-8h"))
  osot          = "E:\\Optimize\\VMwareHorizonOSOptimizationTool-x86_64-1.2.2303.21510536.exe"
  template2     = "E:\\Optimize\\OSOT_Config_22.12.xml"
  template1     = "E:\\Optimize\\Windows 10, 11 and Server 2019, 2022.xml"
  answer_file   = "E:\\Optimize\\answer_file.xml"
  appvol_agent  = "E:\\App_Volumes_Agent_2306.msi"
  horizon_agent = "E:\\VMware-Horizon-Agent-x86_64-2306-8.10.0-22012512.exe"
  dem_agent     = "E:\\VMware Dynamic Environment Manager Enterprise 2306 10.10 x64.msi"
  dem_profiler  = "E:\\VMware DEM Application Profiler 2206 10.6 x64.msi"
}
//Base Image
build {
  name = "win10_base"
  sources = [
    "source.vsphere-iso.win10_base"
  ]
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true"
    ]
    update_limit = 25
  }
  //wait 5 min for winupdate to complete.
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "5m"
  }
  //Enter Audit Mode
  provisioner "windows-shell" {
    inline       = ["%WINDIR%\\System32\\Sysprep\\sysprep.exe /audit /reboot"]
    pause_before = "5m"
  }
  provisioner "powershell" {
    scripts = [
      "provisioners/VDI/Configure-Image.ps1",
      "provisioners/VDI/Update-Edge.ps1",
      "provisioners/VDI/Install-WebView2.ps1",
      "provisioners/VDI/Configure-Edge.ps1"
    ]
    pause_before = "30s"
  }
  //Update MS Store (first time)
  provisioner "powershell" {
    inline = [
      "E:\\Update-MicrosoftStore.ps1 -Wait 600"
    ]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force; Write-Output `n\"Update MS Store (Second Time)...\""]
    pause_before = "30s"
  }
  //Update store a second time. 
  provisioner "powershell" {
    inline = [
      "E:\\Update-MicrosoftStore.ps1 -Wait 300"
    ]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline = [
      "Write-Output \"Install Horizon Apps in ${var.datacenter}\"",
      "E:\\Install-HorizonAgents.ps1 -HorizonInstaller \"${local.horizon_agent}\" -DEMinstaller \"${local.dem_agent}\" -AppVolInstaller \"${local.appvol_agent}\" -AppVolServer \"${var.appvolserver}\" -DEMServer \"${var.demserver}\""
    ]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "powershell" {
    script       = "provisioners/VDI/Set-SvDriverWhiteList.ps1"
    pause_before = "5s"
  }
  //Shutdown without Optimization
  /*
    provisioner "powershell" {
      inline       = ["Write-Output \"PWSH Shutdown: $(Get-Date -f hh:mm:ss)\"; cmd.exe /c shutdown /s /t 5"]
      pause_before = "30s"
  }
  */
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start PreOptimize $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "Write-Output \"Optimizer Template: ${local.template1}\"",
      "Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-o -t `\"${local.template1}`\" -notification enable -storeapp remove-all --exclude ScreenSketch Calculator StickyNotes Photos -v\" -Wait -PassThru -RedirectStandardOutput C:\\Temp\\Pre-Optimize.log",
      "Write-Output \"End PreOptimize $(Get-Date)\""
    ] #"Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-o -t `\"${local.template1}`\" -notification enable -storeapp remove-all --exclude ScreenSketch Calculator StickyNotes Photos -v > C:\\Temp\\Pre-Optimize.log 2>&1\" -Wait -PassThru",
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start Optimize $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "Write-Output \"Optimizer Template: ${local.template2}\"",
      "Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-o -v -t `\"${local.template2}`\"\" -Wait -PassThru -RedirectStandardOutput C:\\Temp\\Optimize.log",
      "Write-Output \"End Optimize $(Get-Date)\""
    ] #"Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-o -t `\"${local.template2}`\" -v > C:\\Temp\\Optimize.log 2>&1\" -Wait -PassThru",
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  //reboot command in generalize script
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start Generalize $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "Write-Output \"Sysprep Answer File: ${local.osot}\"",
      "Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-g `\"${local.answer_file}`\" -v\" -Wait -PassThru -RedirectStandardOutput C:\\Temp\\Generalize.log",
      "Write-Output \"End Generalize $(Get-Date)\"",
      "Write-Output  \"Restart: $(Get-Date -f hh:mm:ss)\"",
      "shutdown /r /t 5"
    ] #"Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-g `\"${local.answer_file}`\" -v > C:\\Temp\\Generalize.log 2>&1\" -Wait -PassThru",
    pause_before = "30s"
  }
  //after generalize extend restart-timeout to 10 minutes.
  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {Write-Output `n\"Restarted: $(Get-Date -f hh:mm:ss)\"}\""
    restart_timeout       = "10m"
  }
  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {Write-Output `n\"Restarted: $(Get-Date -f hh:mm:ss)\"}\""
    restart_timeout       = "5m"
  }
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start OptimizePostGeneralize $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "Write-Output \"Optimizer Template: ${local.template2}\"",
      "Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-o -v -t `\"${local.template2}`\"\" -Wait -PassThru -RedirectStandardOutput C:\\Temp\\OptimizePostGen.log",
      "Write-Output \"End OptimizePostGeneralize $(Get-Date)\""
    ] #"Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-o -t `\"${local.template2}`\" -v > C:\\Temp\\OptimizePostGen.log 2>&1\" -Wait -PassThru",
    pause_before = "1m"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start Finalized_ScheduledTask $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "& E:\\Optimize\\Finalized_ScheduledTask.ps1 -optimizer \"${local.osot}\"",
      "Write-Output \"End Finalized_ScheduledTask $(Get-Date)\""
    ]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"Provisioning Completed: $(Get-Date -f hh:mm:ss) `nWait (up to 45 minutes) for finalized scheduled task to complete...\""]
    pause_before = "30s"
  }
  post-processors {
  /*     
  post-processor "vsphere" {
      vm_name             = "${local.base_vm_name}${local.version}${local.build_name}"
      host                = var.vcenter_server
      username            = var.username
      password            = var.password
      datacenter          = var.datacenter
      cluster             = var.cluster
      datastore           = var.datastore
      vm_network          = var.network
      keep_input_artifact = true
    } 
    */
    post-processor "manifest" {
      output = "manifests/${local.base_vm_name}${local.time}.json"
    }
  }
}
//Base Image (Win11)
build {
  name = "win11_base"
  sources = [
    "source.vsphere-iso.win11_base"
  ]
  provisioner "powershell" {
    inline       = ["Write-Output `n\"Set Windows Power Plan to High Performance\"; powercfg.exe -SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"]
    pause_before = "1m"
  }
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true"
    ]
    update_limit = 25
  }
  //wait 5 min for winupdate to complete.
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "5m"
  }
  //Enter Audit Mode
  provisioner "windows-shell" {
    inline       = ["%WINDIR%\\System32\\Sysprep\\sysprep.exe /audit /reboot"]
    pause_before = "5m"
  }
  provisioner "powershell" {
    scripts = [
      "provisioners/VDI/Configure-Image.ps1",
      "provisioners/VDI/Update-Edge.ps1",
      "provisioners/VDI/Configure-Edge.ps1"
    ]
    pause_before = "30s"
  }
  //Update MS Store (first time)
  provisioner "powershell" {
    inline = [
      "E:\\Update-MicrosoftStore.ps1 -Wait 600"
    ]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force; Write-Output `n\"Update MS Store (Second Time)...\""]
    pause_before = "30s"
  }
  //Update store a second time. 
  provisioner "powershell" {
    inline = [
      "E:\\Update-MicrosoftStore.ps1 -Wait 300"
    ]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline = [
      "Write-Output \"Install Horizon Apps in ${var.datacenter}\"",
      "E:\\Install-HorizonAgents.ps1 -HorizonInstaller \"${local.horizon_agent}\" -DEMinstaller \"${local.dem_agent}\" -AppVolInstaller \"${local.appvol_agent}\" -AppVolServer \"${var.appvolserver}\" -DEMServer \"${var.demserver}\""
    ]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "powershell" {
    script       = "provisioners/VDI/Set-SvDriverWhiteList.ps1"
    pause_before = "5s"
  }
  # //Shutdown without Optimization
  #   provisioner "powershell" {
  #     inline       = ["Write-Output \"PWSH Shutdown: $(Get-Date -f hh:mm:ss)\"; cmd.exe /c shutdown /s /t 5"]
  #     pause_before = "30s"
  # }
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start PreOptimize $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "Write-Output \"Optimizer Template: ${local.template1}\"",
      "Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-o -t `\"${local.template1}`\" -notification enable -storeapp remove-all --exclude ScreenSketch Calculator StickyNotes Photos -v\" -Wait -PassThru -RedirectStandardOutput C:\\Temp\\Pre-Optimize.log",
      "Write-Output \"End PreOptimize $(Get-Date)\""
    ]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start Optimize $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "Write-Output \"Optimizer Template: ${local.template2}\"",
      "Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-o -v -t `\"${local.template2}`\"\" -Wait -PassThru -RedirectStandardOutput C:\\Temp\\Optimize.log",
      "Write-Output \"End Optimize $(Get-Date)\""
    ]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  //reboot command in generalize script
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start Generalize $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "Write-Output \"Sysprep Answer File: ${local.osot}\"",
      "Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-g `\"${local.answer_file}`\" -v\" -Wait -PassThru -RedirectStandardOutput C:\\Temp\\Generalize.log",
      "Write-Output \"End Generalize $(Get-Date)\"",
      "Write-Output  \"Restart: $(Get-Date -f hh:mm:ss)\"",
      "shutdown /r /t 5"
    ]
    pause_before = "30s"
  }
  //after generalize extend restart-timeout to 10 minutes.
  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {Write-Output `n\"Restarted: $(Get-Date -f hh:mm:ss)\"}\""
    restart_timeout       = "10m"
  }
  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {Write-Output `n\"Restarted: $(Get-Date -f hh:mm:ss)\"}\""
    restart_timeout       = "5m"
  }
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start OptimizePostGeneralize $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "Write-Output \"Optimizer Template: ${local.template2}\"",
      "Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-o -v -t `\"${local.template2}`\"\" -Wait -PassThru -RedirectStandardOutput C:\\Temp\\OptimizePostGen.log",
      "Write-Output \"End OptimizePostGeneralize $(Get-Date)\""
    ]
    pause_before = "1m"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start Finalized_ScheduledTask $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "& E:\\Optimize\\Finalized_ScheduledTask.ps1 -optimizer \"${local.osot}\"",
      "Write-Output \"End Finalized_ScheduledTask $(Get-Date)\""
    ]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"Provisioning Completed: $(Get-Date -f hh:mm:ss) `nWait (up to 45 minutes) for finalized scheduled task to complete...\""]
    pause_before = "30s"
  }
  post-processors {
    post-processor "manifest" {
      output = "manifests/${local.base_vm_name}${local.time}.json"
    }
  }
}
//Reference VMs
build {
  name = "win10_ref"
  sources = [
    "source.vsphere-iso.win10_ref"
  ]
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true"
    ]
    update_limit = 25
  }
  //wait 5 min for winupdate to complete.
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "5m"
  }
  //Enter Audit Mode
  provisioner "windows-shell" {
    inline       = ["%WINDIR%\\System32\\Sysprep\\sysprep.exe /audit /reboot"]
    pause_before = "5m"
  }
  provisioner "powershell" {
    scripts = [
      "provisioners/VDI/Configure-Image.ps1",
      "provisioners/VDI/Update-Edge.ps1",
      "provisioners/VDI/Install-WebView2.ps1",
      "provisioners/VDI/Configure-Edge.ps1"
    ]
    pause_before = "30s"
  }
  //Update MS Store (first time)
  provisioner "powershell" {
    inline = [
      "E:\\Update-MicrosoftStore.ps1 -Wait 600"
    ]
    pause_before = "30s"
  }  
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force; Write-Output `n\"Update MS Store (Second Time)...\""]
    pause_before = "30s"
  }
  //Update store a second time. 
  provisioner "powershell" {
    inline = [
      "E:\\Update-MicrosoftStore.ps1 -Wait 300"
    ]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  //Copy Files to RefVM
  provisioner "powershell" {
    inline = [
      "Copy-Item -Path E:\\Join-Domain.ps1 -Destination C:\\Temp",
      "Copy-Item -Path E:\\New-AppPackage_Wrapper.ps1 -Destination C:\\Temp"
    ]
  }
  provisioner "powershell" {
    inline = [
      "Write-Output \"Install Horizon Apps in ${var.datacenter}\"",
      "E:\\Install-Horizon_ReferenceImage.ps1 -AppVolInstaller \"${local.appvol_agent}\" -AppVolServer \"${var.appvolserver}\" -DEMprofiler \"${local.dem_profiler}\""
    ]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "powershell" {
    script       = "provisioners/VDI/Set-SvDriverWhiteList.ps1"
    pause_before = "5s"
  }
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start PreOptimize $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "Write-Output \"Optimizer Template: ${local.template1}\"",
      "Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-o -t `\"${local.template1}`\" -notification enable -storeapp remove-all --exclude ScreenSketch Calculator StickyNotes Photos -v\" -Wait -PassThru -RedirectStandardOutput C:\\Temp\\Pre-Optimize.log",
      "Write-Output \"End PreOptimize $(Get-Date)\""
    ] #"Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-o -t `\"${local.template1}`\" -notification enable -storeapp remove-all --exclude ScreenSketch Calculator StickyNotes Photos -v > C:\\Temp\\Pre-Optimize.log 2>&1\" -Wait -PassThru",
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  //Shutdown without Optimization
  /*
    provisioner "powershell" {
      inline       = ["Write-Output \"PWSH Shutdown: $(Get-Date -f hh:mm:ss)\"; cmd.exe /c shutdown /s /t 5"]
      pause_before = "30s"
  }*/
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start Optimize $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "Write-Output \"Optimizer Template: ${local.template2}\"",
      "Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-o -v -t `\"${local.template2}`\"\" -Wait -PassThru -RedirectStandardOutput C:\\Temp\\Optimize.log",
      "Write-Output \"End Optimize $(Get-Date)\""
    ] #"Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-o -t `\"${local.template2}`\" -v > C:\\Temp\\Optimize.log 2>&1\" -Wait -PassThru",
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  //reboot command in generalize script
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start Generalize $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "Write-Output \"Sysprep Answer File: ${local.osot}\"",
      "Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-g `\"${local.answer_file}`\" -v\" -Wait -PassThru -RedirectStandardOutput C:\\Temp\\Generalize.log",
      "Write-Output \"End Generalize $(Get-Date)\"",
      "Write-Output  \"Restart: $(Get-Date -f hh:mm:ss)\"",
      "shutdown /r /t 5"
    ] #"Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-g `\"${local.answer_file}`\" -v > C:\\Temp\\Generalize.log 2>&1\" -Wait -PassThru",
    pause_before = "30s"
  }
  //after generalize extend restart-timeout to 10 minutes.
  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {Write-Output `n\"Restarted: $(Get-Date -f hh:mm:ss)\"}\""
    restart_timeout       = "10m"
  }
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start OptimizePostGeneralize $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "Write-Output \"Optimizer Template: ${local.template2}\"",
      "Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-o -v -t `\"${local.template2}`\"\" -Wait -PassThru -RedirectStandardOutput C:\\Temp\\OptimizePostGen.log",
      "Write-Output \"End OptimizePostGeneralize $(Get-Date)\""
    ] #"Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-o -t `\"${local.template2}`\" -v > C:\\Temp\\OptimizePostGen.log 2>&1\" -Wait -PassThru",
    pause_before = "1m"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start Finalized_ScheduledTask $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "& E:\\Optimize\\Finalized_ScheduledTask.ps1 -optimizer \"${local.osot}\"",
      "Write-Output \"End Finalized_ScheduledTask $(Get-Date)\""
    ]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"Provisioning Completed: $(Get-Date -f hh:mm:ss) `nWait (up to 45 minutes) for finalized scheduled task to complete...\""]
    pause_before = "30s"
  }
  post-processor "manifest" {
    output = "manifests/${local.ref_vm_name}${local.time}.json"
  }

}
//Dedicated VMs Template
build {
  name = "win10_dev"
  sources = [
    "source.vsphere-iso.win10_dev"
  ]
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true"
    ]
    update_limit = 25
  }
  //wait 5 min for winupdate to complete.
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "5m"
  }
  //Enter Audit Mode
  provisioner "windows-shell" {
    inline       = ["%WINDIR%\\System32\\Sysprep\\sysprep.exe /audit /reboot"]
    pause_before = "2m"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "powershell" {
    scripts = [

      "provisioners/VDI/Update-Edge.ps1"
    ]
    pause_before = "30s"
  }
  //Install Horizon Agent
  provisioner "powershell" {
    inline = [
      "$HorizonArgs = '/s /v\"/qn REBOOT=R RDP_CHOICE=1 ADDLOCAL=Core,USB,RTAV,NGVC,V4V,ScannerRedirection,VmwVaudio,GEOREDIR,PerfTracker,HelpDesk\"'" ,
      "Write-Output \"Horizon Installer: ${local.horizon_agent}\"",
      "Write-Output \"Horizon Arguments: $($HorizonArgs)\"",
      "Start-Process -Wait ${local.horizon_agent} -ArgumentList $HorizonArgs"
    ]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  //Shutdown without Optimization
  /*
    provisioner "powershell" {
      inline       = ["Write-Output \"PWSH Shutdown: $(Get-Date -f hh:mm:ss)\"; cmd.exe /c shutdown /s /t 5"]
      pause_before = "30s"
  }
  */
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start PreOptimize $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "Write-Output \"Optimizer Template: ${local.template1}\"",
      "Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-o -t `\"${local.template1}`\" -notification enable -storeapp remove-all --exclude ScreenSketch Calculator StickyNotes Photos -v\" -Wait -PassThru -RedirectStandardOutput C:\\Temp\\Pre-Optimize.log",
      "Write-Output \"End PreOptimize $(Get-Date)\""
    ]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start Optimize $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "Write-Output \"Optimizer Template: ${local.template2}\"",
      "Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-o -v -t `\"${local.template2}`\"\" -Wait -PassThru -RedirectStandardOutput C:\\Temp\\Optimize.log",
      "Write-Output \"End Optimize $(Get-Date)\""
    ]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  //reboot command in generalize script
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start Generalize $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "Write-Output \"Sysprep Answer File: ${local.osot}\"",
      "Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-g `\"${local.answer_file}`\" -v\" -Wait -PassThru -RedirectStandardOutput C:\\Temp\\Generalize.log",
      "Write-Output \"End Generalize $(Get-Date)\"",
      "Write-Output  \"Restart: $(Get-Date -f hh:mm:ss)\"",
      "shutdown /r /t 5"
    ]
    pause_before = "30s"
  }
  //after generalize extend restart-timeout to 10 minutes.
  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {Write-Output `n\"Restarted: $(Get-Date -f hh:mm:ss)\"}\""
    restart_timeout       = "10m"
  }
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start OptimizePostGeneralize $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "Write-Output \"Optimizer Template: ${local.template2}\"",
      "Start-Process -FilePath \"${local.osot}\" -ArgumentList \"-o -v -t `\"${local.template2}`\"\" -Wait -PassThru -RedirectStandardOutput C:\\Temp\\OptimizePostGen.log",
      "Write-Output \"End OptimizePostGeneralize $(Get-Date)\""
    ]
    pause_before = "1m"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"PWSH Restart: $(Get-Date -f hh:mm:ss)\"; Restart-Computer -Confirm:$false -Force"]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline = [
      "Write-Output \"Start Finalized_ScheduledTask $(Get-Date)\"",
      "Write-Output \"Optimizer Tool: ${local.osot}\"",
      "& E:\\Optimize\\Finalized_ScheduledTask.ps1 -optimizer \"${local.osot}\"",
      "Write-Output \"End Finalized_ScheduledTask $(Get-Date)\""
    ]
    pause_before = "30s"
  }
  provisioner "powershell" {
    inline       = ["Write-Output `n\"Provisioning Completed: $(Get-Date -f hh:mm:ss) `nWait (up to 45 minutes) for finalized scheduled task to complete...\""]
    pause_before = "30s"
  }

  post-processor "manifest" {
    output = "manifests/${local.dev_temp_name}${local.time}.json"
  }
}
