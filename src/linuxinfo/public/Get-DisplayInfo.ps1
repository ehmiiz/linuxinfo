function Get-DisplayInfo {
    <#
    .SYNOPSIS
        Gathers display and graphics information from a Linux system.
    .DESCRIPTION
        Collects and returns display information including:
        - Monitor refresh rate (via xrandr)
        - Display aspect ratio (via xrandr)
        - Number of connected monitors (via xrandr)
        - Graphics card information (via lspci)

        For multiple monitors, the primary display's refresh rate and resolution are reported.

    .OUTPUTS
        PSCustomObject with the following properties:
        - RefreshRate: Primary display refresh rate (Hz)
        - AspectRatio: Primary display resolution
        - NumberOfMonitors: Count of connected displays
        - GPU: Graphics card model information

    .EXAMPLE
        Get-DisplayInfo
        Returns display configuration and graphics hardware information.

    .NOTES
        Author: Emil Larsson
        Requires: xrandr, lspci, grep
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    # Verify required binaries are available
    if (-not (Resolve-BinDep -Bins "xrandr", "lspci", "grep")) {
        return
    }

    try {
        # Initialize default values
        $CurrentResolution = "Unknown"
        $RefreshRate = "Unknown"
        $Monitors = 0
        $DisplayData = "Unknown"

        # Get xrandr output
        $XrandrOutput = xrandr
        if ($XrandrOutput) {
            # Get current resolution from the primary/first connected display
            $ResolutionMatch = $XrandrOutput | Select-String -Pattern 'connected primary (\d+x\d+)'
            if (-not $ResolutionMatch) {
                # Try alternative pattern if no primary monitor is specified
                $ResolutionMatch = $XrandrOutput | Select-String -Pattern 'current (\d+ x \d+)'
            }
            if ($ResolutionMatch) {
                $CurrentResolution = $ResolutionMatch.Matches[0].Groups[1].Value
            }

            # Get refresh rate from the primary/first connected display
            $RefreshMatch = $XrandrOutput | Select-String -Pattern '\d+\.\d+\*'
            if ($RefreshMatch) {
                $RefreshRate = $RefreshMatch.Matches[0].Value.TrimEnd('*')
            }

            # Get monitor count
            $MonitorOutput = xrandr --listmonitors
            if ($MonitorOutput) {
                $Monitors = ($MonitorOutput[0] -replace '[^0-9]')
                Write-Verbose "Detected $Monitors monitor(s)"
            }
        }

        # Get GPU information
        $GPUOutput = lspci | grep -i vga
        if ($GPUOutput) {
            $DisplayData = ($GPUOutput -split ":" | Select-Object -Last 1).Trim()
        }
    }
    catch {
        Write-Warning "Error gathering display information: $_"
        return
    }

    [PSCustomObject]@{
        RefreshRate = $RefreshRate
        AspectRatio = $CurrentResolution
        NumberOfMonitors = [int]$Monitors
        GPU = $DisplayData
    }
}