# Get all currently mapped drives
$mappedDrives = Get-PSDrive -PSProvider FileSystem

Write-Host "Checking mapped drives..."

foreach ($drive in $mappedDrives) {
    Write-Host "Checking drive: $($drive.Name)"

    # Check if the drive's DisplayRoot contains 'delphi2008'
    if ($drive.DisplayRoot -like "*delphi2008*") {
        Write-Host "Found matching drive: $($drive.Name) with path $($drive.DisplayRoot)"

        # Extract the drive letter
        $driveLetter = $drive.Name + ":"

        # Replace 'delphi2008' with 'FS01' in the path
        $newPath = $drive.DisplayRoot -replace 'delphi2008', 'FS01'

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
