<#
.SYNOPSIS
This script retrieves all computers from Active Directory, sorts them by the last AD logon date, 
checks for the most recent logon event in the security logs, and displays the results in a sorted table.

.DESCRIPTION
The script performs the following steps:
1. Fetches all computer objects from Active Directory, including their last logon date.
2. Sorts these computers by their last logon date in descending order.
3. Iterates over the sorted list of computers, querying the Security event log on the local domain controller 
   for the most recent logon event for each computer (Event IDs 4768 and 4624).
4. Compiles the results into a hashtable, including each computer's name, last logon date from AD, 
   and the most recent logon event time.
5. Sorts the final results by the most recent logon event time and displays them in a formatted table.

.NOTES
File Name : AD_Stale_PCs.ps1
Author    : Erik Sikich
Version   : 1.0
Requires  : PowerShell v5.1 or higher, Active Directory module

.EXAMPLE
PS> .\AD_Stale_PCs.ps1

This example runs the script, displaying a table of all computers, their last AD logon date, 
and the most recent logon event time, sorted by the most recent logon event time.
#>

$computers = Get-ADComputer -Filter * -Properties Name, LastLogonDate |
             Sort-Object LastLogonDate -Descending |
             Select-Object Name, LastLogonDate

$activity = @{}
$eventIdFilter = "EventID=4768 or EventID=4624"
$i = 0

foreach ($computer in $computers) {
    $progressPercent = ($i++ / $computers.Count) * 100
    Write-Progress -Activity "Analyzing Logon Events" -Status "Checking $($computer.Name)" -PercentComplete $progressPercent
    
    $computerName = $computer.Name.Split('.')[0]
    $xpathFilter = "*[System[($eventIdFilter)] and EventData[Data[@Name='TargetUserName']='$computerName$']]"
    
    $logonEvent = Get-WinEvent -LogName Security -FilterXPath $xpathFilter -ErrorAction SilentlyContinue -MaxEvents 1

    $lastLogonEventTime = if ($logonEvent) { $logonEvent.TimeCreated } else { $null }

    $activity[$computer.Name] = @{
        LastLogonDate = $computer.LastLogonDate
        LastLogonEventTime = $lastLogonEventTime
    }
}

Write-Progress -Activity "Processing Complete" -Status "Finalizing" -Completed

$sortedActivity = $activity.GetEnumerator() | Sort-Object { $_.Value.LastLogonEventTime } -Descending

$properties = @(
    @{
        Name = 'ComputerName'
        Expression = { $_.Key }
    },
    @{
        Name = 'LastLogonDate'
        Expression = { $_.Value.LastLogonDate }
    },
    @{
        Name = 'LastLogonEventTime'
        Expression = { $_.Value.LastLogonEventTime }
    }
)

$sortedActivity | Format-Table -Property $properties -AutoSize

# Display in a formatted table
$sortedActivity | Format-Table -Property $properties -AutoSize

# Export to a CSV file
$sortedActivity | Select-Object @{Name='ComputerName'; Expression={$_.Key}},
                                 @{Name='LastLogonDate'; Expression={$_.Value.LastLogonDate}},
                                 @{Name='LastLogonEventTime'; Expression={$_.Value.LastLogonEventTime}} |
Export-Csv -Path "AD_Stale_PCs_Report.csv" -NoTypeInformation
