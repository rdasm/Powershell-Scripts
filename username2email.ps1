$count=1
$users = ForEach ($user in $(Get-Content -Path .\$args)) {

Get-ADUser -Filter {samAccountName -eq $user} | Get-ADuser -Properties DisplayName
$nil = (Get-ADUser -Filter {samAccountName -eq $user})
    if ($nil -eq $Null) 
	    {
	    Add-Content -Path .\$args.fault.txt -Value  $count
	    Write-output $user | Out-File .\$args.fault.txt -Append
	    }
    else
        {
	Add-Content -Path .\$args.users.txt -Value  $count
        Get-ADUser -Filter {samAccountName -eq $user} | Select -ExpandProperty samAccountName | Out-File .\$args.users.txt -Append
        }
$count=$count+1
}
    
 $users | Select-Object SamAccountName,GivenName,Surname,UserPrincipalName,Mail | Export-CSV -Path .\$args.found.csv -NoTypeInformation
