# Active Directory and GPO String Scanner

This PowerShell script is designed to comprehensively scan all Active Directory (AD) objects and Group Policy Objects (GPOs) for a specified string across all their attributes and settings. It provides real-time progress feedback through the PowerShell console.

## Features

- Scans all attributes of AD objects for the specified string.
- Generates and searches XML reports of GPOs for the specified string.
- Displays progress feedback during the scan.

## Prerequisites

Before running this script, ensure that you have:

- PowerShell 5.1 or higher.
- Active Directory and GroupPolicy PowerShell modules installed.
- Administrative privileges on the machine where the script is executed.
- Necessary permissions to read AD objects and GPOs in your domain.

## Usage

1. Open PowerShell with administrative privileges.
2. Navigate to the directory containing the script.
3. Execute the script:

    \`\`\`powershell
    .\\SearchADandGPO.ps1
    \`\`\`

4. Follow the progress in the PowerShell console. The script will output locations where the specified string is found.

## Customization

To search for a different string, modify the \`$searchString\` variable in the script:

\`\`\`powershell
$searchString = "YourSearchStringHere"
\`\`\`

## Caution

- This script may take a significant amount of time to complete, especially in large environments.
- Ensure you have a backup or recovery plan before making any changes based on the script's findings.

## Contributing

Contributions to improve the script are welcome. Please fork the repository, make your changes, and submit a pull request.
