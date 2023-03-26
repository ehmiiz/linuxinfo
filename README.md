# linuxinfo

<p align="center">
  <img src="linuxinfoico.png" />
</p>


Contains functions that help with getting valuable information on a linux system

## Completed functions:

- Get-FileSystemHelp (help data on `/`, json format with navigation)
- Get-BatteryInfo (upower parser)
- Get-SystemUptime (uptime parser) (Get-Uptime exists in Linux, so this function is a bit redundant but was fun to write.)


## Planned functions:

- Get-ComputerInfo (Combines everything)
- Get-HardWareInfo (parse CPU, RAM, Storage, GPU, PCU, Motherboard)
- Get-DisplayInfo (lspci parser)
- Get-NetworkInfo (gets network adapter info)
- Get-PeripheralInfo (gets usb, bluetooth devices, cameras, microphones)
- Get-OSInfo (Gets install date, os version, cat /etc/os-release)