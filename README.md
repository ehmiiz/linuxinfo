# LinuxInfo

A PowerShell module for retrieving comprehensive Linux system information with a familiar PowerShell syntax.

<p align="center">
  <img src="linuxinfoico.png" />
</p>

## Overview

LinuxInfo provides PowerShell-native commands to gather detailed system information on Linux systems. It bridges the gap between PowerShell and Linux system commands, offering familiar PowerShell syntax for system information retrieval.

## Features

- **System Information**
  - Comprehensive computer information (`Get-ComputerInfo`)
  - Detailed OS information (`Get-OSInfo`)
  - System uptime statistics (`Get-SystemUptime`)

- **Hardware Details**
  - Battery status and health (`Get-BatteryInfo`)
  - Display and graphics information (`Get-DisplayInfo`)
  - USB device management (`Get-USBInfo`)

- **Network & Storage**
  - Network adapter configuration (`Get-NetworkInfo`)
  - Filesystem navigation help (`Get-FileSystemHelp`)

## Installation

### From PowerShellGallery (Recommended)

```powershell
Install-Module linuxinfo -Verbose
```

### Local Development Installation

```powershell
./build.ps1
```

To reinstall the module (for development):

```powershell
./build.ps1 -Force
```

## Available Commands

### System Information

- `Get-ComputerInfo` - Retrieves comprehensive system information
- `Get-OSInfo` - Displays detailed OS information including install date and version
- `Get-SystemUptime` - Shows system uptime information

### Hardware Information

- `Get-BatteryInfo` - Provides detailed battery status and health information
- `Get-DisplayInfo` - Shows graphics and display adapter information
- `Get-USBInfo` - Lists all USB devices connected to the system

### Network & Storage

- `Get-NetworkInfo` - Retrieves network adapter information and configuration
- `Get-FileSystemHelp` - Provides filesystem navigation help in JSON format

## Requirements

- PowerShell 6.0.0 or later
- Linux Operating System
- Required Linux utilities: 
  - upower (for battery information)
  - lspci (for display information)
  - Various standard Linux commands

## Documentation

Detailed documentation for each command is available through PowerShell's built-in help system:

```powershell
Get-Help Get-OSInfo -Full
Get-Help Get-ComputerInfo -Detailed
```

## Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

Please ensure your code follows PowerShell best practices and includes appropriate documentation.

## Testing

The module is actively tested on:

- Fedora (RHEL based)
- Ubuntu (Debian based)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Version History

- 1.0.0: First stable release
  - Complete core functionality
  - Improved error handling
  - Enhanced documentation
  - Tested on major Linux distributions

## Support

For issues, feature requests, or questions, please open an issue on GitHub.

## Completed functions

- Get-FileSystemHelp (help data on `/`, json format with navigation)
- Get-BatteryInfo (`upower` parser)
- Get-SystemUptime (`uptime` parser) (Get-Uptime exists in Linux, so this function is a bit redundant but was fun to write.)
- Get-ComputerInfo
- Get-OSInfo (Gets install date, os version, `cat /etc/os-release`)
- Get-DisplayInfo (`lspci` parser)
- Get-NetworkInfo (gets network adapter info)
- Get-USBInfo (gets usb devices)

## Contributions

Feel free to open issues, PRs or anything else to contribute to the module.
