# PowerShell Script to Find Printer Related GPOs

# Import the GroupPolicy module
Import-Module GroupPolicy

# Get all GPOs in the domain
$gpos = Get-GPO -All

# Loop through each GPO
foreach ($gpo in $gpos) {
    # Generate GPO Report in XML format
    $report = Get-GPOReport -Guid $gpo.Id -ReportType Xml

    # Check if the report contains printer related settings
    if ($report -like "*printer*") {
        Write-Host "Printer-related GPO found: $($gpo.DisplayName)"
    }
}
