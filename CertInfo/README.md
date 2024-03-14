# Check Certificate PowerShell Script

This PowerShell script is designed to check for a specific certificate by its thumbprint on the local machine and, optionally, on a remote server (the issuer's server).

## Features

- Searches for a certificate with a given thumbprint across various certificate stores on the local machine.
- Displays details about the found certificate, such as its location, subject, issuer, expiration date, and validity status.
- Optionally connects to the issuer's server to perform a similar check and display the certificate details there.

## Prerequisites

Ensure PowerShell remoting is enabled and configured on the target remote server if you intend to check the issuer's server.
