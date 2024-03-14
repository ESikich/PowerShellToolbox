<#
.SYNOPSIS
This script checks for a specific certificate by its thumbprint on the local machine and, optionally, on a remote server (the issuer's server).

.DESCRIPTION
The script searches for a certificate with a given thumbprint across various certificate stores on the local machine. If found, it displays details about the certificate, including its location (store and store location), subject, issuer, expiration date, and validity status. If the issuer's server can be determined, the script then attempts to remotely connect to the issuer's server and performs a similar check to display the certificate details there.

.PARAMETER thumbprint
The thumbprint of the certificate to search for, which may include spaces.

.EXAMPLE
.\CheckCertificate.ps1

This command executes the script to search for and display details of the certificate with the specified thumbprint.

.NOTES
Ensure PowerShell remoting is enabled and configured on the target remote server if attempting to check the issuer's server.
#>

# Thumbprint input with or without spaces
$thumbprintInput = "38 ff 2a 49 f3 dc 65 dc 4e f4 6a d2 60 60 a7 8a 34 15 b9 de"
# Remove spaces from the thumbprint
$thumbprint = $thumbprintInput -replace '\s', ''

# Define the script block for checking certificates, to be used locally and remotely
$scriptBlock = {
    param($thumbprint)

    # Define a function to check and display certificate details
    function Check-Certificate($cert, $store, $storeLocation) {
        if ($cert) {
            $expirationDate = $cert.NotAfter
            $currentDate = Get-Date

            Write-Output "Certificate with thumbprint $thumbprint found in $storeLocation\$store."
            Write-Output "Subject: $($cert.Subject)"
            Write-Output "Issuer: $($cert.Issuer)"
            Write-Output "Expiration Date: $($expirationDate)"
            Write-Output "Status: $(if ($expirationDate -lt $currentDate) { 'Expired' } else { 'Valid' })"
        } else {
            Write-Output "Certificate with thumbprint $thumbprint not found in $storeLocation\$store."
        }
    }

    # Iterate through stores and store locations to find and display certificate details
    $storeLocations = @('LocalMachine', 'CurrentUser')
    $stores = @('My', 'CA', 'Root', 'AuthRoot', 'TrustedPublisher', 'TrustedPeople')

    foreach ($storeLocation in $storeLocations) {
        foreach ($store in $stores) {
            $path = "Cert:\$storeLocation\$store"
            $cert = Get-ChildItem -Path $path -Recurse | Where-Object { $_.Thumbprint -eq $thumbprint }
            if ($cert) {
                Check-Certificate $cert $store $storeLocation
                return
            }
        }
    }
}

# Find and display the certificate details on the local machine
& $scriptBlock $thumbprint

# Continue with the remote check if the certificate's issuer needs to be verified
$localCertFound = $false

foreach ($storeLocation in $storeLocations) {
    foreach ($store in $stores) {
        $path = "Cert:\$storeLocation\$store"
        $localCert = Get-ChildItem -Path $path -Recurse | Where-Object { $_.Thumbprint -eq $thumbprint }
        if ($localCert) {
            $localCertFound = $true
            $issuer = $localCert.Issuer
            Write-Output "Issuer: $issuer"
            break 2
        }
    }
}

if ($localCertFound) {
    # Parse the host name from the issuer's CN
    if ($issuer -match 'CN=([^,]+)') {
        $issuerCN = $matches[1]
        $issuerParts = $issuerCN -split '-'
        if ($issuerParts.Length -eq 3) {
            $issuerServerName = $issuerParts[1]
            Write-Output "Parsed Issuer Server Name: $issuerServerName"

            # Execute the script block remotely
            Invoke-Command -ComputerName $issuerServerName -ScriptBlock $scriptBlock -ArgumentList $thumbprint
        } else {
            Write-Output "Unable to parse the issuer's server name from the CN: $issuerCN"
        }
    } else {
        Write-Output "The issuer's CN could not be found in the issuer string: $issuer"
    }
} else {
    Write-Output "Certificate not found on the local machine."
}
