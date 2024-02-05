# PowerShellToolbox
A collection of PowerShell scripts

## DC Health Check
### Domain Controller Health Check
A tool crafted for evaluating the operational state of domain controllers in an Active Directory environment. It performs a series of checks such as replication status, service functionality, network accessibility, and share availability. Additionally, it assesses the health of SYSVOL, runs diagnostic tests, and lists FSMO roles, aiding administrators in identifying and resolving potential issues to maintain the stability and efficiency of the domain infrastructure.

## Fast RoboCopy
### Fast RoboCopy
Designed for file synchronization between two directories. The script employs a custom function, Buffered-Write, to manage the output from Robocopy operations efficiently. This function buffers a specified number of lines before writing them to the log file, aiming to optimize performance by reducing the number of write operations to disk and console by buffering them in memory.

## frs_dfsr_migrate.ps1
### FRS to DFSR SYSVOL Migration Script
Designed to automate the migration process from File Replication Service (FRS) to Distributed File System Replication (DFSR) for the SYSVOL folder in Active Directory environments. This script facilitates a smooth and monitored transition through the three critical states of the migration process: Prepared, Redirected, and Eliminated.

## smb_search.ps1
### Search for SMB Shares
A script to scan the network and check for SMB file shares.

## home_folder_update.ps1
### Update home folders with new server name
This script allows you to find and replace a string in AD user's home folders, eg. for a server upgrade/migration.
