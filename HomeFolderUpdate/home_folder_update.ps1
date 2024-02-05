# Import the Active Directory module
Import-Module ActiveDirectory

# Variables
$findString = "\\oldserver" # Current string to search for (double backslashes for literal interpretation in match)
$replaceString = "\\newserver02" # String to replace with (normal backslashes for replacement string)

# Get all AD users with a home directory containing the findString
$allUsers = Get-ADUser -Filter * -Properties HomeDirectory

# Filter users with a home directory containing the findString
$usersWithHomeFolder = $allUsers | Where-Object { $_.HomeDirectory -like "*$findString*" }

# Check if any users are found
if ($usersWithHomeFolder.Count -eq 0) {
    Write-Output "No users found with home directory containing '$findString'."
    exit
}

# Display proposed changes and ask for confirmation
Write-Output "Proposed home directory changes:"
foreach ($user in $usersWithHomeFolder) {
    # Show the current and proposed new home directory
    $newHomeDirectory = $user.HomeDirectory -replace [regex]::Escape($findString), $replaceString
    Write-Output "User: $($user.SamAccountName), Current: $($user.HomeDirectory), New: $newHomeDirectory"
}

# Ask for confirmation
$response = Read-Host "Do you want to proceed with these changes? (Y/N)"
if ($response -eq 'Y') {
    # Iterate over the users and update their home directory
    foreach ($user in $usersWithHomeFolder) {
        # Replace the findString with replaceString in the user's home directory path
        $newHomeDirectory = $user.HomeDirectory -replace [regex]::Escape($findString), $replaceString

        # Update the user's home directory in AD
        Set-ADUser -Identity $user.DistinguishedName -HomeDirectory $newHomeDirectory

        # Output the updated information
        Write-Output "Updated user: $($user.SamAccountName), New Home Directory: $newHomeDirectory"
    }
    Write-Output "Home directories update complete."
} else {
    Write-Output "Operation cancelled. No changes were made."
}
