function Get-SystemUptime {
    <#
    .SYNOPSIS
        Gets system uptime information on Linux systems.
    
    .DESCRIPTION
        Retrieves detailed system uptime information using the 'uptime' command.
        Returns boot time, uptime duration, and a human-readable format.
        
        Note: While this function provides a Linux-native way to get uptime,
        consider using PowerShell's built-in Get-Uptime cmdlet for cross-platform
        compatibility.
    
    .INPUTS
        None. This function does not accept pipeline input.
    
    .OUTPUTS
        PSCustomObject with the following properties:
        - SystemBootTime: DateTime when the system was last booted
        - SystemUptime: TimeSpan showing how long the system has been running
        - FriendlyView: Human-readable uptime string
        - LoadAverages: PSCustomObject containing 1, 5, and 15 minute load averages
    
    .EXAMPLE
        Get-SystemUptime
        Returns system uptime information.
    
    .EXAMPLE
        (Get-SystemUptime).SystemUptime.Days
        Returns just the number of days the system has been up.
    
    .NOTES
        Author: Emil Larsson
        Version: 2.0
        Requires: uptime
    #>
    [CmdletBinding()]
    param()

    # Platform check
    if (-not $IsLinux) {
        Write-Error 'This function is only supported on Linux systems.' -ErrorAction Stop
    }

    # Verify required binary
    if (-not (Resolve-BinDep -Bins "uptime")) {
        return
    }

    try {
        # Get system boot time
        $bootTime = Get-Date (uptime -s)
        if (-not $bootTime) {
            Write-Error "Failed to determine system boot time." -ErrorAction Stop
        }

        # Calculate current uptime
        $currentUptime = New-TimeSpan -Start $bootTime -End (Get-Date)

        # Get load averages
        $loadOutput = uptime
        if ($loadOutput -match '.*load average: ([\d.]+),\s*([\d.]+),\s*([\d.]+)') {
            $loadAverages = [PSCustomObject]@{
                OneMinute     = [double]$Matches[1]
                FiveMinutes   = [double]$Matches[2]
                FifteenMinutes = [double]$Matches[3]
            }
        }
        else {
            Write-Warning "Could not parse load averages from uptime output."
            $loadAverages = [PSCustomObject]@{
                OneMinute      = $null
                FiveMinutes    = $null
                FifteenMinutes = $null
            }
        }

        # Get human-readable uptime
        $friendlyUptime = (uptime -p).TrimStart('up ')

        # Build and return the result object
        [PSCustomObject]@{
            PSTypeName     = 'Linux.SystemUptime'
            SystemBootTime = $bootTime
            SystemUptime   = $currentUptime
            FriendlyView  = $friendlyUptime
            LoadAverages  = $loadAverages
        }
    }
    catch {
        Write-Error "Failed to retrieve system uptime information: $_" -ErrorAction Stop
    }
}

# Optional: Add custom type formatting
Update-TypeData -TypeName 'Linux.SystemUptime' -DefaultDisplayPropertySet @('SystemBootTime', 'SystemUptime', 'FriendlyView') -Force -ErrorAction SilentlyContinue