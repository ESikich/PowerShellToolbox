
# Domain Controller Health Check Script

## Overview
Designed to assess the health of all domain controllers within an Active Directory domain. It's a comprehensive tool for system administrators and IT professionals to maintain the operational efficiency and integrity of domain controllers.

## Features
- **Active Directory Module Check**: Ensures the Active Directory PowerShell module is installed and loaded.
- **FSMO Roles Display**: Lists the FSMO roles within the domain.
- **SYSVOL Replication Check**: Determines the replication mechanism for the SYSVOL folder.
- **Disk Space Verification**: Evaluates the disk space for the SYSVOL directory.
- **Service Status Inspection**: Checks the status of key services like NTDS, DNS, KDC, and Netlogon.
- **Network Accessibility and Share Availability**: Verifies network accessibility and the availability of critical shares.
- **Security Policy Compliance**: Examines specific security policy settings.
- **Diagnostic Tests**: Performs checks on SYSVOL and advertising using the `dcdiag` tool.

## Prerequisites
- PowerShell remoting enabled
- Necessary Active Directory permissions
- Active Directory PowerShell module

## Usage
```powershell
PS> .\Check-DomainControllerHealth.ps1
```

## Testing
Always test the script in a non-production environment before deploying it in a live setting.

## Author
Erik Sikich
[GitHub](https://github.com/esikich)

## License
This script is provided as-is, with no warranties. It is free to use and modify. Always review and test the script before using it in your environment.
