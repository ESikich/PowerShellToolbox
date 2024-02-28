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

# Initialize a list to hold the results
$results = New-Object System.Collections.Generic.List[Object]

# Define a streamlined function for adding results directly
function Add-Result {
    param ($type, $identifier, $property, $value)
    $results.Add([PSCustomObject]@{
        Type       = $type
        Identifier = $identifier
        Property   = $property
        Value      = $value
    })
}

# Define a function to process AD objects and GPOs in memory as much as possible
function Process-Items {
    param (
        [string]$Type,
        [System.Collections.Generic.IEnumerable[Object]]$Items,
        [scriptblock]$IdentifierExpression,
        [scriptblock]$AdditionalProcessing = $null
    )
    $totalItems = $Items.Count
    $processedItems = 0
    foreach ($item in $Items) {
        $processedItems++
        Write-Progress -Activity "Processing $Type" -Status "$processedItems of $totalItems processed" -PercentComplete (($processedItems / $totalItems) * 100)

        $identifier = & $IdentifierExpression $item
        if ($Type -eq 'GPO') {
            $value = Get-GPOReport -Guid $item.Id -ReportType Xml
            if ($value -match $searchString) {
                Add-Result -type $Type -identifier $identifier -property "XML Report" -value "Contains '$searchString'"
            }
        } else {
            $properties = $item | Get-Member -MemberType Properties
            foreach ($property in $properties.Name) {
                $value = $item.$property
                if ($value -is [array]) {
                    foreach ($itemValue in $value) {
                        if ($itemValue -match $searchString) {
                            Add-Result -type $Type -identifier $identifier -property $property -value $itemValue
                        }
                    }
                } elseif ($value -match $searchString) {
                    Add-Result -type $Type -identifier $identifier -property $property -value $value
                }
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
