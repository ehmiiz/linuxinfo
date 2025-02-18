---
external help file: linuxinfo-help.xml
Module Name: linuxinfo
online version:
schema: 2.0.0
---

# Convert-USBDataToObject

## SYNOPSIS
Converts raw USB device data into structured PowerShell objects.

## SYNTAX

```
Convert-USBDataToObject [-Data] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Parses raw USB device information (typically from lsusb output) and converts it into 
structured PowerShell objects.
The function processes device headers, descriptors, and 
their properties, converting numeric values into appropriate types and organizing the 
data hierarchically.

## EXAMPLES

### EXAMPLE 1
```
$usbData = Get-Content -Path "./usb-output.txt" -Raw
$usbData | Convert-USBDataToObject
```

Converts the contents of a file containing USB device information into structured objects.

### EXAMPLE 2
```
# Get detailed information for a specific USB device and convert it to an object
$usbDevice = Convert-USBDataToObject -Data (Get-USBInfo -id 1 -full)
```

# Display all descriptor types
$usbDevice.Descriptors.Keys

# Examine specific descriptor properties
$usbDevice.Descriptors.Device.Properties
$usbDevice.Descriptors.Configuration.Properties

This example shows how to:
1.
Get detailed USB information for device ID 1
2.
Convert it to a structured object
3.
View available descriptor types
4.
Access specific descriptor properties

### EXAMPLE 3
```
# Get and analyze all USB devices with their descriptors
Get-USBInfo -full | Convert-USBDataToObject | ForEach-Object {
    Write-Host "Device: $($_.Manufacturer)" -ForegroundColor Yellow
    foreach ($descriptor in $_.Descriptors.Keys) {
        Write-Host "`nDescriptor: $descriptor" -ForegroundColor Cyan
        $_.Descriptors[$descriptor].Properties | Format-Table -AutoSize
    }
}
```

This example demonstrates how to:
1.
Get information for all USB devices
2.
Convert them to objects
3.
Format and display each device's descriptors in a readable way

## PARAMETERS

### -Data
The raw USB device data string to parse.
This is typically the output from lsusb or 
similar commands.
The data should contain device headers and descriptor information 
in a structured format.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Content

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

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

### [PSCustomObject] Objects containing structured USB device information with the following properties:
### - Bus: Integer representing the USB bus number
### - Device: Integer representing the device number
### - VendorId: String containing the vendor ID in hexadecimal
### - ProductId: String containing the product ID in hexadecimal
### - Manufacturer: String containing the manufacturer/device description
### - Descriptors: Hashtable of descriptor objects containing device properties
## NOTES

## RELATED LINKS
