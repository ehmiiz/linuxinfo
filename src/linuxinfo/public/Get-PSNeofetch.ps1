

function Get-PSNeofetch {
    
    <#
.SYNOPSIS
    Displays system information in a neofetch-like format with ASCII art.

.DESCRIPTION
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

.EXAMPLE
    Get-PSNeofetch

    Shows system information with colored ASCII art based on the detected environment.

.NOTES
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

.LINK
    https://github.com/ehmiiz/linuxinfo
#>


    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('Ubuntu', 'Fedora', 'Windows')]
        [string]$AsciiDistro = 'Windows'
    )

    # ASCII Art definitions
    $ubuntuArt = @'
            .-/+oossssoo+/-.
        `:+ssssssssssssssssss+:`
      -+ssssssssssssssssssyyssss+-
    .ossssssssssssssssssdMMMNysssso.
   /ssssssssssshdmmNNmmyNMMMMhssssss/
  +sssssssshmydMMMMMMMNddddyssssssss+
 /sssssssshNMMMyhhyyyyhmNMMMNhssssssss/
.ssssssssdMMMNhsssssssssshNMMMdssssssss.
+sssshhhyNMMNyssssssssssssyNMMMysssssss+
ossyNMMMNyMMhsssssssssssssshmmmhssssssso
ossyNMMMNyMMhsssssssssssssshmmmhssssssso
+sssshhhyNMMNyssssssssssssyNMMMysssssss+
.ssssssssdMMMNhsssssssssshNMMMdssssssss.
 /sssssssshNMMMyhhyyyyhdNMMMNhssssssss/
  +sssssssssdmydMMMMMMMMddddyssssssss+
   /ssssssssssshdmNNNNmyNMMMMhssssss/
    .ossssssssssssssssssdMMMNysssso.
      -+sssssssssssssssssyyyssss+-
        `:+ssssssssssssssssss+:`
            .-/+oossssoo+/-.
'@

    $fedoraArt = @'
          /:-------------:\
       :-------------------::
     :-----------/shhOHbmp---:\
   /-----------omMMMNNNMMD  ---:
  :-----------sMMMMNMNMP.    ---:
 :-----------:MMMdP-------    ---\
,------------:MMMd--------    ---:
:------------:MMMd-------    .---:
:----    oNMMMMMMMMMNho     .----:
:--     .+shhhMMMmhhy++   .------/
:-    -------:MMMd--------------:
:-   --------/MMMd-------------;
:-    ------/hMMMy------------:
:-- :dMNdhhdNMMNo------------;
:---:sdNMMMMNds:------------:
:------:://:-------------::
:---------------------://
'@

    $windowsArt = @'
        ,.=:!!t3Z3z.,
       :tt:::tt333EE3
       Et:::ztt33EEEL @Ee.,      ..,
      ;tt:::tt333EE7 ;EEEEEEttttt33#
     :Et:::zt333EEQ. $EEEEEttttt33QL
     it::::tt333EEF @EEEEEEttttt33F
    ;3=*^```"*4EEV :EEEEEEttttt33@.
    ,.=::::!t=., ` @EEEEEEtttz33QF
   ;::::::::zt33)   "4EEEtttji3P*
  :t::::::::tt33.:Z3z..  `` ,..g.
  i::::::::zt33F AEEEtttt::::ztF
 ;:::::::::t33V ;EEEttttt::::t3
 E::::::::zt33L @EEEtttt::::z3F
{3=*^```"*4E3) ;EEEtttt:::::tZ`
             ` :EEEEtttt::::z7
                 "VEzjt:;;z>*`
'@

    # Get system information first to determine ASCII art
    $computerInfo = Get-ComputerInfo
    $osInfo = Get-OSInfo
    $displayInfo = Get-DisplayInfo
    $networkInfo = Get-NetworkInfo
    $systemUptime = Get-SystemUptime
    $batteryInfo = Get-BatteryInfo

    # Dynamically select ASCII art based on kernel and OS
    $asciiArt = if ($osInfo.KernelRelease -like "*WSL*") {
        $windowsArt
    }
    elseif ($osInfo.DistName -like "*Ubuntu*") {
        $ubuntuArt
    }
    elseif ($osInfo.DistName -like "*Fedora*") {
        $fedoraArt
    }
    else {
        # Default to Windows art if no match
        $windowsArt
    }

    # Format the output
    $userName = $env:USER ?? $env:USERNAME
    $hostName = if ($osInfo.KernelRelease -like "*WSL*") {
        (hostname).ToLower()
    }
    else {
        $env:COMPUTERNAME
    }

    $separator = "-" * 10

    # Create info array with enhanced data points and colors
    $infoLines = @(
        "$([char]0x1b)[32m$userName@$hostName$([char]0x1b)[0m"  # Green
        $separator
        "$([char]0x1b)[31mOS:$([char]0x1b)[0m $($osInfo.DistName) $($osInfo.DistVersion)"
        "$([char]0x1b)[31mKernel:$([char]0x1b)[0m $($osInfo.KernelRelease)"
        "$([char]0x1b)[31mUptime:$([char]0x1b)[0m $($systemUptime.FriendlyView)"
        "$([char]0x1b)[31mShell:$([char]0x1b)[0m pwsh"
        "$([char]0x1b)[31mCPU:$([char]0x1b)[0m $($computerInfo.CPU)"
        "$([char]0x1b)[31mArchitecture:$([char]0x1b)[0m $($computerInfo.CPUArchitecture)"
        "$([char]0x1b)[31mGPU:$([char]0x1b)[0m $($computerInfo.GPU)"
        if ($displayInfo.AspectRatio -ne "Unknown") {
            "$([char]0x1b)[31mResolution:$([char]0x1b)[0m $($displayInfo.AspectRatio)"
        }
        "$([char]0x1b)[31mMemory:$([char]0x1b)[0m $($computerInfo.RAM)"
        if ($networkInfo.LocalIP) {
            "$([char]0x1b)[31mIP:$([char]0x1b)[0m $($networkInfo.LocalIP)"
        }
        if ($batteryInfo) {
            "$([char]0x1b)[31mBattery:$([char]0x1b)[0m $($batteryInfo.Percentage)% ($($batteryInfo.State))"
        }
        "$([char]0x1b)[31mDisk:$([char]0x1b)[0m $($computerInfo.SystemDiskUsed) / $($computerInfo.SystemDiskSize)"
    )

    # Split ASCII art and info into arrays
    $artLines = $asciiArt -split "`n"
    
    # Calculate padding for right-aligned info
    $maxArtLength = ($artLines | Measure-Object -Property Length -Maximum).Maximum
    $padding = $maxArtLength + 4  # Add some space between art and info

    # Combine art and info
    $maxLines = [Math]::Max($artLines.Count, $infoLines.Count)
    for ($i = 0; $i -lt $maxLines; $i++) {
        $line = ""
        if ($i -lt $artLines.Count) {
            $line += $artLines[$i].PadRight($padding)
        }
        else {
            $line += " " * $padding
        }
        if ($i -lt $infoLines.Count) {
            $line += $infoLines[$i]
        }
        Write-Output $line
    }
}
