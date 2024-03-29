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

function Get-DomainFSMORoles {
    $domain = Get-ADDomain
    $forest = Get-ADForest

    $fsmoRoles = @{
        "Schema Master" = $forest.SchemaMaster;
        "Domain Naming Master" = $forest.DomainNamingMaster;
        "PDC Emulator" = $domain.PDCEmulator;
        "RID Master" = $domain.RIDMaster;
        "Infrastructure Master" = $domain.InfrastructureMaster;
    }

    Write-Host "`nDomain FSMO Roles for: $($domain.Name)" -ForegroundColor Cyan
    Write-Host "--------------------------------------" -ForegroundColor Magenta

    foreach ($role in $fsmoRoles.GetEnumerator()) {
        Write-Host ("{0,-22}: {1}" -f $role.Key, $role.Value) -ForegroundColor Yellow
    }

    Write-Host "--------------------------------------`n" -ForegroundColor Magenta
}


function Check-SysvolReplicationType {
    param (
        [string]$DomainController
    )

    # Get the current domain and default naming context
    $currentDomain = (Get-ADDomainController -Identity $DomainController).hostname
    $defaultNamingContext = (([ADSI]"LDAP://$currentDomain/rootDSE").defaultNamingContext)

    # Prepare the searcher for Domain Controllers
    $searcher = New-Object DirectoryServices.DirectorySearcher
    $searcher.Filter = "(&(objectClass=computer)(dNSHostName=$currentDomain))"
    $searcher.SearchRoot = "LDAP://" + $currentDomain + "/OU=Domain Controllers," + $defaultNamingContext
    $dcObjectPath = $searcher.FindAll() | %{$_.Path}

    # Check for DFSR
    $searchDFSR = New-Object DirectoryServices.DirectorySearcher
    $searchDFSR.Filter = "(&(objectClass=msDFSR-Subscription)(name=SYSVOL Subscription))"
    $searchDFSR.SearchRoot = $dcObjectPath
    $dfsrSubObject = $searchDFSR.FindAll()

    if ($dfsrSubObject -ne $null) {
        return [pscustomobject]@{
            "SYSVOL Replication Mechanism" = "DFSR"
            "Path" = $dfsrSubObject|%{$_.Properties."msdfsr-rootpath"}
        }
    }

    # Check for FRS
    $searchFRS = New-Object DirectoryServices.DirectorySearcher
    $searchFRS.Filter = "(&(objectClass=nTFRSSubscriber)(name=Domain System Volume (SYSVOL share)))"
    $searchFRS.SearchRoot = $dcObjectPath
    $frsSubObject = $searchFRS.FindAll()

    if ($frsSubObject -ne $null) {
        return [pscustomobject]@{
            "SYSVOL Replication Mechanism" = "FRS"
            "Path" = $frsSubObject|%{$_.Properties.frsrootpath}
        }
    }

    # Default return if neither DFSR nor FRS objects are found
    return "Unknown"
}

# Function to get SYSVOL size and check free disk space
function Check-SysvolDiskSpace {
    param (
        [string]$DomainController
    )

    try {
        # Get the size of the SYSVOL folder
        $sysvolSize = (Get-ChildItem "\\$DomainController\SYSVOL" -Recurse -File -Force | Measure-Object -Property Length -Sum).Sum

        $files = Get-ChildItem "\\$DomainController\SYSVOL" -Recurse | Where-Object { -not $_.PSIsContainer }
        Write-Host $files

        # Convert size to GB
        $sysvolSizeGB = [math]::Round($sysvolSize / 1GB, 2)

        # Get the free space on the drive where SYSVOL is located
        $driveInfo = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $DomainController -Filter "DeviceID='C:'"
        $freeSpaceGB = [math]::Round($driveInfo.FreeSpace / 1GB, 2)

        # Calculate required free space (SYSVOL size + 10%)
        $requiredSpaceGB = [math]::Round($sysvolSizeGB * 1.1, 2)

        # Check if free space is sufficient
        $isSpaceSufficient = $freeSpaceGB -ge $requiredSpaceGB

        $result = @{
            "DomainController"    = $DomainController
            "SYSVOLSizeGB"        = $sysvolSizeGB
            "FreeSpaceGB"         = $freeSpaceGB
            "RequiredSpaceGB"     = $requiredSpaceGB
            "IsSpaceSufficient"   = $isSpaceSufficient
        }

        return $result
    } catch {
        Write-Host "Failed to check disk space for $DomainController" -ForegroundColor Red
        return $null
    }
}

# Function to check if SYSVOL is shared and DC is advertising
function Check-SysvolAndAdvertising {
    param (
        [string]$DomainController
    )

    try {
        $dcdiagResult = Invoke-Command -ComputerName $DomainController -ScriptBlock {
            dcdiag /s:$env:COMPUTERNAME /test:sysvolcheck /test:advertising
        }

        # Parsing the result for SYSVOL check
        $sysvolCheckMatch = $dcdiagResult -match "^\s*.* passed test SysVolCheck"
        $sysvolCheck = $sysvolCheckMatch -ne $null

        # Parsing the result for Advertising check
        $advertisingCheckMatch = $dcdiagResult -match "^\s*.* passed test Advertising"
        $advertisingCheck = $advertisingCheckMatch -ne $null

        $result = @{
            "DomainController"   = $DomainController
            "IsSYSVOLHealthy"    = $sysvolCheck
            "IsAdvertising"      = $advertisingCheck
        }

        return $result
    } catch {
        Write-Host "Failed to perform Dcdiag checks on $DomainController" -ForegroundColor Red
        return $null
    }
}

# Function to check the "Manage Auditing and Security Log" policy
function Check-SecurityPolicy {
    param (
        [string]$DomainController
    )

    try {
        $seceditExportPath = "\\$DomainController\c$\Temp\secpol.cfg"
        $seceditReportPath = "\\$DomainController\c$\Temp\secpol.txt"

        # Export the security settings to a file
        Invoke-Command -ComputerName $DomainController -ScriptBlock {
            secedit /export /cfg C:\Temp\secpol.cfg
        }

        # Convert the file to a readable format
        Invoke-Command -ComputerName $DomainController -ScriptBlock {
            secedit /export /areas USER_RIGHTS /cfg C:\Temp\secpol.cfg /log C:\Temp\secpol.txt
        }

        # Read and parse the file
        $secpolContent = Get-Content -Path $seceditReportPath
        $isAdminRightSet = $secpolContent -match "SeSecurityPrivilege\s*\*\s*S-1-5-32-544"

        Remove-Item -Path $seceditExportPath -Force
        Remove-Item -Path $seceditReportPath -Force

        return $isAdminRightSet
    } catch {
        Write-Host "Failed to check security policy on $DomainController" -ForegroundColor Red
        return $null
    }
}

function Test-DomainControllerHealth {
    # Retrieve all domain controllers in the current domain
    $domainControllers = Get-ADDomainController -Filter *

    foreach ($dc in $domainControllers) {
        Write-Host "`nHealth Check for Domain Controller: $($dc.HostName)" -ForegroundColor Cyan
        Write-Host "--------------------------------------" -ForegroundColor Magenta

        # Check SYSVOL Replication Type
        $replicationTypeInfo = Check-SysvolReplicationType -DomainController $dc.HostName
        Write-Host "SYSVOL Replication: $($replicationTypeInfo.'SYSVOL Replication Mechanism')" -ForegroundColor Yellow

        # Check Key Services
        $services = @("NTDS", "DNS", "KDC", "Netlogon")
        $serviceStatuses = $services | ForEach-Object {
            try {
                $status = Get-Service -ComputerName $dc.HostName -Name $_ -ErrorAction Stop
                "$_ : " + $(if ($status.Status -eq "Running") { "Running" } else { "NOT RUNNING" })
            } catch {
                "$_ : Error"
            }
        }
        Write-Host "Service Statuses:`n$($serviceStatuses -join "`n")" -ForegroundColor Yellow

        # Network Accessibility
        $networkStatus = if (Test-Connection -ComputerName $dc.HostName -Count 2 -Quiet) { "OK" } else { "UNREACHABLE" }
        Write-Host "Network Accessibility: $networkStatus" -ForegroundColor Yellow

        # Check SYSVOL and NETLOGON Shares
        $shares = @("SYSVOL", "NETLOGON")
        $shareStatuses = $shares | ForEach-Object {
            $status = if (Test-Path "\\$($dc.HostName)\$_") { "ACCESSIBLE" } else { "INACCESSIBLE" }
            "$_ Share: $status"
        }
        Write-Host "Share Statuses:`n$($shareStatuses -join "`n")" -ForegroundColor Yellow

        # Check SYSVOL Disk Space
        $diskSpaceCheck = Check-SysvolDiskSpace -DomainController $dc.HostName
        if ($diskSpaceCheck -ne $null) {
            $status = if ($diskSpaceCheck.IsSpaceSufficient) { "PASS" } else { "FAIL" }
            $statusColor = if ($diskSpaceCheck.IsSpaceSufficient) { 'Green' } else { 'Red' }
            Write-Host "Disk Space: $status" -ForegroundColor $statusColor
            Write-Host "Details: SYSVOL Size: $($diskSpaceCheck.SYSVOLSizeGB) GB, Free: $($diskSpaceCheck.FreeSpaceGB) GB, Required: $($diskSpaceCheck.RequiredSpaceGB) GB"
        }

        # Check "Manage Auditing and Security Log" Policy
        $isSecurityPolicySet = Check-SecurityPolicy -DomainController $dc.HostName
        $securityPolicyStatus = if ($isSecurityPolicySet) { "PASS" } else { "FAIL" }
        $securityPolicyColor = if ($isSecurityPolicySet) { 'Green' } else { 'Red' }
        Write-Host "Security Policy: $securityPolicyStatus" -ForegroundColor $securityPolicyColor

        # Check SYSVOL and Advertising
        $sysvolAdvertisingCheck = Check-SysvolAndAdvertising -DomainController $dc.HostName
        if ($sysvolAdvertisingCheck -ne $null) {
            $sysvolStatus = if ($sysvolAdvertisingCheck.IsSYSVOLHealthy) { "Healthy" } else { "Unhealthy" }
            $advertisingStatus = if ($sysvolAdvertisingCheck.IsAdvertising) { "Passing" } else { "Failing" }
            Write-Host "SYSVOL: $sysvolStatus, Advertising: $advertisingStatus"
        }

        Write-Host "--------------------------------------`n" -ForegroundColor Magenta
    }
}

# Execute the health check function
Test-DomainControllerHealth

# Execute the FSMO roles check function
Get-DomainFSMORoles
