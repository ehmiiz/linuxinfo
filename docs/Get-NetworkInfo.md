---
external help file: linuxinfo-help.xml
Module Name: linuxinfo
online version:
schema: 2.0.0
---

# Get-NetworkInfo

## SYNOPSIS
Gets network information on Linux systems.

## SYNTAX

```
Get-NetworkInfo [-IncludePublicIP] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves detailed network configuration including IP addresses, gateway,
DNS servers, and MAC addresses using various Linux networking tools.
Optionally can retrieve the public IP address.

## EXAMPLES

### EXAMPLE 1
```
Get-NetworkInfo
Returns basic network information.
```

### EXAMPLE 2
```
Get-NetworkInfo -IncludePublicIP
Returns network information including the public IP address.
```

## PARAMETERS

### -IncludePublicIP
When specified, includes the public IP address in the output by querying
an external service (checkip.amazonaws.com).

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. This function does not accept pipeline input.
## OUTPUTS

### PSCustomObject with the following properties:
### - LocalIP: Local IP address
### - DefaultGateway: Default gateway address
### - DNSServers: Array of DNS server addresses
### - MACAddress: Physical (MAC) address
### - SubnetMask: Network subnet mask
### - PublicIP: Public IP address (if -IncludePublicIP is specified)
## NOTES
Author: Emil Larsson
Version: 2.0
Requires: hostname, awk, ip, grep, cat

## RELATED LINKS
