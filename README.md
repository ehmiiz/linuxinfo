# linuxinfo

Get valuable information on a linux system using PowerShell!

<p align="center">
  <img src="linuxinfoico.png" />
</p>

## Install locally using the build script.


```powershell
./build.ps1
```

### To reinstall the module (if you've done local edits)

```powershell
./build.ps1 -Force
```

## Install from PowerShellGallery (not published yet)

```powershell
Install-Module linuxinfo -Verbose
Import-Module linuxinfo -Force -Verbose
```

## Completed functions:

- Get-FileSystemHelp (help data on `/`, json format with navigation)
- Get-BatteryInfo (`upower` parser)
- Get-SystemUptime (`uptime` parser) (Get-Uptime exists in Linux, so this function is a bit redundant but was fun to write.)
- Get-ComputerInfo
- Get-OSInfo (Gets install date, os version, `cat /etc/os-release`)
- Get-DisplayInfo (`lspci` parser)
- Get-NetworkInfo (gets network adapter info)


## Planned functions:

- Get-PeripheralInfo (gets usb, bluetooth devices, cameras, microphones)


## Testing

The module is tested on the following linux dists:

- Fedora (RHEL based)
- Ubuntu (Debian based)