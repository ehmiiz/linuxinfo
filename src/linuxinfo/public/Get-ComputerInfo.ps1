function Get-ComputerInfo {
    <#
    .SYNOPSIS
        Gathers detailed system information from a Linux system.
    .DESCRIPTION
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

    .OUTPUTS
        PSCustomObject with the following properties:
        - BiosDate: DateTime of BIOS release
        - BiosVendor: Manufacturer of BIOS
        - BiosVersion: BIOS version string
        - CPU: Processor model name
        - CPUArchitecture: Processor architecture
        - CPUThreads: Total number of CPU threads
        - CPUCores: Total number of CPU cores
        - CPUSockets: Number of CPU sockets
        - DistName: Linux distribution name
        - DistSupportURL: Distribution's support URL
        - SystemDiskSize: Total system disk size
        - SystemDiskFree: Available disk space
        - SystemDiskUsed: Used disk space
        - GPU: Graphics card information
        - DistVersion: Distribution version
        - KernelRelease: Linux kernel version
        - OS: Operating system name
        - RAM: Total system memory
        - Manufacturer: System manufacturer
        - ProductName: System product name
        - SystemVersion: System version
        - SerialNumber: System serial number

    .NOTES
        Author: Emil Larsson
        Date: 2023-03-27
        
        The script handles both native Linux and Windows Subsystem for Linux (WSL) environments,
        using different methods to gather BIOS information in each case.

    .EXAMPLE
        Get-ComputerInfo
        Returns a detailed object containing system information.
    #>
    [CmdletBinding()]
    param (
    )

    # Verifies required binary
    if (-not (Resolve-BinDep -Bins "lscpu", "awk", "lspci", "grep", "lsmem", "uname")) {
        return
    }

    $script:CPUData = lscpu | awk '/^Model name:/ || /^Socket\(s\):/ || /^Core\(s\) per socket:/ || /^Thread\(s\) per core:/ {print $0}' | Sort-Object
    
    $script:OSData = (Get-Content /etc/os-release) | Select-String -Pattern '(?<=NAME=|VERSION=|PRETTY_NAME=|HOME_URL=|SUPPORT_END=)[^,\n]+' -Raw
    
    # DisplayData
    $DisplayData = (lspci | grep -i vga) -split ":" | Select-Object -Last 1
    if ($DisplayData -like " *") {
        $DisplayData = $DisplayData.TrimStart(" ")
    }

    # Ram
    $RAM = (lsmem | Select-String 'Total online memory:' -Raw ).Split(':    ')[1]
    if ($RAM -like "* *") {
        $RAM = $RAM.Replace(" ", "")
    }
    # Convert RAM to rounded GB if it ends with 'G'
    if ($RAM -match '(\d+\.?\d*)G$') {
        $ramValue = [decimal]$Matches[1]
        $RAM = "{0}GB" -f [Math]::Ceiling($ramValue)
    }

    # CPU Regex

    $CorePerSocket = $CPUData[0].Substring($CPUData[0].Length - 2)
    if ($CorePerSocket -like "* *") {
        $CorePerSocket = $CorePerSocket.Trim(" ")
    }

    $Sockets = $CPUData[2].Substring($CPUData[2].Length - 2)
    if ($Sockets -like "* *") {
        $Sockets = $Sockets.Trim(" ")
    }
    
    $ThreadsPerCore = $CPUData[3].Substring($CPUData[3].Length - 2)
    if ($ThreadsPerCore -like "* *") {
        $ThreadsPerCore = $ThreadsPerCore.Trim(" ")
    }
    
    # Get CPU architecture with fallbacks if uname -p returns unknown
    $CPUArc = uname -p
    if ((-not $CPUArc) -or ($CPUArc -eq 'unknown')) {
        # Try uname -m as first fallback
        $CPUArc = uname -m
        if ((-not $CPUArc) -or ($CPUArc -eq 'unknown')) {
            # Try lscpu as second fallback
            $CPUArc = (lscpu | Select-String -Pattern '^Architecture:').ToString().Split(':')[1].Trim()
            if ((-not $CPUArc) -or ($CPUArc -eq 'unknown')) {
                $CPUArc = "Unknown"
            }
        }
    }

    # Make CPU Thread count more robust, if parser failed, output unknown instead of error
    try {
        $CPUThreads = ([int]$ThreadsPerCore * [int]$CorePerSocket)
    }
    catch {
        $CPUThreads = 'Unknown'
    }

    try {
        $CPUCores = ([int]$CorePerSocket * [int]$Sockets)
    }
    catch {
        $CPUCores = 'Unknown'
    }
    

    # Dist Name & version
    $regex = '"([^"]*)"'
    $DistName = ([regex]::Match($OSData[0], $regex)).Value
    $DistNameData = $script:OSData | Where-Object { $_ -like "VERSION=*" }
    $DistVersion = ([regex]::Match($DistNameData, $regex)).Value

    # Fix disk display:
    $DiskSizeNice = (Get-PSDrive -Name "/" | Select-Object  @{L = "DiskSize"; E = { ($_.Free + $_.Used) / 1GB } } | Where-Object { $_.DiskSize -gt 0 }).DiskSize | ForEach-Object {
        if ($_ -ge 1) {
            "{0}GB" -f [int]$_
        }
    }

    if ($DiskSizeNice[0] -eq $DiskSizeNice[1]) {
        $DiskSizeNice = $DiskSizeNice[0]
    }

    $DiskFreeNice = (Get-PSDrive -Name "/" | Select-Object  @{L = "DiskFree"; E = { ($_.Free) / 1GB } } | Where-Object { $_.DiskFree -gt 0 }).DiskFree | ForEach-Object {
        if ($_ -ge 1) {
            "{0}GB" -f [int]$_
        }
    }

    if ($DiskFreeNice[0] -eq $DiskFreeNice[1]) {
        $DiskFreeNice = $DiskFreeNice[0]
    }

    $DiskUsedNice = (Get-PSDrive -Name "/" | Select-Object  @{L = "DiskUsed"; E = { ($_.Used) / 1GB } } | Where-Object { $_.DiskUsed -gt 0 }).DiskUsed | ForEach-Object {
        if ($_ -ge 1) {
            "{0}GB" -f [int]$_
        }
    }

    if ($DiskUsedNice[0] -eq $DiskUsedNice[1]) {
        $DiskUsedNice = $DiskUsedNice[0]
    }

    # Get BIOS information directly from DMI
    $BiosDate = Get-Content "/sys/class/dmi/id/bios_date"
    $BiosVendor = Get-Content "/sys/class/dmi/id/bios_vendor"
    $BiosVersion = Get-Content "/sys/class/dmi/id/bios_version"

    if ($CPUData[1].Replace("  ", "").Split(":")[1] -like " *") {
        $CPUData = $CPUData[1].Replace("  ", "").Split(":")[1].TrimStart(" ")
    }
    else {
        $CPUData = $CPUData[1].Replace("  ", "").Split(":")[1]
    }

    # Get system information using dmidecode
    $SystemInfo = @{
        Manufacturer = "Unknown"
        ProductName = "Unknown"
        Version = "Unknown"
        SerialNumber = "Unknown"
    }

    try {
        # Check if sudo is available
        if (Get-Command sudo -ErrorAction SilentlyContinue) {
            Write-Verbose "Attempting to get system information using dmidecode"
            $DmiOutput = sudo dmidecode -t system 2>$null
            
            if ($DmiOutput) {
                $SystemInfo.Manufacturer = ($DmiOutput | Select-String "Manufacturer:" -Raw).Split(":")[1].Trim()
                $SystemInfo.ProductName = ($DmiOutput | Select-String "Product Name:" -Raw).Split(":")[1].Trim()
                $SystemInfo.Version = ($DmiOutput | Select-String "Version:" -Raw).Split(":")[1].Trim()
                $SystemInfo.SerialNumber = ($DmiOutput | Select-String "Serial Number:" -Raw).Split(":")[1].Trim()
            }
        }
        else {
            Write-Verbose "sudo not available - system information will be limited"
        }
    }
    catch {
        Write-Verbose "Unable to get system information using dmidecode: $_"
    }

    # Modify the return object to include system information
    $Return = [PSCustomObject][ordered]@{
        BiosDate         = [DateTime]$BiosDate
        BiosVendor       = $BiosVendor
        BiosVersion      = $BiosVersion
        CPU              = $CPUData
        CPUArchitecture  = $CPUArc
        CPUThreads       = $CPUThreads
        CPUCores         = $CPUCores
        CPUSockets       = $Sockets
        DistName         = $DistName.Replace('"', '')
        DistSupportURL   = ($OSData | Where-Object { $_ -like "HOME_URL=*" }).TrimStart("HOME_URL=").Trim('"')
        SystemDiskSize   = $DiskSizeNice
        SystemDiskFree   = $DiskFreeNice
        SystemDiskUsed   = $DiskUsedNice
        GPU              = $DisplayData
        DistVersion      = $DistVersion.Replace('"', '')
        KernelRelease    = uname -r
        OS               = uname -o
        RAM              = $RAM
        Manufacturer     = $SystemInfo.Manufacturer
        ProductName      = $SystemInfo.ProductName
        SystemVersion    = $SystemInfo.Version
        SerialNumber     = $SystemInfo.SerialNumber
    }

    # Display results to user
    $Return
}