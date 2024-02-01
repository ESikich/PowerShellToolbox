
## Description

This PowerShell script is designed to update the mapped network drives in a Windows environment. It automates the process of changing the server paths for all mapped drives that refer to an old server name, replacing it with a new server name. This is particularly useful during server migrations or reconfigurations where drive mappings need to be updated across numerous client machines.

## Features

- Automatically detects all currently mapped drives.
- Identifies and updates mappings that reference an old server name.
- Removes old drive mappings and creates new ones with updated server paths.
- Provides console output for each step of the process for easy tracking.

## Requirements

- Windows PowerShell 5.1 or newer.
- Appropriate permissions to execute PowerShell scripts and modify network drive mappings on the client machine.

## Installation

1. Download the PowerShell script from the link provided: [Download Script](#)
2. Save the script to a preferred location on your system.

## Usage

1. Open PowerShell as an Administrator.
2. Navigate to the directory where the script is saved.
3. Execute the script with the following command:

   ```powershell
   .\UpdateDriveMappings.ps1
   ```

4. The script will prompt for the old and new server names. Enter these when prompted to start the update process.

## Example

```powershell
# Define old and new server names inside the script or modify it to accept parameters
$oldServerName = "oldServerName"
$newServerName = "newServerName"

# Execute the script
.\UpdateDriveMappings.ps1
```

## Notes

- Ensure you have backup of your drive mappings or a way to restore them in case of any issues.
- It's recommended to test the script in a non-production environment first to ensure it behaves as expected.
