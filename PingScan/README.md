
# Ping Scan

## Overview
This PowerShell script is designed for network discovery within a specified subnet. It efficiently scans a range of IP addresses to identify active devices by pinging them and then attempts to retrieve their MAC addresses from the ARP table. This tool is invaluable for network administrators seeking to map out devices on a network.

## Features
- Generates a range of IP addresses based on a given subnet prefix.
- Utilizes parallel processing for efficient scanning.
- Identifies active devices by pinging their IP addresses.
- Retrieves MAC addresses of active devices by querying the ARP table.
- Outputs a list of discovered devices, including their IP and MAC addresses.

## Prerequisites
- PowerShell 7.0 or higher (for `-Parallel` feature support).
- Network access and permissions to use `Test-Connection` and `arp` commands.

## Configuration
To target a different subnet, modify the `$subnet` variable at the beginning of the script to the desired prefix. For example, to scan the subnet `10.0.0.`, set `$subnet = "10.0.0."`.

## Contributing
Contributions to this project are welcome! Please fork the repository, make your changes, and submit a pull request.

## License
This script is provided "as is", without warranty of any kind. You are free to use and modify it for personal or commercial purposes at your own risk.
