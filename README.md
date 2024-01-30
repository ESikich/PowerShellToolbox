# PowerShellToolbox
A collection of PowerShell scripts

## dc_health_check.ps1
### Domain Controller Health Check Script
PowerShell script for checking the health of all domain controllers in an Active Directory domain. The script performs a variety of checks including replication status, service status, network accessibility, and share availability.

## frs_dfsr_migrate.ps1
### FRS to DFSR SYSVOL Migration Script
Designed to automate the migration process from File Replication Service (FRS) to Distributed File System Replication (DFSR) for the SYSVOL folder in Active Directory environments. This script facilitates a smooth and monitored transition through the three critical states of the migration process: Prepared, Redirected, and Eliminated.

## smb_search.ps1
### Search for SMB Shares
A script to scan the network and check for SMB file shares.

## home_folder_update.ps1
### Update home folders with new server name
This script allows you to find and replace a string in AD user's home folders, eg. for a server upgrade/migration.
