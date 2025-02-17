<#
.SYNOPSIS
    Verifies the presence of required Linux binary dependencies.

.DESCRIPTION
    The Resolve-BinDep function checks if specified Linux binary commands are available
    in the system's PATH. If any required binary is missing, it warns the user and
    stops execution.

.PARAMETER Bins
    An array of binary names to check for availability.

.EXAMPLE
    Resolve-BinDep -Bins @('ls', 'grep', 'awk')
    Verifies if ls, grep, and awk commands are available in the system.

.NOTES
    This function is designed for Linux environments and should be used to validate
    dependencies before executing Linux-specific operations.

.OUTPUTS
    None. The function writes a warning if dependencies are missing or a verbose message if all dependencies are found.

.LINK
    https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-overview
#>

function Resolve-BinDep {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory,
            Position = 0,
            HelpMessage = "Array of required Linux binary names"
        )]
        [string[]]$Bins
    )

    # Platform check
    if (-not $IsLinux) {
        Write-Error 'This function is only supported on Linux systems.' -ErrorAction Stop
    }

    # Get available commands, ensuring $BinsLookup is an empty array if nothing is found
    $BinsLookup = @(Get-Command $Bins -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name)
    
    # Only perform comparison if we found at least one command
    if ($BinsLookup.Count -gt 0) {
        $Diff = Compare-Object -ReferenceObject $Bins -DifferenceObject $BinsLookup
        
        if ($Diff) {
            $missingBins = $Diff | Where-Object { $_.SideIndicator -eq '<=' } | Select-Object -ExpandProperty InputObject
            Write-Warning "Cannot process function. Missing required dependencies: '$($missingBins -join "', '")'.`nInstall them and retry."
            return $false
        }
        else {
            Write-Verbose "All required binary dependencies are present: '$($Bins -join "', '")'."
            return $true
        }
    }
    else {
        # If no commands were found, all requested binaries are missing
        Write-Warning "Cannot process function. Missing required dependencies: '$($Bins -join "', '")'.`nInstall them and retry."
        return $false
    }
}
