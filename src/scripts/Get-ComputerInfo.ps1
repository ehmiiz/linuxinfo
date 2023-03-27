function Get-ComputerInfo {
    [CmdletBinding()]
    param (
        $Property
    )
    <#
        Get:
            - Linux kernel version
            - Bios version
            - OS Version
            - Installed RAM
            - CPU
            - Cores
            - Disk free
            - System root
            
            lscpu
            Write a PowerShell supported regex pattern to select NAME=,VERSION=, PRETTY_NAME, HOME_URL, SUPPORT_END
            
    #>
    $script:CPUData = (Get-Content /proc/cpuinfo | Select-String 'model name' -Raw | Select-Object -Unique).Split(":")[1].TrimStart(" ")
    $script:OSData = (Get-Content /etc/os-release) | Select-String -Pattern '(?<=NAME=|VERSION=|PRETTY_NAME=|HOME_URL=|SUPPORT_END=)[^,\n]+' -Raw
    
    # Free disk
    $FreeDisk = Get-PSDrive | Where-Object {$_.Free -gt 0} | Select-Object -ExpandProperty Free

    # DisplayData
    $DisplayData = (glxinfo -B | Select-String 'Device: ' -Raw).Split(": ")[1]

    return $Object = [PSCustomObject][ordered]@{
        BiosDate = Get-Content /sys/class/dmi/id/bios_date
        BiosVendor = Get-Content /sys/class/dmi/id/bios_vendor
        BiosVerson = Get-Content /sys/class/dmi/id/bios_version
        CPU = $CPUData
        CPUArchitecture = uname -p
        DistName = $OSData[0].TrimStart("NAME=").Trim('"')
        DistSupportURL = ($OSData | Where-Object {$_ -like "HOME_URL=*"}).TrimStart("HOME_URL=").Trim('"')
        DiskSize = (Get-PSDrive | Select-Object  @{L="DiskSize";E={ ($_.Free + $_.Used) / 1GB }} | Where-Object {$_.DiskSize -gt 0}).DiskSize
        DiskFree = (Get-PSDrive | Select-Object  @{L="DiskFree";E={ ($_.Free) / 1GB }} | Where-Object {$_.DiskFree -gt 0}).DiskFree
        DiskUsed = (Get-PSDrive | Select-Object  @{L="DiskUsed";E={ ($_.Used) / 1GB }} | Where-Object {$_.DiskUsed -gt 0}).DiskUsed
        GPU = (glxinfo -B | Select-String 'Device: ' -Raw).Split(": ")[1]
        DistVersion = $OSData[1].TrimStart("VERSION=").Trim('"')
        KernelRelease = uname -r
        OS = uname -o
        RAM = (lsmem | Select-String 'Total online memory:' -Raw ).Split(':    ')[1]
    }
}

Get-ComputerInfo