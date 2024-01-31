
# DCHealthCheck

This PowerShell script checks the health of all domain controllers in the current Active Directory domain. It performs various checks, including replication status, service status, network accessibility, and share availability.

## Prerequisites

- Active Directory PowerShell module.
- Appropriate permissions to access and manage domain controllers.

## Installation

No installation is required. However, the script automatically installs the Active Directory PowerShell module if it is not already available.

## Usage

Run the script in PowerShell:

```powershell
PS> .\Check-DomainControllerHealth.ps1
```

## Features

- Checks replication status, service status, network accessibility, and share availability of domain controllers.
- Installs the Active Directory PowerShell module if necessary.
- Reports on SYSVOL replication mechanism (DFSR or FRS).
- Checks disk space related to SYSVOL.
- Validates the "Manage Auditing and Security Log" policy.
- Performs SYSVOL and NETLOGON share accessibility checks.
- Reports on FSMO roles in the domain.

## Author

Erik Sikich - [GitHub](https://github.com/esikich)

## Notes

- Intended for environments with PowerShell remoting and necessary AD permissions enabled.
- Always test in a non-production environment before deploying in a live setting.
