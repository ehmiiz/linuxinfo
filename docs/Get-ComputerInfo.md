---
Module Name: linuxinfo
online version: https://github.com/ehmiiz/linuxinfo
schema: 2.0.0
---

# Get-ComputerInfo

## SYNOPSIS
Gathers detailed system information from a Linux system.

Gets a consolidated object of system and operating system properties.

## SYNTAX

```
Get-ComputerInfo [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Collects and returns comprehensive system information including:
- BIOS details (date, vendor, version)
- CPU information (model, architecture, threads, cores, sockets)
- Distribution details (name, version, support URL)
- System disk metrics (total, free, used space in GB)
- Graphics card information
- Memory information
- Kernel and OS details
- System information (manufacturer, product name, version, serial)

The function uses various Linux system commands and files:
- lscpu: CPU information
- uname: System and kernel information
- lspci: Graphics card details
- lsmem: Memory information
- /etc/os-release: Distribution details
- /sys/class/dmi/id/*: BIOS information (non-WSL)
- WMI queries: BIOS information (WSL)
- dmidecode: System information (requires sudo)


## EXAMPLES

### EXAMPLE 1
```
Get-ComputerInfo
Returns a detailed object containing system information.
```

### Example 1: Get detailed system information from the OS
```
Get-ComputerInfo
```


## PARAMETERS

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


## OUTPUTS

### PSCustomObject with the following properties:
### - BiosDate: DateTime of BIOS release
### - BiosVendor: Manufacturer of BIOS
### - BiosVersion: BIOS version string
### - CPU: Processor model name
### - CPUArchitecture: Processor architecture
### - CPUThreads: Total number of CPU threads
### - CPUCores: Total number of CPU cores
### - CPUSockets: Number of CPU sockets
### - DistName: Linux distribution name
### - DistSupportURL: Distribution's support URL
### - SystemDiskSize: Total system disk size
### - SystemDiskFree: Available disk space
### - SystemDiskUsed: Used disk space
### - GPU: Graphics card information
### - DistVersion: Distribution version
### - KernelRelease: Linux kernel version
### - OS: Operating system name
### - RAM: Total system memory
### - Manufacturer: System manufacturer
### - ProductName: System product name
### - SystemVersion: System version
### - SerialNumber: System serial number
### Microsoft.PowerShell.Management.ComputerInfo
This cmdlet returns a ComputerInfo object.

## NOTES
Author: Emil Larsson
Date: 2023-03-27

The script handles both native Linux and Windows Subsystem for Linux (WSL) environments,
using different methods to gather BIOS information in each case.


## RELATED LINKS

[linuxinfo](https://github.com/ehmiiz/linuxinfo).