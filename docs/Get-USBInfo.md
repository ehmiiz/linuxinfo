---
external help file: linuxinfo-help.xml
Module Name: linuxinfo
online version:
schema: 2.0.0
---

# Get-USBInfo

## SYNOPSIS
Gets information about USB devices connected to the system.

## SYNTAX

```
Get-USBInfo [-Full] [[-Id] <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves basic information about USB devices from lsusb command.
Each device is returned as a PowerShell object with standardized properties.
Use -Full to include detailed troubleshooting data.

## EXAMPLES

### EXAMPLE 1
```
Get-USBInfo
Lists all USB devices with basic information.
```

### EXAMPLE 2
```
Get-USBInfo -Id 1
Gets information for a specific USB device.
```

### EXAMPLE 3
```
Get-USBInfo -Full
Lists all USB devices including detailed troubleshooting data.
```

### EXAMPLE 4
```
Get-USBInfo -Id 1 -Full
Gets detailed information for a specific USB device.
```

### EXAMPLE 5
```
$devices = Get-USBInfo
$devices | Where-Object VendorID -eq '0951'
Gets all USB devices and filters for a specific vendor.
```

## PARAMETERS

### -Full
If specified, includes detailed troubleshooting data from lsusb -v -d
for each device.

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

### -Id
Specifies a specific device ID to return.
The ID is the sequential number
shown in the basic listing (1,2,3...).

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 0
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

## OUTPUTS

### [PSCustomObject[]] USBDevice objects containing:
### * Id          - Sequential device number (1,2,3...)
### * Bus         - USB bus number
### * Device      - Device number on bus
### * VendorID    - Vendor ID (hex)
### * ProductID   - Product ID (hex) 
### * DeviceID    - Combined VendorID:ProductID format
### * Description - Device description
### When -Full is specified, adds:
### * TroubleshootingData - Raw output from lsusb -v -d
## NOTES
Requires lsusb command to be available on the system.
The DeviceID property can be used directly with 'lsusb -v -d'.

## RELATED LINKS
