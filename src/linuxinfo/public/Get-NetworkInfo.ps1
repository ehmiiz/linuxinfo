function Get-NetworkInfo {
    <#
    .SYNOPSIS
        Gets network information on Linux systems.
    
    .DESCRIPTION
        Retrieves detailed network configuration including IP addresses, gateway,
        DNS servers, and MAC addresses using various Linux networking tools.
        Optionally can retrieve the public IP address.
    
    .PARAMETER IncludePublicIP
        When specified, includes the public IP address in the output by querying
        an external service (checkip.amazonaws.com).
    
    .INPUTS
        None. This function does not accept pipeline input.
    
    .OUTPUTS
        PSCustomObject with the following properties:
        - LocalIP: Local IP address
        - DefaultGateway: Default gateway address
        - DNSServers: Array of DNS server addresses
        - MACAddress: Physical (MAC) address
        - SubnetMask: Network subnet mask
        - PublicIP: Public IP address (if -IncludePublicIP is specified)
    
    .EXAMPLE
        Get-NetworkInfo
        Returns basic network information.
    
    .EXAMPLE
        Get-NetworkInfo -IncludePublicIP
        Returns network information including the public IP address.
    
    .NOTES
        Author: Emil Larsson
        Version: 2.0
        Requires: hostname, awk, ip, grep, cat
    #>
    [CmdletBinding()]
    param(
        [Parameter(HelpMessage="Include public IP address in the output")]
        [Switch]$IncludePublicIP
    )

    # Platform check
    if (-not $IsLinux) {
        Write-Error 'This function is only supported on Linux systems.' -ErrorAction Stop
    }

    # Verify required binaries
    if (-not (Resolve-BinDep -Bins @("hostname", "awk", "ip", "grep", "cat"))) {
        return
    }

    try {
        # Get local IP address
        $localIP = (hostname -I | awk '{print $1}').Trim()
        if (-not $localIP) {
            Write-Error "No local IP address found. Check network connectivity." -ErrorAction Stop
        }

        # Get default interface name
        $defaultInterface = $(ip route | grep default | awk '{print $5}')
        if (-not $defaultInterface) {
            Write-Warning "No default interface found. Some network information may be incomplete."
        }

        # Get network information
        $networkInfo = @{
            LocalIP = $localIP
            DefaultGateway = $null
            DNSServers = @()
            MACAddress = $null
            SubnetMask = $null
        }

        # Get default gateway
        $defaultGateway = (ip route show default | awk '{print $3}').Trim()
        if ($defaultGateway) {
            $networkInfo.DefaultGateway = $defaultGateway
        }

        # Get DNS servers
        $dnsServers = @(grep nameserver /etc/resolv.conf | awk '{print $2}' | Where-Object { $_ })
        if ($dnsServers) {
            $networkInfo.DNSServers = $dnsServers
        }

        # Get MAC address for default interface
        if ($defaultInterface) {
            $macAddress = (ip link show $defaultInterface | grep -i 'link/ether' | awk '{print $2}').Trim()
            if ($macAddress) {
                $networkInfo.MACAddress = $macAddress
            }
        }

        # Get subnet mask
        if ($defaultInterface) {
            $subnetMask = (ip addr show $defaultInterface | awk '/inet / {print $2}' | cut -d '/' -f 2).Trim()
            if ($subnetMask) {
                $networkInfo.SubnetMask = $subnetMask
            }
        }

        # Create base object
        $resultObject = [PSCustomObject]$networkInfo

        # Add public IP if requested
        if ($IncludePublicIP) {
            try {
                $publicIP = Invoke-RestMethod -Uri "https://checkip.amazonaws.com" -TimeoutSec 5
                Add-Member -InputObject $resultObject -MemberType NoteProperty -Name 'PublicIP' -Value $publicIP.Trim()
            }
            catch {
                Write-Warning "Could not retrieve public IP address: $_"
                Add-Member -InputObject $resultObject -MemberType NoteProperty -Name 'PublicIP' -Value "Unavailable"
            }
        }

        return $resultObject
    }
    catch {
        Write-Error "Failed to retrieve network information: $_" -ErrorAction Stop
    }
}