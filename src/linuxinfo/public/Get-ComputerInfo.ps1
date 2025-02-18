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
    $IsWSL = Get-Item Env:WSL_DISTRO_NAME -ErrorAction SilentlyContinue
    
    if ($IsWSL) {
        try {
            $DisplayData = powershell.exe -Command "Get-WmiObject Win32_VideoController | Select-Object -ExpandProperty Description" 2>$null
            if ([string]::IsNullOrEmpty($DisplayData)) {
                $DisplayData = "Unknown"
            }
        }
        catch {
            Write-Verbose "Unable to get GPU information from Windows host: $_"
            $DisplayData = "Unknown"
        }
    }
    else {
        $DisplayData = (lspci | grep -i vga) -split ":" | Select-Object -Last 1
        if ($DisplayData -like " *") {
            $DisplayData = $DisplayData.TrimStart(" ")
        }
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

    # Debug disk values
    $diskInfo = Get-PSDrive -Name "/"
    Write-Verbose "Raw disk values:"
    Write-Verbose ("Used bytes: {0}" -f $diskInfo.Used)
    Write-Verbose ("Used GB raw: {0}" -f ($diskInfo.Used/1GB))

    # Fix disk display:
    try {
        $DiskSizeNice = "{0:N2}GB" -f (($diskInfo.Used + $diskInfo.Free) / 1GB)
        $DiskFreeNice = "{0:N2}GB" -f ($diskInfo.Free / 1GB)
        $DiskUsedNice = "{0:N2}GB" -f ($diskInfo.Used / 1GB)
    }
    catch {
        Write-Verbose "Error calculating disk space: $_"
        $DiskSizeNice = "Unknown"
        $DiskFreeNice = "Unknown"
        $DiskUsedNice = "Unknown"
    }

    # Get system information using dmidecode or set WSL defaults
    $SystemInfo = @{
        Manufacturer = "Unknown"
        ProductName  = "Unknown"
        Version      = "Unknown"
        SerialNumber = "Unknown"
    }

    # Get BIOS information based on environment (WSL vs native Linux)
    $IsWSL = Get-Item Env:WSL_DISTRO_NAME -ErrorAction SilentlyContinue
    
    if ($IsWSL) {
        # For WSL, get BIOS info from Windows host using WMI
        try {
            $BiosInfo = powershell.exe -Command "Get-WmiObject Win32_BIOS" 2>$null
            $BiosDate = $BiosInfo.ReleaseDate
            $BiosVendor = $BiosInfo.Manufacturer
            $BiosVersion = $BiosInfo.SMBIOSBIOSVersion
        }
        catch {
            Write-Verbose "Unable to get BIOS information from Windows host: $_"
            $BiosDate = "01/01/1970"
            $BiosVendor = "Unknown"
            $BiosVersion = "Unknown"
        }

        $SystemInfo = @{
            Manufacturer = "Microsoft Corporation"
            ProductName  = "Windows Subsystem for Linux"
            Version      = $WSLVersion
            SerialNumber = "WSL"
        }
    }
    else {
        $BiosDate = Get-Content "/sys/class/dmi/id/bios_date"
        $BiosVendor = Get-Content "/sys/class/dmi/id/bios_vendor"
        $BiosVersion = Get-Content "/sys/class/dmi/id/bios_version"
    }

    if ($CPUData[1] -match "Model name:\s*(.+)") {
        $CPUData = $Matches[1].Trim()
    }
    else {
        $CPUData = "Unknown"
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

    # Parse BIOS date before creating return object
    $ParsedBiosDate = try {
        if ($BiosDate -match '(\d{4})(\d{2})(\d{2})') {
            [DateTime]::ParseExact("$($Matches[1])-$($Matches[2])-$($Matches[3])", 'yyyy-MM-dd', $null)
        } else {
            [DateTime]"01/01/1970"
        }
    } catch {
        Write-Verbose "Failed to parse BIOS date: $_"
        [DateTime]"01/01/1970"
    }

    # Modify the return object to include system information
    $Return = [PSCustomObject][ordered]@{
        BiosDate        = $ParsedBiosDate
        BiosVendor      = $BiosVendor
        BiosVersion     = $BiosVersion
        CPU             = $CPUData
        CPUArchitecture = $CPUArc
        CPUThreads      = $CPUThreads
        CPUCores        = $CPUCores
        CPUSockets      = $Sockets
        DistName        = $DistName.Replace('"', '')
        DistSupportURL  = ($OSData | Where-Object { $_ -like "HOME_URL=*" }).TrimStart("HOME_URL=").Trim('"')
        SystemDiskSize  = $DiskSizeNice
        SystemDiskFree  = $DiskFreeNice
        SystemDiskUsed  = $DiskUsedNice
        GPU             = $DisplayData
        DistVersion     = $DistVersion.Replace('"', '')
        KernelRelease   = uname -r
        OS              = uname -o
        RAM             = $RAM
        Manufacturer    = $SystemInfo.Manufacturer
        ProductName     = $SystemInfo.ProductName
        SystemVersion   = $SystemInfo.Version
        SerialNumber    = $SystemInfo.SerialNumber
    }

    # Display results to user
    $Return
}