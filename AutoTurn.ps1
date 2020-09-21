Write-Host "Please be patient while the AutoTURN 10.2.3 installation completes."
Start-Sleep -Seconds 10
Start-Process msiexec.exe '/i C:\Temp\SetupWorkstationSilent.msi /quiet /le c:\temp\autoturn.txt' -Verb runAs
Start-Sleep -Seconds 180
$expath = "C:\Program Files\Transoft Solutions\AutoTURN 10"
if (!$expath)
{
Write-Host "AutoTurn Did not install correctly, please try again."
Pause
Exit
}
Write-Host "AutoTurn 10.2.3 has completed."
Pause