function Get-BatteryInfo {
    <#
    .SYNOPSIS
        Gets battery information on Linux systems using upower.
    
    .DESCRIPTION
        Uses the upower binary to gather detailed battery data on Linux systems.
        Returns information including battery state, capacity, voltage, and estimated time remaining.
        Requires the upower binary to be installed.
    
    .INPUTS
        None. This function does not accept pipeline input.
    
    .OUTPUTS
        PSCustomObject with the following properties:
        - Model: Battery model information
        - State: Current battery state (charging/discharging)
        - IsRechargeable: Whether the battery is rechargeable
        - WarningLevel: Current warning level
        - Percentage: Current charge percentage
        - Capacity: Battery capacity percentage
        - Technology: Battery technology type
        - TimeToEmpty: Estimated time until battery depletion (if discharging)
        - Energy: Current energy level
        - EnergyFull: Maximum energy when fully charged
        - EnergyRate: Current energy consumption rate
        - Voltage: Current voltage
        - ChargeCycles: Number of charge cycles
    
    .EXAMPLE
        Get-BatteryInfo
        Returns battery information for the system's primary battery.
    
    .NOTES
        Author: Emil Larsson
        Version: 2.0
        Requires: upower
    #>
    [CmdletBinding()]
    param()

    # Platform check
    if (-not $IsLinux) {
        Write-Error 'This function is only supported on Linux systems.' -ErrorAction Stop
    }

    # Verify required binary
    if (-not (Resolve-BinDep -Bins "upower")) {
        return
    }

    try {
        # Find battery device
        $Battery = upower -e | Where-Object { $_ -match "BAT[0-9]" }
        if (-not $Battery) {
            Write-Warning 'No battery detected. This system may not have a battery or upower cannot detect it.'
            return
        }

        # Define regex pattern for data extraction
        $regex = '(?i)\b(model|rechargeable|state|warning-level|energy(-full(-design)?|-rate)?|voltage|charge-cycles|time to empty|percentage|capacity|technology)\b'
        
        # Get and filter battery data
        $FilteredData = upower -i $Battery | 
            Select-String $regex -Raw |
            ForEach-Object { $_.Trim() -replace '\s+', ' ' -replace ': ', ':' }

        # Convert data to hashtable
        $batteryData = @{}
        foreach ($line in $FilteredData) {
            $key, $value = $line -split ':', 2
            $batteryData[$key] = $value.Trim()
        }

        # Build and return object with consistent property types
        [PSCustomObject]@{
            Model = $batteryData['model']
            State = $batteryData['state']
            IsRechargeable = [bool]($batteryData['rechargeable'] -eq 'yes')
            WarningLevel = $batteryData['warning-level']
            Percentage = ($batteryData['percentage'] -match '[\d\.]+%') ? [decimal]($batteryData['percentage'] -replace '%') : $null
            Capacity = ($batteryData['capacity'] -match '[\d\.]+%') ? [decimal]($batteryData['capacity'] -replace '%') : $null
            Technology = $batteryData['technology']
            TimeToEmpty = $batteryData['time to empty']
            Energy = ($batteryData['energy'] -match '[\d\.]+\s*Wh') ? [decimal]($batteryData['energy'] -replace ' Wh') : $null
            EnergyFull = ($batteryData['energy-full'] -match '[\d\.]+\s*Wh') ? [decimal]($batteryData['energy-full'] -replace ' Wh') : $null
            EnergyRate = ($batteryData['energy-rate'] -match '[\d\.]+\s*W') ? [decimal]($batteryData['energy-rate'] -replace ' W') : $null
            Voltage = ($batteryData['voltage'] -match '[\d\.]+\s*V') ? [decimal]($batteryData['voltage'] -replace ' V') : $null
            ChargeCycles = ($batteryData['charge-cycles'] -match '^\d+$') ? [int]$batteryData['charge-cycles'] : $null
        }
    }
    catch {
        Write-Error "Failed to get battery information: $_" -ErrorAction Stop
    }
}