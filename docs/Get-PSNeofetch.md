---
Module Name: linuxinfo
online version: https://github.com/ehmiiz/linuxinfo
schema: 2.0.0
---

# Get-PSNeofetch

## SYNOPSIS

Displays system information in a neofetch-like format with ASCII art.

## SYNTAX

```
Get-PSNeofetch [[-AsciiDistro] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Get-PSNeofetch is a lightweight PowerShell implementation of the popular neofetch command.
It displays system information alongside ASCII art, automatically detecting the
environment (WSL, Ubuntu, Fedora) and showing the appropriate logo.

The function displays:

- Username and hostname
- OS details and kernel version
- System uptime
- Shell version (pwsh)
- CPU information
- Architecture
- GPU details
- Display resolution (when available)
- Memory usage
- Network IP (when available)
- Battery status (when available)
- Disk usage

The ASCII art is automatically selected based on:

- WSL detection (Windows logo)
- Ubuntu detection (Ubuntu logo)
- Fedora detection (Fedora logo)
- Default fallback to Windows logo

## EXAMPLES

### EXAMPLE 1

```
Get-PSNeofetch
```

Shows system information with colored ASCII art based on the detected environment.

## PARAMETERS

### -AsciiDistro

'Ubuntu', 'Fedora' or 'Windows'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Windows
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction

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

## NOTES

Author: Ehmiiz

Dependencies:
    - Get-ComputerInfo
    - Get-OSInfo
    - Get-DisplayInfo
    - Get-NetworkInfo
    - Get-SystemUptime
    - Get-BatteryInfo

The function uses ANSI color codes for output formatting:

- Green: Username@hostname
- Red: Information labels
- Default: Information values

## RELATED LINKS

[https://github.com/ehmiiz/linuxinfo](https://github.com/ehmiiz/linuxinfo)
