
# FRS to DFSR SYSVOL Migration Script

This PowerShell script automates the migration process from File Replication Service (FRS) to Distributed File System Replication (DFSR) SYSVOL in Active Directory environments. It is designed to facilitate the migration through three main stages: Prepared, Redirected, and Eliminated, by setting the global state and monitoring the migration state on all domain controllers until each state is fully reached.

## Author

Erik Sikich

- GitHub: [esikich](https://github.com/esikich)

## Date

January 25, 2024

## Prerequisites

- PowerShell Version: 5.1 or higher
- It is highly recommended to test the script in a controlled environment before executing it in a production setting.

## Usage

To start the migration process, execute the script from the PowerShell command line:

```powershell
.\MigrateFRStoDFSR.ps1
```

## Functionality

The script contains a function `Migrate-SysvolState` that is responsible for:

1. Setting the global migration state to either Prepared (1), Redirected (2), or Eliminated (3).
2. Monitoring the migration state across all domain controllers.
3. Ensuring that all domain controllers have successfully migrated to the target global state before proceeding.

## Version

1.0

## Notes

- Ensure you have administrative privileges to run this script.
- Monitor the migration process closely for any errors or warnings that may arise.
