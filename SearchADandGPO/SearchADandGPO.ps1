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
$searchString = "server6"

# Initialize a list to hold the results
$results = New-Object System.Collections.Generic.List[Object]

# Initialize hashtables to track processed items
$processedADObjects = @{}
$processedGPOs = @{}

# Function to add results, ensuring uniqueness for AD Objects and GPOs
function Add-Result {
    param ($type, $identifier, $property, $value)
    $key = "$type-$identifier"
    if (-not $processedADObjects.ContainsKey($key) -and $type -eq 'AD Object') {
        $processedADObjects[$key] = $true
        $results.Add([PSCustomObject]@{
            Type       = $type
            Identifier = $identifier
            Property   = $property
            Value      = $value
        })
    }
    elseif (-not $processedGPOs.ContainsKey($key) -and $type -eq 'GPO') {
        $processedGPOs[$key] = $true
        $results.Add([PSCustomObject]@{
            Type       = $type
            Identifier = $identifier
            Property   = $property
            Value      = $value
        })
    }
}

# Function to process AD objects and GPOs, focusing on unique entries
function Process-Items {
    param (
        [string]$Type,
        [System.Collections.Generic.IEnumerable[Object]]$Items,
        [scriptblock]$IdentifierExpression
    )
    $totalItems = $Items.Count
    $processedItemsCount = 0
    foreach ($item in $Items) {
        $processedItemsCount++
        Write-Progress -Activity "Processing $Type" -Status "$processedItemsCount of $totalItems processed" -PercentComplete (($processedItemsCount / $totalItems) * 100)

        $identifier = & $IdentifierExpression $item
        if ($Type -eq 'GPO') {
            $value = Get-GPOReport -Guid $item.Id -ReportType Xml -ErrorAction SilentlyContinue
            if ($value -match $searchString) {
                Add-Result -type $Type -identifier $identifier -property "XML Report" -value "Contains '$searchString'"
            }
        } else {
            $hasMatch = $false
            $properties = $item | Get-Member -MemberType Properties
            foreach ($property in $properties.Name) {
                $value = $item.$property
                if ($value -match $searchString) {
                    $hasMatch = $true
                    break # Found a match, no need to check further properties for AD Object
                }
            }
            if ($hasMatch) {
                Add-Result -type $Type -identifier $identifier -property "N/A" -value "Contains '$searchString'"
            }
        }
    }
    Write-Progress -Activity "Processing $Type" -Status "Completed" -Completed
}

# Scan Active Directory Objects
$adObjects = Get-ADObject -Filter * -Properties *
Write-Host "Scanning Active Directory Objects..."
Process-Items -Type "AD Object" -Items $adObjects -IdentifierExpression { param($obj) $obj.DistinguishedName }

# Scan Group Policy Objects
$gpos = Get-GPO -All
Write-Host "Scanning Group Policy Objects..."
Process-Items -Type "GPO" -Items $gpos -IdentifierExpression { param($gpo) $gpo.DisplayName }

# Display results
if ($results.Count -gt 0) {
    $results | Format-Table -Property Type, Identifier, Property, Value -AutoSize
} else {
    Write-Output "No matches found."
}
Write-Output "Scanning complete."
