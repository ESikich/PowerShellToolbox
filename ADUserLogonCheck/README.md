# Active Directory User Logon Details Script

## Introduction
This PowerShell script is designed for system administrators to retrieve and display a list of active users from Active Directory who have a logon script, a home folder mapped, or both. Additionally, it shows the last logon time for each user, providing a clear view of user account configurations and recent activity.

## Prerequisites
Before running this script, ensure you have the following:
- PowerShell 5.1 or higher.
- Active Directory module for Windows PowerShell.
- Appropriate permissions to read Active Directory user objects.

## Usage
To use this script, follow these steps:
1. Open PowerShell as an administrator.
2. Navigate to the directory containing the script.
3. Run the script by typing `.\ADUserLogonDetails.ps1` and pressing Enter.

The script will output a table containing the usernames, script names, home folders, and last logon times of active users with a logon script or a mapped home folder.

## Customization
You can customize the script to include additional user properties by modifying the `-Properties` parameter in the `Get-ADUser` cmdlet call and adjusting the custom object creation section accordingly.

## Notes
- The `LastLogonDate` property is replicated across domain controllers, but there might be a slight delay. For the most accurate results, consider querying all domain controllers and using the most recent `LastLogonDate`.
- Running this script may require elevated permissions, depending on your domain's security policies.

## Contributing
Contributions to this script are welcome. Please ensure that any pull requests or issues adhere to the project's contribution guidelines.

## License
Specify the license under which this script is released, if applicable.

