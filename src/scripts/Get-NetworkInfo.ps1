function Get-NetworkInfo {
    [CmdletBinding()]
    param(
        [Switch]$IncludePublicIP
    )


    # Local IP
    $localIP = (hostname -I | awk '{print $1}').Trim()

    if ( -not $localIP) {
        Write-Error "No local IP was found. Check your network cable / wifi settings." -ErrorAction Stop
    }

    # netmask
    $subnetMask = ip addr show $(ip route | grep default | awk '{print $5}') | awk '/inet / {print $2}' | cut -d '/' -f 2

    # def gateway
    $defaultGateway = (ip route show default | awk '{print $3}').Trim()
    
    # local dns servers
    $dnsServers = (grep nameserver /etc/resolv.conf | awk '{print $2}').Trim()

    $macAddress = ip add | grep link/ether | awk '{print $2}'

    $Obj = [PSCustomObject]@{
        "LocalIP" = $localIP
        "DefaultGateway" = $defaultGateway
        "DNSServer(s)" = $dnsServers -split '\r\n'
        "MAC Address" = $macAddress
        "SubnetMask" = $subnetMask
    }

    if ($IncludePublicIP) {
        $PublicIP = Invoke-RestMethod -Uri "https://checkip.amazonaws.com"
        $Obj | Add-Member -MemberType NoteProperty -Name 'PublicIP' -Value $PublicIP 
    }

    return $Obj
}