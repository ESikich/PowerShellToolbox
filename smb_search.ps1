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
$aliveIps = @()

# Ping scan to find alive IPs
Write-Host "Performing initial ping scan..."
for ($i = $start; $i -le $end; $i++)
{
    $currentIp++
    $ipBytes = [System.BitConverter]::GetBytes($i)
    [System.Array]::Reverse($ipBytes)
    $ip = [System.Net.IPAddress]::new($ipBytes)

    Write-Progress -Activity "Ping Scanning Network" -Status "$ip" -PercentComplete (($currentIp / $totalIps) * 100)

    if (Quick-Ping -IPAddress $ip)
    {
        $aliveIps += $ip
    }
}
Write-Host "Ping scan complete. Alive IPs found: $($aliveIps.Count)"

# Scan each alive IP address for SMB shares
foreach ($ip in $aliveIps)
{
    try
    {
        # Query SMB shares on the IP address
        $shares = Get-SmbShare -CimSession $ip -ErrorAction Stop
        if ($shares)
        {
            foreach ($share in $shares)
            {
                Write-Output "Share found: $($share.Name) on $ip"
            }
        }
    }
    catch
    {
        Write-Warning "Failed to retrieve shares from $ip"
    }
}
