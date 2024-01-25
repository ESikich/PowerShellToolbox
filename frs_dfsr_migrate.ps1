<#
.SYNOPSIS
    PowerShell script to automate the migration from FRS to DFSR SYSVOL in Active Directory.

.DESCRIPTION
    This script automates the process of migrating FRS to DFSR SYSVOL across three states: Prepared, Redirected, and Eliminated. 
    It sets the global state and monitors the migration state on all domain controllers until each state is fully reached.

.AUTHOR
    Erik Sikich
    github.com/esikich

.DATE
    January 25, 2024

.NOTES
    Version:        1.0
    PowerShell Ver: 5.1 or higher
    Test the script in a controlled environment before executing in a production setting.

.EXAMPLE
    .\MigrateFRStoDFSR.ps1

#>

# Function to set global state and monitor migration state
function Migrate-SysvolState {
    param (
        [int]$GlobalState
    )

    # Set global state
    Dfsrmig /setglobalstate $GlobalState
    Write-Host "Global state set to $GlobalState. Migration in progress..."

    # Wait and monitor the migration state
    $allDCsReady = $false
    while (-not $allDCsReady) {
        Start-Sleep -Seconds 60 # Wait for 60 seconds before re-checking
        $output = Dfsrmig /getmigrationstate
        Write-Host $output

        # Check if all DCs are ready
        if ($output -like "*All domain controllers have migrated successfully to the global state*") {
            $allDCsReady = $true
        }
    }

    Write-Host "Migration to state $GlobalState completed."
}

# Start migration process

# Migrate to Prepared State
Write-Host "Migrating to Prepared State..."
Migrate-SysvolState -GlobalState 1

# Migrate to Redirected State
Write-Host "Migrating to Redirected State..."
Migrate-SysvolState -GlobalState 2

# Migrate to Eliminated State
Write-Host "Migrating to Eliminated State..."
Migrate-SysvolState -GlobalState 3

Write-Host "Migration process completed successfully."
