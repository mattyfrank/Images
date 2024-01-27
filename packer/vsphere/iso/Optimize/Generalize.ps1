param(
    $Optimizer = "E:\Optimize\VMwareHorizonOSOptimizationTool-x86_64-1.2.2303.21510536.exe",
    $answer_file="E:\Optimize\answer_file.xml"    
)

if(!(Test-Path $Optimizer)){Write-Error "Optimizer Missing!" -ErrorAction Stop}

Write-Output "Optimizer: $optimizer"
Write-Output "Answer File: $answer_file"

Write-Output `n"Generalize: $(Get-Date)"
Start-Process -FilePath $Optimizer -ArgumentList "-g "$answer_file" -v" -Wait -PassThru -RedirectStandardOutput C:\Temp\Generalize.log

Write-Output "End Generalize."
Write-Output "Rebooting"; shutdown /r /t 5