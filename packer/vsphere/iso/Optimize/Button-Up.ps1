# Finalize (option 7, sdelete, will balloon the snapshot storage, so is left out instead of using the "all" option)
param($Optimizer="E:\Optimize\VMwareHorizonOSOptimizationTool-x86_64-1.2.2303.21510536.exe")
$Temp = "C:\Temp"
Write-Output "Button-Up"
Start-Process -FilePath $optimizer -ArgumentList "-f 0 1 2 3 4 5 6 9 10 11 -v" -Wait -PassThru -RedirectStandardOutput $Temp\Button-Up.log

Write-Output "cleaning c:\temp"
$cleanup = gci $temp\* -Include *
Remove-Item $cleanup -Force -Recurse

# Shutdown machine with comment
shutdown /s /t 30 /c "Image Ready"