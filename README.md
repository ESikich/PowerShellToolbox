# PowerShellToolbox
A collection of PowerShell scripts

## DC Health Check
A tool crafted for evaluating the operational state of domain controllers in an Active Directory environment. It performs a series of checks such as replication status, service functionality, network accessibility, and share availability. Additionally, it assesses the health of SYSVOL, runs diagnostic tests, and lists FSMO roles, aiding administrators in identifying and resolving potential issues to maintain the stability and efficiency of the domain infrastructure.

## Fast RoboCopy
Designed for file synchronization between two directories. The script employs a custom function, Buffered-Write, to manage the output from Robocopy operations efficiently. This function buffers a specified number of lines before writing them to the log file, aiming to optimize performance by reducing the number of write operations to disk and console by buffering them in memory.

## MappedDriveUpdate
Simplifies the migration process for users or administrators moving resources to a new server.
Automates the process of updating network drive mappings from an old server to a new one.
Identifies all drives mapped to the old server, removes these mappings, and then creates new mappings to the new server with the same drive letters.
Checks each mapped drive against the old server's name, and if a match is found, it executes the update process using the net use command for persistent mappings.

## FRS to DFSR SYSVOL Migration
Automates the migration of SYSVOL replication from File Replication Service (FRS) to Distributed File System Replication (DFSR) in Active Directory environments. The script progresses through three key migration states—Prepared, Redirected, and Eliminated—using the Dfsrmig command to set the global state and verify the migration status on all domain controllers until each state is fully achieved. It includes a function, Migrate-SysvolState, to manage the migration process, with pauses to ensure that all domain controllers reach the required state before proceeding to the next.

## smb_search.ps1
### Search for SMB Shares
A script to scan the network and check for SMB file shares.

## home_folder_update.ps1
### Update home folders with new server name
This script allows you to find and replace a string in AD user's home folders, eg. for a server upgrade/migration.
