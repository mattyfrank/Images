build {
  name = "Win10-image"

  sources = [
    "source.azure-arm.Win10-image"
  ]

  #provisioner "powershell" {
  #  script = "provisioners/choco-bootstrap-offline.ps1"
  #}

  provisioner "windows-shell" {
    inline = [
      "shutdown /r /t 0"
    ]
  }
  
  provisioner "powershell" {
    script       = "provisioners/run_sysprep.ps1"
    pause_before = "30s"
  }

}
