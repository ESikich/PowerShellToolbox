# Define the subnet prefix
$subnet = "192.168.4."
# Create an array of all IP addresses in the range
$ipRange = 1..255 | ForEach-Object { "$subnet$_" }

# Run the operations in parallel using ForEach-Object -Parallel
$result = $ipRange | ForEach-Object -Parallel {
    # Inside the parallel script block, $_ refers to the current IP address
    $ip = $_

    # Ping the IP address
    if (Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue) {
        # If the ping is successful, look up the MAC address in the ARP table
        $arpResult = arp -a $ip | Out-String
        if ($arpResult -match "\s$ip\s+([\da-fA-F\-]+)") {
            $macAddress = $matches[1]
            # Output the IP and MAC address
            return "$ip - $macAddress"
        }
    }
} -ThrottleLimit 20

# Display the results
$result | Where-Object { $_ } | ForEach-Object { Write-Host $_ }
