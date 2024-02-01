# Define old and new server names
$oldServerName = "delphi2008"
$newServerName = "FS01"

# Get all currently mapped drives
$mappedDrives = Get-PSDrive -PSProvider FileSystem

Write-Host "Checking mapped drives..."

foreach ($drive in $mappedDrives) {
    Write-Host "Checking drive: $($drive.Name)"

    # Check if the drive's DisplayRoot contains the old server name
    if ($drive.DisplayRoot -like "*$oldServerName*") {
        Write-Host "Found matching drive: $($drive.Name) with path $($drive.DisplayRoot)"

        # Extract the drive letter
        $driveLetter = $drive.Name + ":"

        # Replace old server name with new server name in the path
        $newPath = $drive.DisplayRoot -replace $oldServerName, $newServerName

        Write-Host "New path will be: $newPath"

        # Remove the old mapping
        Write-Host "Removing old drive mapping..."
        Remove-PSDrive -Name $drive.Name -Force
        Start-Process cmd.exe -ArgumentList "/c net use $driveLetter /delete /y" -NoNewWindow -Wait

        # Create the new mapping with net use for persistence
        Write-Host "Creating new drive mapping..."
        Start-Process cmd.exe -ArgumentList "/c net use $driveLetter $newPath /persistent:yes" -NoNewWindow -Wait

        Write-Host "Drive mapping updated."
    } else {
        Write-Host "No match found for drive: $($drive.Name)"
    }
}

Write-Host "Script completed."

Read-Host "Press Enter to Exit"
