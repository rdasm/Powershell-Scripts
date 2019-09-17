$count=1
$users = ForEach ($user in $(Get-Content -Path .\$args)) {


Get-ADUser -Filter {Emailaddress -eq $user} | Get-ADuser -Properties displayname,description
$nil = (Get-ADUser -Filter {Emailaddress -eq $user})
    if ($nil -eq $Null) 
	    {
	    Add-Content -Path .\$args.fault.txt -Value  $count
	    Write-output $user | Out-File .\$args.fault.txt -Append
	    }
    else
        {
	Add-Content -Path .\$args.users.txt -Value  $count
        Get-ADUser -Filter {Emailaddress -eq $user} | Select -ExpandProperty description | Out-File .\$args.users.txt -Append
        }
$count=$count+1
}
    
 $users | Select-Object SamAccountName,Displayname,UserPrincipalName,Description | Export-CSV -Path .\$args.found.csv -NoTypeInformation
