# PowerShellToolbox
A collection of PowerShell scripts

## <a href="https://github.com/ESikich/PowerShellToolbox/tree/main/ActiveDirectoryUserLogonDetails">Active Directory User Logon Details</a>

Retrieves active users from Active Directory with logon scripts or home folders mapped, displaying their username, script name, home folder, and last logon time in a formatted table.

**Features:**
- Retrieves active users with logon scripts or home folders mapped
- Displays username, script name, home folder, and last logon time
- Useful for administrators auditing user account configurations and activity

## <a href="https://github.com/ESikich/PowerShellToolbox/tree/main/AD_Stale_PCs">Active Directory Stale Computers Analyzer</a>

Retrieves all computers from Active Directory, sorts them by last logon date, checks for the most recent logon event in the security logs, and displays results in a sorted table.

**Features:**
- Fetches all computer objects from Active Directory, including their last logon date.
- Sorts computers by their last logon date in descending order.
- Queries the Security event log on the local domain controller for the most recent logon event for each computer (Event IDs 4768 and 4624).
- Compiles results into a hashtable with computer name, last logon date from AD, and the most recent logon event time.
- Sorts the final results by the most recent logon event time and displays them in a formatted table.

## <a href="https://github.com/ESikich/PowerShellToolbox/tree/main/CertInfo">Certificate Checker</a>

A PowerShell script to search for a specific certificate by its thumbprint on the local machine and optionally on a remote server (the issuer's server).

**Features:**
- Searches for a certificate with a given thumbprint across various certificate stores on the local machine
- Displays details about the certificate, including its location, subject, issuer, expiration date, and validity status
- Attempts to remotely connect to the issuer's server to perform a similar check if the issuer's server can be determined

## <a href="https://github.com/ESikich/PowerShellToolbox/tree/main/DCHealthCheck">Domain Controller Health Check</a>

Checks the health of all domain controllers in the current Active Directory domain.

- **SYSVOL Replication**: Determines the replication mechanism (DFSR or FRS) for SYSVOL.
- **Service Statuses**: Checks the status of key services like NTDS, DNS, KDC, and Netlogon.
- **Network Accessibility**: Verifies if the domain controller is reachable over the network.
- **Share Statuses**: Checks the accessibility of SYSVOL and NETLOGON shares.
- **Disk Space**: Evaluates SYSVOL size and available disk space.
- **Security Policy**: Verifies if the "Manage Auditing and Security Log" policy is properly set.
- **SYSVOL and Advertising**: Checks the SYSVOL and advertising status.

## <a href="https://github.com/ESikich/PowerShellToolbox/tree/main/FRS_DFSR_Migration">FRS_DFSR_Migration</a>

A PowerShell script designed to automate the transition from File Replication Service (FRS) to Distributed File System Replication (DFSR) SYSVOL in Active Directory, streamlining the process through specific migration stages.

### Features

- **Automated Migration Stages**: Handles the migration through the Prepared, Redirected, and Eliminated stages by setting and monitoring the global state.
- **State Monitoring**: Checks the migration state on all domain controllers to ensure each stage is fully achieved before moving to the next.
- **Function `Migrate-SysvolState`**: This key function manages the migration state, ensuring all domain controllers reach the desired state synchronously.


## <a href="https://github.com/ESikich/PowerShellToolbox/tree/main/FRS_DFSR_Migration">Fast RoboCopy</a>
Designed for file synchronization between two directories. The script employs a custom function, Buffered-Write, to manage the output from Robocopy operations efficiently. This function buffers a specified number of lines before writing them to the log file, aiming to optimize performance by reducing the number of write operations to disk and console by buffering them in memory.

## Home Folder Update
Updates Active Directory (AD) user home directories from an old server path to a new one. Retrieves AD users whose home directories reference the old server, displaying the proposed new paths for user confirmation. Upon agreement, it systematically updates each user's home directory attribute in AD to reflect the new server path. Includes a confirmation step to proceed with the updates.

## MappedDriveUpdate
Simplifies the migration process for users or administrators moving resources to a new server.
Automates the process of updating network drive mappings from an old server to a new one.
Identifies all drives mapped to the old server, removes these mappings, and then creates new mappings to the new server with the same drive letters.
Checks each mapped drive against the old server's name, and if a match is found, it executes the update process using the net use command for persistent mappings.

## PingScan

A script designed for network administrators to conduct network discovery within a specified subnet, identifying active devices and gathering essential network information.

### Features

- **IP Range Generation**: Creates a range of IP addresses from a specified subnet prefix.
- **Parallel Processing**: Enhances efficiency by scanning multiple IP addresses simultaneously.
- **Device Detection**: Determines active devices by sending ping requests.
- **MAC Address Retrieval**: Obtains MAC addresses from the ARP table for active devices.
- **Discovery Output**: Lists discovered devices, detailing their IP and MAC addresses, aiding in network mapping and inventory.

## SearchADAndGPO

A PowerShell script designed for administrators to search for specific strings within all attributes of Active Directory (AD) objects and all settings of Group Policy Objects (GPOs), providing a thorough audit tool for AD and GPO configurations.

#### Features

- **Comprehensive AD Scan**: Examines all attributes of AD objects for a user-defined string.
- **GPO Analysis**: Creates and searches through XML reports of GPOs for the specified string.
- **Progress Feedback**: Offers real-time progress updates during the scanning process in the PowerShell console.

## smb_search.ps1
### Search for SMB Shares
A script to scan the network and check for SMB file shares.
