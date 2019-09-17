#Remove-Item .\$args.final.csv
$users = ForEach ($user in $(Get-Content -Path .\$args.users.txt)) {

    Disable-ADAccount $user    
    Get-AdUser $user -Properties Department, Mail      
}
    
 $users | Select-Object SamAccountName,Mail,GivenName,Surname,Enabled | Export-CSV -Path .\$args.final.csv -NoTypeInformation
