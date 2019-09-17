$array = New-Object System.Collections.arraylist
$computers = Get-AdComputer -filter 'enabled -eq $true'
foreach ($computer in $computers)
{
    $results = Get-Admpwdpassword -computername $computer
    $array.add([PSCUSTOMOBJECT]@{
    "Computername" = $computer.name
    "DN" = $results.distinguishedname
    "Password" = $results.password
    "Expiration" = $results.expiration}) | Out-null
}

$array | Export-csv -notypeinformation .\results.csv -delimiter "`t" 
