## Runs sysprep
Write-Output "Running Sysprep..."

## executes sysprep
& $env:SystemRoot\System32\sysprep\sysprep.exe /oobe /generalize /shutdown

## wait until sysprep finishes
while($true) { $imageState = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State | Select-Object ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }
