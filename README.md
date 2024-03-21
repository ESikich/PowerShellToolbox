# PowerShellToolbox
A collection of PowerShell scripts

## [AD User Logon Details](https://github.com/ESikich/PowerShellToolbox/tree/main/ADUserLogonCheck)

Retrieves active users from AD with logon scripts or home folders mapped, displaying their username, script name, home folder, and last logon time in a formatted table.

- Retrieves active users with logon scripts or home folders mapped
- Displays username, script name, home folder, and last logon time
- Useful for administrators auditing user account configurations and activity

## [AD Stale Computers Analyzer](https://github.com/ESikich/PowerShellToolbox/tree/main/AD_Stale_PCs)

Retrieves all computers from AD, sorts them by last logon date, checks for the most recent logon event in the security logs, and displays results in a sorted table.

- Fetches all computer objects from AD, including their last logon date
- Sorts computers by their last logon date in descending order
- Queries the Security event log on the local domain controller for the most recent logon event for each computer (Event IDs 4768 and 4624)
- Compiles results into a hashtable with computer name, last logon date from AD, and the most recent logon event time
- Sorts the final results by the most recent logon event time and displays them in a formatted table

## [Certificate Checker](https://github.com/ESikich/PowerShellToolbox/tree/main/CertInfo)

A PowerShell script to search for a specific certificate by its thumbprint on the local machine and optionally on a remote server (the issuer's server).

- Searches for a certificate with a given thumbprint across various certificate stores on the local machine
- Displays details about the certificate, including its location, subject, issuer, expiration date, and validity status
- Attempts to remotely connect to the issuer's server to perform a similar check if the issuer's server can be determined

## [Domain Controller Health Check](https://github.com/ESikich/PowerShellToolbox/tree/main/DCHealthCheck)

Checks the health of all domain controllers in the current AD domain.

- **SYSVOL Replication**: Determines the replication mechanism (DFSR or FRS) for SYSVOL
- **Service Statuses**: Checks the status of key services like NTDS, DNS, KDC, and Netlogon
- **Network Accessibility**: Verifies if the domain controller is reachable over the network
- **Share Statuses**: Checks the accessibility of SYSVOL and NETLOGON shares
- **Disk Space**: Evaluates SYSVOL size and available disk space
- **Security Policy**: Verifies if the "Manage Auditing and Security Log" policy is properly set
- **SYSVOL and Advertising**: Checks the SYSVOL and advertising status

## [FRS to DFSR Migration](https://github.com/ESikich/PowerShellToolbox/tree/main/FRS_DFSR_Migration)

A PowerShell script designed to automate the transition from File Replication Service (FRS) to Distributed File System Replication (DFSR) SYSVOL in AD, streamlining the process through specific migration stages.

- **Automated Migration Stages**: Handles the migration through the Prepared, Redirected, and Eliminated stages by setting and monitoring the global state
- **State Monitoring**: Checks the migration state on all domain controllers to ensure each stage is fully achieved before moving to the next
- **Function `Migrate-SysvolState`**: This key function manages the migration state, ensuring all domain controllers reach the desired state synchronously

## [Fast RoboCopy](https://github.com/ESikich/PowerShellToolbox/tree/main/FastRoboCopy)

Designed for file synchronization between two directories. The script employs a custom function, Buffered-Write, to manage the output from Robocopy operations efficiently. This function buffers a specified number of lines before writing them to the log file, aiming to optimize performance by reducing the number of write operations to disk and console by buffering them in memory.

## [AD Home Directory Updater](https://github.com/ESikich/PowerShellToolbox/tree/main/HomeFolderUpdate)

A PowerShell script to update users' home directories in AD.

- **Search for Users**: Finds users with a home directory containing a specified string
- **Display Changes**: Displays proposed changes for home directory paths
- **Confirm Changes**: Prompts the user for confirmation before making updates
- **Update Home Directories**: Updates users' home directory paths in AD

## [Drive Mapping Update Script](https://github.com/ESikich/PowerShellToolbox/tree/main/MappedDriveUpdate)

A PowerShell script to update mapped drive paths from an old server to a new server.

- **Check Mapped Drives**: Checks all currently mapped drives
- **Update Mapped Drives**:
