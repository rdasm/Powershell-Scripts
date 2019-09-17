PARAM ($PastDays = 15 )
#************************************************
# PullAzureSignInReports.ps1
# Version 1.0
# Date: 10-31-2016
# Author: Tim Springston [MSFT]
# Description: This script will use Graph to pull the Azure AD Sign In Events
#  report for the given tenant. The report will pull a 30 day report maximum.
#  At least one user must be assigned an AAD Premium license for this to work.
# Results are placed into CSV files for each report type for review.
#************************************************
cls
# This script will require the Web Application and permissions setup in Azure Active Directory
$ClientID       = "abcdefghijklmnopqrstuvwxyz"             # Should be a ~35 character string insert your info here
$ClientSecret   = "abcdefghijklmnopqrstuvwxyz"         # Should be a ~44 character string insert your info here
$loginURL       = "https://login.windows.net"
$tenantdomain   = "contoso.onmicrosoft.com"            # For example, contoso.onmicrosoft.com
$Tenantname = $tenantdomain.Split('.')[0]

Write-Host "Collecting Azure AD Sign In reports for tenant $tenantdomain`."
function GetReport      ($url, $reportname, $tenantname) {
      $AuditOutputCSV = $Pwd.Path + "\" + (($tenantdomain.Split('.')[0]) + "_SignInReport.csv")
      # Get an Oauth 2 access token based on client id, secret and tenant domain
      $body       = @{grant_type="client_credentials";resource=$resource;client_id=$ClientID;client_secret=$ClientSecret}
      $oauth      = Invoke-RestMethod -Method Post -Uri $loginURL/$tenantdomain/oauth2/token?api-version=1.0 -Body $body
     if ($oauth.access_token -ne $null)
      {
      $Expiry = (Get-Date).AddSeconds($oauth.expires_in)
    $headerParams = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}
    $myReport = (Invoke-WebRequest -UseBasicParsing -Headers $headerParams -Uri $url)
      $ConvertedReport = ConvertFrom-Json -InputObject $myReport.Content 
      $XMLReportValues = $ConvertedReport.value
      $nextURL = $ConvertedReport."@odata.nextLink"
      if ($nextURL -ne $null)
            {
            Do 
            {
            $Soon = (Get-Date).AddSeconds(5)
            $TimeDifference = New-TimeSpan $Expiry $Soon
            if ($TimeDifference.Seconds -le 5)
            {
            $body = @{grant_type="client_credentials";resource=$resource;client_id=$ClientID;client_secret=$ClientSecret}
            $oauth = Invoke-RestMethod -Method Post -Uri $loginURL/$tenantdomain/oauth2/token?api-version=1.0 -Body $body
            $headerParams = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}
            $Expiry = (Get-Date).AddSeconds($oauth.expires_in)
            }
            $NextResults = Invoke-WebRequest -UseBasicParsing -Headers $headerParams -Uri $nextURL -ErrorAction SilentlyContinue
            $NextConvertedReport = ConvertFrom-Json -InputObject $NextResults.Content 
            $XMLReportValues += $NextConvertedReport.value
            $nextURL = $NextConvertedReport."@odata.nextLink"
            }
            While ($nextURL -ne $null)
            }
            #Place results into a CSV
            $AuditOutputCSV = $Pwd.Path + "\" + $tenantname + "_$reportname.csv"
      $XMLReportValues | select *  |  Export-csv $AuditOutputCSV -NoTypeInformation -Force -append
            Write-Host "The report can be found at $AuditOutputCSV".
      }     
      if ($ConvertedReport.value.count -eq 0)
        {
        $AuditOutputCSV = $Pwd.Path + "\" + $tenantname + "_$reportname.txt"
        Get-Date |  Out-File -FilePath $AuditOutputCSV 
        "No Data Returned. This typically means either the tenant does not have Azure AD Premium licensing or that the report query succeeded however there were no entries in the report. " |  Out-File -FilePath $AuditOutputCSV -Append
        }
      }

if ($PastDays -ne $null)
	{
	$DateRaw = Get-Date
	$Date = ($DateRaw.Month.ToString()) + '-' + ($DateRaw.Day.ToString()) + "-" + ($DateRaw.Year.ToString())
	$PastPeriod =  "{0:s}" -f (get-date).AddDays(-($PastDays)) + "Z"
	$filter = "`$filter=signinDateTime+ge+$PastPeriod"
	$url = "https://graph.windows.net/$tenantdomain/activities/signinEvents?api-version=beta&" + $filter
	GetReport $url $ReportName $Tenantname
	}
