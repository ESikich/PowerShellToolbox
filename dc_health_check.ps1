<#
.SYNOPSIS
This script checks the health of all domain controllers in the current Active Directory domain.

.DESCRIPTION
The script performs several checks on each domain controller, including replication status, service status, network accessibility, and share availability. It requires the Active Directory PowerShell module and appropriate permissions to access and manage domain controllers.

.AUTHOR
Erik Sikich
github.com/esikich

.EXAMPLE
PS> .\Check-DomainControllerHealth.ps1

.NOTES
This script is intended for use in environments where PowerShell remoting and necessary AD permissions are enabled.
Always test in a non-production environment before deploying in a live setting.
#>

# Import ActiveDirectory Module
if (-not (Get-Module -Name ActiveDirectory -ListAvailable)) {
    Write-Host "Active Directory module is not installed. Installing..." -ForegroundColor Cyan
    Install-WindowsFeature RSAT-AD-PowerShell
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "Active Directory module installed successfully." -ForegroundColor Green
} else {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "Active Directory module loaded successfully." -ForegroundColor Green
}

function Check-SysvolReplicationType {
    param (
        [string]$DomainController
    )

    $dfsrPath = "CN=SYSVOL Subscription,CN=Domain System Volume,CN=DFSR-LocalSettings,CN=$DomainController,OU=Domain Controllers,DC=<YourDomain>,DC=<YourTLD>"

    try {
        $dfsrObject = Get-ADObject -Identity $dfsrPath -Properties "msDFSR-Flags"
        if ($dfsrObject."msDFSR-Flags") {
            return "DFSR"
        } else {
            return "FSR"
        }
    } catch {
        return "FSR"  # Default to FSR if the DFSR object is not found
    }
}

function Test-DomainControllerHealth {
    # Retrieve all domain controllers in the current domain
    $domainControllers = Get-ADDomainController -Filter *

    foreach ($dc in $domainControllers) {
        Write-Host "`nChecking health for domain controller: $($dc.HostName)" -ForegroundColor Yellow

        # Check SYSVOL Replication Type
        $replicationType = Check-SysvolReplicationType -DomainController $dc.HostName
        Write-Host "SYSVOL Replication Type for $($dc.HostName): $replicationType" -ForegroundColor Yellow

        # Check Replication Status
        try {
            repadmin /showrepl $dc.HostName | Out-Null
            Write-Host "Replication Status for $($dc.HostName): OK" -ForegroundColor Green
        } catch {
            Write-Host "Replication Status for $($dc.HostName): ERROR" -ForegroundColor Red
        }

        # Check Key Services
        $services = @("NTDS", "DNS", "KDC", "Netlogon")
        foreach ($service in $services) {
            try {
                $status = Get-Service -ComputerName $dc.HostName -Name $service -ErrorAction Stop
                if ($status.Status -eq "Running") {
                    Write-Host "$service service on $($dc.HostName): Running" -ForegroundColor Green
                } else {
                    Write-Host "$service service on $($dc.HostName): NOT RUNNING" -ForegroundColor Red
                }
            } catch {
                Write-Host "Failed to retrieve status for $service on $($dc.HostName)" -ForegroundColor Red
            }
        }

        # Network Accessibility (Ping Test)
        if (Test-Connection -ComputerName $dc.HostName -Count 2 -Quiet) {
            Write-Host "Network accessibility for $($dc.HostName): OK" -ForegroundColor Green
        } else {
            Write-Host "Network accessibility for $($dc.HostName): UNREACHABLE" -ForegroundColor Red
        }

        # Check SYSVOL and NETLOGON Shares
        foreach ($share in @("SYSVOL", "NETLOGON")) {
            if (Test-Path "\\$($dc.HostName)\$share") {
                Write-Host "$share share on $($dc.HostName): ACCESSIBLE" -ForegroundColor Green
            } else {
                Write-Host "$share share on $($dc.HostName): INACCESSIBLE" -ForegroundColor Red
            }
        }

        Write-Host "--------------------------------------" -ForegroundColor Magenta
    }
}

# Execute the health check function
Test-DomainControllerHealth
