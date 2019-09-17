#Remove-Item .\$args.fault.txt
#Remove-Item .\$args.users.txt
$count=1
$users = ForEach ($user in $(Get-Content -Path .\$args.txt)) {

    Get-ADUser -Filter {SamAccountName -eq $user} | Get-ADUser -Properties Description    
    $nil = (Get-ADUser -Filter {SamAccountName -eq $user})
    if ($nil -eq $Null) 
	    {
	    Add-Content -Path .\$args.fault.txt -Value  $count
	    Write-output $user | Out-File .\$args.fault.txt -Append
	    }
    else
        {
	Add-Content -Path .\$args.users.txt -Value  $count
        Get-ADUser -Filter {SamAccountName -eq $user} | Select -ExpandProperty SamAccountName | Out-File .\$args.users.txt -Append
        }
$count=$count+1
}
    
 $users | Select-Object SamAccountName,GivenName,Surname,UserPrincipalName,Description,Country | Export-CSV -Path .\$args.found.csv -NoTypeInformation
