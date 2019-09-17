#Remove-Item .\$args.fault.txt
#Remove-Item .\$args.users.txt
$count=1
$users = ForEach ($user in $(Get-Content -Path .\$args.txt)) {

$nil = (Invoke-command -computer $user {Get-ItemProperty -path "HKLM:software/microsoft/windows/currentversion/oeminformation" | Select-object pscomputername,model})
   if ($nil -eq $Null) 
	    {
	    Add-Content -Path .\$args.fault.txt -Value  $count
	    Write-output $user | Out-File .\$args.fault.txt -Append
	    }
    else
        {
	 Write-output $nil | Out-File .\$args.found.txt -Append
        }
$count=$count+1
}
    
 $users | Select-Object Name
