---
external help file: linuxinfo-help.xml
Module Name: linuxinfo
online version:
schema: 2.0.0
---

# Get-BatteryInfo

## SYNOPSIS
Gets battery information on Linux systems using upower.

## SYNTAX

```
Get-BatteryInfo [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Uses the upower binary to gather detailed battery data on Linux systems.
Returns information including battery state, capacity, voltage, and estimated time remaining.
Requires the upower binary to be installed.

## EXAMPLES

### EXAMPLE 1
```
Get-BatteryInfo
Returns battery information for the system's primary battery.
```

## PARAMETERS

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
### - Model: Battery model information
### - State: Current battery state (charging/discharging)
### - IsRechargeable: Whether the battery is rechargeable
### - WarningLevel: Current warning level
### - Percentage: Current charge percentage
### - Capacity: Battery capacity percentage
### - Technology: Battery technology type
### - TimeToEmpty: Estimated time until battery depletion (if discharging)
### - Energy: Current energy level
### - EnergyFull: Maximum energy when fully charged
### - EnergyRate: Current energy consumption rate
### - Voltage: Current voltage
### - ChargeCycles: Number of charge cycles
## NOTES
Author: Emil Larsson
Version: 2.0
Requires: upower

## RELATED LINKS
