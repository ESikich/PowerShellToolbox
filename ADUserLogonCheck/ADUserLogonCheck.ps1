<#
.SYNOPSIS
Active Directory User Logon Details

.DESCRIPTION
This PowerShell script retrieves active users from Active Directory who have either a logon script or a home folder mapped (or both). It displays their username, script name, home folder, and last logon time in a formatted table. Useful for administrators looking to audit user account configurations and activity.
#>

# Import the Active Directory module
Import-Module ActiveDirectory

# Get all users who have either a logon script, home folder mapped, or both, and are active
$usersWithScriptOrHomeFolder = Get-ADUser -Filter "ScriptPath -like '*' -or HomeDirectory -like '*'" -Properties ScriptPath, HomeDirectory, Enabled, LastLogonDate | Where-Object { $_.Enabled -eq $true }

# Check if any users were found
if ($usersWithScriptOrHomeFolder.Count -eq 0) {
    Write-Host "No active users found with a logon script or a home folder mapped."
} else {
    # Create a custom object for each user and output in a table format
    $usersWithScriptOrHomeFolder | ForEach-Object {
        $username = $_.SamAccountName
        $scriptName = if ($_.ScriptPath) { $_.ScriptPath } else { "N/A" }
        $homeFolder = if ($_.HomeDirectory) { $_.HomeDirectory } else { "N/A" }
        $lastLogonDate = if ($_.LastLogonDate) { $_.LastLogonDate.ToString("g") } else { "N/A" }

        # Create a custom object
        [PSCustomObject]@{
            Username = $username
            ScriptName = $scriptName
            HomeFolder = $homeFolder
            LastLogonTime = $lastLogonDate
        }
    } | Format-Table -AutoSize
}
