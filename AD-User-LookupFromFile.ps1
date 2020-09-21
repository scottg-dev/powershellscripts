$users = ForEach ($user in $(Get-Content C:\Temp\test\users.txt)) {

    Get-AdUser $user -Properties Department,Mail
        
}
    
 $users |
 Select-Object SamAccountName,Department,Mail |
 Export-CSV -Path C:\Temp\test\output.csv -NoTypeInformation