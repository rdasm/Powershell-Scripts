#------------------------------------------------------------
# Copyright (c) Microsoft Corporation.  All rights reserved.
#------------------------------------------------------------

Import-Module Azure

# This is the ID of your Tenant. You may replace the value with your Tenant Domain
$tenantId = "Your Tenant ID"

# You can add or change filters here
$url = "https://graph.microsoft.com/beta/auditLogs/signIns?`$filter=createdDateTime%20ge%202019-09-01T06:00:00Z%20and%20createdDateTime%20le%202019-09-19T06:00:00Z&`$top=5000"

# By default, this script saves its results to DownloadedReport_currentTime.csv. You may change the file name as needed.
$now = "{0:yyyyMMdd_hhmmss}" -f (get-date)
$outputFile = "AAD_SignInReport_$now.csv"

###################################
#### DO NOT MODIFY BELOW LINES ####
###################################
Function Expand-Collections {
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline)]
        [psobject]$MSGraphObject
    )
    Begin {
        $IsSchemaObtained = $False
    }
    Process {
        If (!$IsSchemaObtained) {
            $OutputOrder = $MSGraphObject.psobject.properties.name
            $IsSchemaObtained = $True
        }

        $MSGraphObject | ForEach-Object {
            $singleGraphObject = $_
            $ExpandedObject = New-Object -TypeName PSObject

            $OutputOrder | ForEach-Object {
                Add-Member -InputObject $ExpandedObject -MemberType NoteProperty -Name $_ -Value $(($singleGraphObject.$($_) | Out-String).Trim())
            }
            $ExpandedObject
        }
    }
    End {}
}

Function Get-Headers {
    param( $token )

    Return @{
        "Authorization" = ("Bearer {0}" -f $token);
        "Content-Type" = "application/json";
    }
}

$clientId = "1b730954-1685-4b74-9bfd-dac224a7b894" # PowerShell clientId
$redirectUri = "urn:ietf:wg:oauth:2.0:oob"
$MSGraphURI = "https://graph.microsoft.com"

$authority = "https://login.microsoftonline.com/$tenantId"
$authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
$authResult = $authContext.AcquireToken($MSGraphURI, $clientId, $redirectUri, "Always")
$token = $authResult.AccessToken

if ($token -eq $null) {
    Write-Output "ERROR: Failed to get an Access Token"
    exit
}

Write-Output "--------------------------------------------------------------"
Write-Output "Downloading report from $url"
Write-Output "Output file: $outputFile"
Write-Output "--------------------------------------------------------------"

# Call Microsoft Graph
$headers = Get-Headers($token)

$count=0
$retryCount = 0
$oneSuccessfulFetch = $False

Do {
    Write-Output "Fetching data using Url: $url"

    Try {
        $myReport = (Invoke-WebRequest -UseBasicParsing -Headers $headers -Uri $url)
        $convertedReport = ($myReport.Content | ConvertFrom-Json).value
        $convertedReport | Expand-Collections | ConvertTo-Csv -NoTypeInformation | Add-Content $outputFile
        $url = ($myReport.Content | ConvertFrom-Json).'@odata.nextLink'
        $count = $count+$convertedReport.Count
        Write-Output "Total Fetched: $count"
        $oneSuccessfulFetch = $True
        $retryCount = 0
    }
    Catch [System.Net.WebException] {
        $statusCode = [int]$_.Exception.Response.StatusCode
        Write-Output $statusCode
        Write-Output $_.Exception.Message
        if($statusCode -eq 401 -and $oneSuccessfulFetch)
        {
            # Token might have expired! Renew token and try again
            $authResult = $authContext.AcquireToken($MSGraphURI, $clientId, $redirectUri, "Auto")
            $token = $authResult.AccessToken
            $headers = Get-Headers($token)
            $oneSuccessfulFetch = $False
        }
        elseif($statusCode -eq 429 -or $statusCode -eq 504 -or $statusCode -eq 503)
        {
            # throttled request or a temporary issue, wait for a few seconds and retry
            Start-Sleep -5
        }
        elseif($statusCode -eq 403 -or $statusCode -eq 400 -or $statusCode -eq 401)
        {
            Write-Output "Please check the permissions of the user"
            break;
        }
        else {
            if ($retryCount -lt 5) {
                Write-Output "Retrying..."
                $retryCount++
            }
            else {
                Write-Output "Download request failed. Please try again in the future."
                break
            }
        }
     }
    Catch {
        $exType = $_.Exception.GetType().FullName
        $exMsg = $_.Exception.Message

        Write-Output "Exception: $_.Exception"
        Write-Output "Error Message: $exType"
        Write-Output "Error Message: $exMsg"

         if ($retryCount -lt 5) {
            Write-Output "Retrying..."
            $retryCount++
        }
        else {
            Write-Output "Download request failed. Please try again in the future."
            break
        }
    }

    Write-Output "--------------------------------------------------------------"
} while($url -ne $null)
