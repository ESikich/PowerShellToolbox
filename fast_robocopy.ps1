$CopyPath = ""
$TargetPath = ""

$TimeStamp = Get-Date -Format 'yyyy-MM-dd'
$FileName = "C:\temp\Robocopy_$TimeStamp.log"

# Check if C:\temp exists, if not create it
if (-not (Test-Path -Path "C:\temp")) {
    New-Item -ItemType Directory -Path "C:\temp"
}

function Buffered-Write {
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]$InputObject,
        [int]$BufferSize = 1000  # Number of lines to buffer before writing
    )

    begin {
        # Initialize the buffer
        $buffer = @()
    }

    process {
        try {
            # Add input to the buffer
            $buffer += $InputObject

            # If buffer exceeds the specified size, write its content to the log file
            if ($buffer.Count -ge $BufferSize) {
                Add-Content -Path $FileName -Value $buffer
                Write-Output $FileName
                # Clear the buffer
                $buffer = @()
            }
        }
        catch {
            # In case of error, write the error message to the log file
            Add-Content -Path $FileName -Value "Error: $($_.Exception.Message)"
        }
    }

    end {
        try {
            # If there's any remaining content in the buffer, write it to the log file
            if ($buffer.Count -gt 0) {
                Add-Content -Path $FileName -Value $buffer
            }
        }
        catch {
            # In case of error, write the error message to the log file
            Add-Content -Path $FileName -Value "Error: $($_.Exception.Message)"
        }
    }
}

# Add a timestamp to the beginning of the temp file
$StartTimestamp = Get-Date
Add-Content -Path $FileName -Value "Script started at: $StartTimestamp"

# Capture the start time
$StartTime = Get-Date

# Robocopy Flags:
# /S: Copies subdirectories, excluding empty ones.
# /E: Copies subdirectories, including empty ones.
# /SEC: Copies files with security (equivalent to /COPY:DATS). 
# /MIR: Mirrors the source directory and the destination (deletes files in the destination not present in the source).
# /xo: Excludes older files - won't overwrite files at the destination that are newer than the source files.
# /R:1: Specifies the number of retries on failed copies. In this case, it will retry once.
# /W:1: Specifies the wait time between retries (in seconds). Here, it waits for 1 second.
# /nc: No class - don't log the file class.
# /np: No progress - don't display the progress percentage in the log.
# /njh: No job header - don't log the job header information.
# /MT:8: Multi-thread copies with 8 threads (available in Windows 7 and later).

Robocopy $CopyPath $TargetPath /S /E /SEC /MIR /FFT /xo /R:1 /W:1 /nc /np /njh /MT:4 | Buffered-Write

# Capture the end time
$EndTime = Get-Date

# Calculate the elapsed time
$ElapsedTime = $EndTime - $StartTime

# Add the end timestamp and elapsed time to the temp file
Add-Content -Path $FileName -Value "Script ended at: $EndTime"
Add-Content -Path $FileName -Value "Total time elapsed: $ElapsedTime"
