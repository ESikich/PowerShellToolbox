<#
.SYNOPSIS
This script scans all Active Directory (AD) objects and Group Policy Objects (GPOs) for a specific string "Users1" in all their attributes and settings, providing progress feedback.

.DESCRIPTION
The script performs two main functions:
1. Scans all AD objects for the specified string in all attributes.
2. Generates XML reports for each GPO and searches them for the specified string.

It includes progress bars to indicate the progress of scans across AD objects and GPOs.

.AUTHOR
Your Name or Alias

.DATE
Date of Creation: 2024-02-28

.NOTES
- Requires ActiveDirectory and GroupPolicy PowerShell modules.
- Intended for use by system administrators with appropriate permissions.
- Execution time may vary based on the size of the AD and number of GPOs.

.EXAMPLE
PS> .\ScanADandGPOs.ps1

This command executes the script, scanning for the string "Users1" across all AD objects and GPOs.

#>

# Load necessary modules
Import-Module ActiveDirectory
Import-Module GroupPolicy

# Define the search string, not case sensitive
$searchString = "Users1"

# Function to scan AD Objects
function Scan-ADObjects {
    Write-Output "Scanning Active Directory Objects..."
    $allADObjects = Get-ADObject -Filter * -Properties *
    $totalObjects = $allADObjects.Count
    $currentObject = 0

    foreach ($obj in $allADObjects) {
        $currentObject++
        $percentComplete = ($currentObject / $totalObjects) * 100
        Write-Progress -Activity "Scanning Active Directory" -Status "$currentObject of $totalObjects objects scanned" -PercentComplete $percentComplete

        $properties = $obj | Get-Member -MemberType Properties
        foreach ($property in $properties) {
            $value = $obj.$($property.Name)
            if ($value -is [array]) {
                foreach ($item in $value) {
                    if ($item -match $searchString) {
                        Write-Output "Found match in $($obj.DistinguishedName) on property $($property.Name) with value $item"
                    }
                }
            } else {
                if ($value -match $searchString) {
                    Write-Output "Found match in $($obj.DistinguishedName) on property $($property.Name) with value $value"
                }
            }
        }
    }
}

# Function to scan GPOs
function Scan-GPOs {
    Write-Output "Scanning Group Policy Objects..."
    $allGPOs = Get-GPO -All
    $totalGPOs = $allGPOs.Count
    $currentGPO = 0

    foreach ($gpo in $allGPOs) {
        $currentGPO++
        $percentComplete = ($currentGPO / $totalGPOs) * 100
        Write-Progress -Activity "Scanning Group Policy Objects" -Status "$currentGPO of $totalGPOs GPOs scanned" -PercentComplete $percentComplete

        $gpoReportXml = Get-GPOReport -Guid $gpo.Id -ReportType Xml
        if ($gpoReportXml -match $searchString) {
            Write-Output "Found match in GPO: $($gpo.DisplayName)"
        }
    }
}

# Execute scans
Scan-ADObjects
Scan-GPOs

# Finalize progress
Write-Progress -Activity "Scanning Active Directory and GPOs" -Completed -Status "Scan complete"
Write-Output "Scanning complete."
