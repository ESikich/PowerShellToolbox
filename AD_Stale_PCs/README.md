# Active Directory Computer Logon Report Script

## Description

This PowerShell script is designed to assist system administrators in monitoring and auditing computer account activities within an Active Directory (AD) environment. It retrieves all computer accounts from AD, sorts them by the last logon date, fetches the most recent logon event from the security logs, and displays a formatted table with the results. This tool is particularly useful for identifying inactive or rarely used computer accounts and ensuring that all machines are regularly communicating with the domain.

## Features

- Retrieves all computer accounts from Active Directory.
- Sorts computers by the last logon date recorded in AD.
- Queries the local domain controller's security logs for the most recent logon event for each computer.
- Displays a formatted table with computer names, last AD logon dates, and the most recent logon event times.
- Sorts the output by the most recent logon event to easily identify the most and least active computers.

## Prerequisites

- PowerShell v5.1 or higher
- Active Directory PowerShell module
- Execution policy set to allow script execution
- Appropriate permissions to query AD objects and read security logs

## Installation

No installation is required. Just download the `AD_Stale_PCs.ps1` script to your local machine or domain controller where you wish to run the report.

## Usage

To execute the script, navigate to the directory containing `AD_Stale_PCs.ps1` and run the following command in PowerShell:

```powershell
.\AD_Stale_PCs.ps1
