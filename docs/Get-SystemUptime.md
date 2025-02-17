---
external help file: linuxinfo-help.xml
Module Name: linuxinfo
online version:
schema: 2.0.0
---

# Get-SystemUptime

## SYNOPSIS
Gets system uptime information on Linux systems.

## SYNTAX

```
Get-SystemUptime [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves detailed system uptime information using the 'uptime' command.
Returns boot time, uptime duration, and a human-readable format.

Note: While this function provides a Linux-native way to get uptime,
consider using PowerShell's built-in Get-Uptime cmdlet for cross-platform
compatibility.

## EXAMPLES

### EXAMPLE 1
```
Get-SystemUptime
Returns system uptime information.
```

### EXAMPLE 2
```
(Get-SystemUptime).SystemUptime.Days
Returns just the number of days the system has been up.
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
### - SystemBootTime: DateTime when the system was last booted
### - SystemUptime: TimeSpan showing how long the system has been running
### - FriendlyView: Human-readable uptime string
### - LoadAverages: PSCustomObject containing 1, 5, and 15 minute load averages
## NOTES
Author: Emil Larsson
Version: 2.0
Requires: uptime

## RELATED LINKS
