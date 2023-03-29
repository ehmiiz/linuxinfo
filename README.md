# linuxinfo

Get valuable information on a linux system using PowerShell!

<p align="center">
  <img src="linuxinfoico.png" />
</p>

## Install from GitHub using git


```powershell
Set-Location $env:PSModulePath.Split(":")[0]
git clone https://github.com/ehmiiz/linuxinfo.git
New-Item -ItemType Directory -Name 0.0.1 -Path ./linuxinfo/
Move-Item ./linuxinfo/src/* -Destination ./linuxinfo/0.0.1/
Import-Module linuxinfo -Force -Verbose
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


## Planned functions:

- Get-HardWareInfo (parse CPU, RAM, Storage, GPU, PCU, Motherboard)
- Get-DisplayInfo (`lspci` parser)
- Get-NetworkInfo (gets network adapter info)
- Get-PeripheralInfo (gets usb, bluetooth devices, cameras, microphones)
- Get-OSInfo (Gets install date, os version, `cat /etc/os-release`)


## Testing

The module is tested on the following linux dists:

- Fedora (RHEL based)
- Ubuntu (Debian based)