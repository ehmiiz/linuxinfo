function Get-NetworkInfo {
    [CmdletBinding()]
    param()

    # Local IP
    $localIP = (hostname -I | awk '{print $1}').Trim()
    
    # netmask
    $subnetMask = (ifconfig $(ip route | grep default | awk '{print $5}') | grep netmask | awk '{print $4}').Trim()

    # def gateway
    $defaultGateway = (ip route show default | awk '{print $3}').Trim()
    
    # pub ip
    $publicIP = (curl ifconfig.me 2>$null).Trim()
    
    # local dns servers
    $dnsServers = (grep nameserver /etc/resolv.conf | awk '{print $2}').Trim()

    $MacAddress = 'tbd'
    # tbd

    $ConnectedNetworkName = 'tbd'
    # tbd

    [PSCustomObject]@{
        "LocalIP" = $localIP
        "SubnetMask" = $subnetMask
        "DefaultGateway" = $defaultGateway
        "PublicIP" = $publicIP
        "DNSServer(s)" = $dnsServers -split '\r\n'
        "MAC Address" = $MacAddress
        "ConnectedNetworkName" = $ConnectedNetworkName
    }
}
