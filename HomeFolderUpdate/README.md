H# Active Directory Home Directory Update Script

## Overview
This PowerShell script is designed to automate the process of updating the home directory paths for users in Active Directory. It searches for users whose home directory is currently set to a specific server path and updates it to a new server path.

## Features
- **Bulk Update:** Capable of updating home directories for all users in Active Directory with a specified old server path.
- **Confirmation Prompt:** Asks for confirmation before applying any changes, ensuring that changes are intentional.
- **Verbose Output:** Displays the current and new home directory paths for each user before and after the update for review and verification.

## Prerequisites
- PowerShell 5.1 or higher.
- Active Directory module for Windows PowerShell.
- Appropriate permissions to read user objects and modify the `HomeDirectory` attribute in Active Directory.

## Usage
1. **Import the Active Directory Module:** Ensure the Active Directory module is imported into your PowerShell session.
    ```powershell
    Import-Module ActiveDirectory
    ```
2. **Configure Script Variables:** Modify the `$findString` and `$replaceString` variables in the script to match your old and new server paths respectively.
    - `$findString`: The current home directory path to search for.
    - `$replaceString`: The new home directory path to replace with.
3. **Execute the Script:** Run the script in a PowerShell session. It will automatically search for users with home directories containing the old path, display the proposed changes, and ask for confirmation before proceeding.

## Confirmation
Upon execution, the script will list all users affected by the change and their proposed new home directory paths. It requires user confirmation (`Y` for yes) to proceed with the updates.

## Important Notes
- Always test the script in a non-production environment before running it in production.
- Ensure you have backups of your Active Directory data to prevent any accidental loss of information.
- The script provides output for each updated user for verification purposes.

## License
This script is provided "as is", without warranty of any kind, express or implied. Use it at your own risk.
