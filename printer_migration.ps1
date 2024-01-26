<#
.SYNOPSIS
This PowerShell script migrates printers from an old server to a new server.

.DESCRIPTION
The script automates the process of exporting printer configurations from an old server and importing them to the new server using PrintBrm.exe. It checks for the existence of the 'print$' share which is necessary for printer migration.

.NOTES
Make sure that the 'print$' share is created on the new server before running this script.

#>

# Check for 'print$' share existence
$printShare = Get-SmbShare -Name "print$" -ErrorAction SilentlyContinue
if (-not $printShare) {
    Write-Host "Error: 'print$' share not found. Please create it before running this script." -ForegroundColor Red
    Exit
}

# Define the old and new server names
$oldServerName = "OldServerName"  # Replace with your old server's name
$newServerName = $env:COMPUTERNAME  # Gets the name of the current computer
$backupPath = "C:\PrinterMigration"  # Local path on the new server for saving the backup
$printBrmPath = "C:\Windows\System32\spool\tools"  # Path to PrintBrm.exe

# Ensure the backup directory exists
if (!(Test-Path -Path $backupPath)) {
    New-Item -ItemType Directory -Path $backupPath
}

# Define the path for the printer export file
$exportFilePath = Join-Path $backupPath "Printers.printerExport"

# Save the current directory and change to where PrintBrm.exe is located
Push-Location
Set-Location -Path $printBrmPath

# Step 1: Export the printers from the old server
& .\PrintBrm.exe -B -S \\$oldServerName -F $exportFilePath -O FORCE

# Check if the export was successful
if (Test-Path -Path $exportFilePath) {
    Write-Host "Printer export successful. File saved to: $exportFilePath"

    # Step 2: Import the printers to the new server
    & .\PrintBrm.exe -R -S \\$newServerName -F $exportFilePath

    Write-Host "Printers have been imported to the new server: $newServerName"
} else {
    Write-Host "Failed to export printers from the old server: $oldServerName" -ForegroundColor Red
}

