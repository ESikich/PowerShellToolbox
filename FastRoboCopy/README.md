# Fast Robocopy

This PowerShell script is designed to perform robust file copying (robocopy) with detailed logging. It is useful for backing up, mirroring, or migrating data with specific requirements.

## Features

- Copies files and folders from a specified source to a destination path.
- Creates a log file in `C:\temp` with detailed information about the copy process.
- Utilizes robocopy for efficient file transfer.
- Supports various robocopy options such as mirroring directories, copying security attributes, and multi-threading.

## Prerequisites

- Windows environment with PowerShell.
- Source and destination paths must be defined in the script.

## Usage

Modify the `$CopyPath` and `$TargetPath` variables in the script to specify the source and destination directories.

## Log File

The log file is created with a timestamp in its name for easy identification. It includes the start time, end time, and duration of the copy process, along with detailed information about the files copied.

## Script Options

- Robocopy flags for various copying requirements.
- Buffered writing to handle large amounts of log data efficiently.
- Error handling to capture any issues during the copying process.

## Notes

- Test the script with a small set of files before using it for large-scale copying.
- Review and customize robocopy options as per your requirements.
