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

# Scan each IP address in the range
for ($i = $start; $i -le $end; $i++)
{
    $currentIp++
    $ipBytes = [System.BitConverter]::GetBytes($i)
    [System.Array]::Reverse($ipBytes)
    $ip = [System.Net.IPAddress]::new($ipBytes)

    Write-Host "Scanning IP: $ip ($currentIp of $totalIps)"
    Write-Progress -Activity "Scanning Network for SMB Shares" -Status "$ip" -PercentComplete (($currentIp / $totalIps) * 100)

    # Check if the IP is reachable
    if(Test-Connection -ComputerName $ip -Count 1 -Quiet)
    {
        try
        {
            # Query SMB shares on the IP address
            $shares = Get-SmbShare -CimSession $ip -ErrorAction Stop
            if($shares)
            {
                foreach($share in $shares)
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
}
