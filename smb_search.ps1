function Quick-Ping {
    param(
        [string]$IPAddress,
        [int]$TimeoutMilliSeconds = 100
    )
    $ping = New-Object System.Net.NetworkInformation.Ping
    $reply = $ping.Send($IPAddress, $TimeoutMilliSeconds)
    return $reply.Status -eq 'Success'
}

# Define the range of IP addresses to scan
$ipRangeStart = "192.168.1.1"
$ipRangeEnd = "192.168.1.254"

# Convert IP range to a sequence of IP addresses
$ipStart = [System.Net.IPAddress]::Parse($ipRangeStart).GetAddressBytes()
[System.Array]::Reverse($ipStart)
$ipEnd = [System.Net.IPAddress]::Parse($ipRangeEnd).GetAddressBytes()
[System.Array]::Reverse($ipEnd)
$start = [System.BitConverter]::ToUInt32($ipStart, 0)
$end = [System.BitConverter]::ToUInt32($ipEnd, 0)
$totalIps = $end - $start + 1
$currentIp = 0
$aliveIps = New-Object System.Collections.Generic.List[System.Net.IPAddress]

# Scan the network
Write-Host "Scanning network..."
for ($i = $start; $i -le $end; $i++) {
    $currentIp++
    $ipBytes = [System.BitConverter]::GetBytes($i)
    [System.Array]::Reverse($ipBytes)
    $ip = New-Object System.Net.IPAddress -ArgumentList (,[System.Byte[]]$ipBytes)

    Write-Progress -Activity "Scanning Network" -Status "$ip" -PercentComplete (($currentIp / $totalIps) * 100)

    if (Quick-Ping -IPAddress $ip) {
        $aliveIps.Add($ip)
    }
}

# Scan each alive IP address for SMB shares
foreach ($ip in $aliveIps) {
    try {
        $netViewOutput = net view \\$ip /all 2>&1
        if ($netViewOutput -notlike '*The command completed successfully*') {
            throw $netViewOutput
        }

        $shares = $netViewOutput | Where-Object { $_ -like '*Disk*' } | ForEach-Object { $_.Trim() -split '\s+' | Select-Object -First 1 }
        foreach ($share in $shares) {
            Write-Output "Share found: $share on $ip"
        }
    } catch {
        Write-Warning "Failed to retrieve shares from $ip. Error: $_"
    }
}
