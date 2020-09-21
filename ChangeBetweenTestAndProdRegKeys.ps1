[System.Windows.MessageBox]::Show('Hello')
Write-Host "Please choose one of the following 1 for Testing, 2 for production"
$Answer = Read-Host -Prompt 'Enter the number you want'

switch ($Answer)
{
	1{Copy-Item "\\capas01tst06\temp\Scott\!Appsetra\Appsetra Test.reg" -Destination "C:\Users\P009197D\Desktop" -Recurse}
	2{Copy-Item "\\capas01tst06\temp\Scott\!Appsetra\Appsetra Prod.reg" -Destination "C:\Users\P009197D\Desktop" -Recurse}
}
Copy-Item "\\capas01tst06\temp\Scott\!Appsetra\RestartService.cmd" -Destination "C:\Users\P009197D\Desktop" -Recurse

