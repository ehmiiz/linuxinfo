function Get-ComputerInfo {
    <#
    .SYNOPSIS
        Gathers information about the system and displays it to the user.
    .DESCRIPTION
        Uses lscpu, uname, os-release file, glxinfo, lsmem, /sys/class/dmi/id/(bios_date, bios_vendor, bios_version) files to filter out a PSCustomObject with useful system data.
    .NOTES
        Author: Emil Larsson, 2023-03-27
        I don't expect this script to be very robust, since it's using a lot of text manipulation
    .EXAMPLE
        Get-ComputerInfo
        Gets an object with computer information.
    #>
    [CmdletBinding()]
    param (
    )

    # Verifies required binary
    Resolve-BinDep -Bins "lscpu", "awk", "lspci", "grep", "lsmem", "uname"

    

    $script:CPUData = lscpu | awk '/^Model name:/ || /^Socket\(s\):/ || /^Core\(s\) per socket:/ || /^Thread\(s\) per core:/ {print $0}'
    $script:OSData = (Get-Content /etc/os-release) | Select-String -Pattern '(?<=NAME=|VERSION=|PRETTY_NAME=|HOME_URL=|SUPPORT_END=)[^,\n]+' -Raw
    
    # DisplayData
    $DisplayData = (lspci | grep -i vga) -split ":" | Select-Object -Last 1
    if ($DisplayData -like " *") {
        $DisplayData = $DisplayData.TrimStart(" ")
    }

    # Ram
    $RAM = (lsmem | Select-String 'Total online memory:' -Raw ).Split(':    ')[1]
    if ($RAM -like "* *") {
        $RAM = $RAM.Replace(" ","")
    }

    # CPU Regex
    $ThreadsPerCore = $CPUData[1].Substring($CPUData[1].Length - 2)
    if ($ThreadsPerCore -like "* *") {
        $ThreadsPerCore = $ThreadsPerCore.Trim(" ")
    }

    $CorePerSocket = $CPUData[2].Substring($CPUData[2].Length - 2)
    if ($CorePerSocket -like "* *") {
        $CorePerSocket = $CorePerSocket.Trim(" ")
    }

    $Sockets = $CPUData[3].Substring($CPUData[3].Length - 2)
    if ($Sockets -like "* *") {
        $Sockets = $Sockets.Trim(" ")
    }

    # Dist Name & version
    $regex = '"([^"]*)"'
    $DistName = ([regex]::Match($OSData[0], $regex)).Value
    $DistNameData = $script:OSData | Where-Object {$_ -like "VERSION=*"}
    $DistVersion = ([regex]::Match($DistNameData, $regex)).Value

    # Fix disk display:
    $DiskSizeNice = (Get-PSDrive | Select-Object  @{L="DiskSize";E={ ($_.Free + $_.Used) / 1GB }} | Where-Object {$_.DiskSize -gt 0}).DiskSize | ForEach-Object {
        if ($_ -ge 1) {
            [int]$_
        }
    }

    if ($DiskSizeNice[0] -eq $DiskSizeNice[1]) {
        $DiskSizeNice = $DiskSizeNice[0]
    }

    $DiskFreeNice = (Get-PSDrive | Select-Object  @{L="DiskFree";E={ ($_.Free) / 1GB }} | Where-Object {$_.DiskFree -gt 0}).DiskFree | ForEach-Object {
        if ($_ -ge 1) {
            [int]$_
        }
    }

    if ($DiskFreeNice[0] -eq $DiskFreeNice[1]) {
        $DiskFreeNice = $DiskFreeNice[0]
    }

    $DiskUsedNice = (Get-PSDrive | Select-Object  @{L="DiskUsed";E={ ($_.Used) / 1GB }} | Where-Object {$_.DiskUsed -gt 0}).DiskUsed | ForEach-Object {
        if ($_ -ge 1) {
            [int]$_
        }
    }

    if ($DiskUsedNice[0] -eq $DiskUsedNice[1]) {
        $DiskUsedNice = $DiskUsedNice[0]
    }


    $Object = [PSCustomObject][ordered]@{
        BiosDate = Get-Content "/sys/class/dmi/id/bios_date"
        BiosVendor = Get-Content "/sys/class/dmi/id/bios_vendor"
        BiosVerson = Get-Content "/sys/class/dmi/id/bios_version"
        CPU = $CPUData[0].Replace("  ","").Split(":")[1]
        CPUArchitecture = uname -p
        CPUThreads = ([int]$ThreadsPerCore * [int]$CorePerSocket)
        CPUCores = ($CorePerSocket * $Sockets)
        CPUSockets = $Sockets
        DistName = $DistName.Replace('"','')
        DistSupportURL = ($OSData | Where-Object {$_ -like "HOME_URL=*"}).TrimStart("HOME_URL=").Trim('"')
        DiskSizeGb = $DiskSizeNice
        DiskFreeGb = $DiskFreeNice
        DiskUsedGb = $DiskUsedNice
        GPU = $DisplayData
        DistVersion = $DistVersion.Replace('"','')
        KernelRelease = uname -r
        OS = uname -o
        RAM = $RAM
    }

    # Display results to user
    return $Object

}