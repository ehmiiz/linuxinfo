function Get-SystemUptime {
    <#
    .SYNOPSIS
        Uses unix `uptime` binary to get system uptime data
    .DESCRIPTION
        A PowerShell wrapper for `uptime`, returns a PSCustomObject with uptime data.
    .NOTES
        Did not realize that `Get-Uptime` exists on linux, use that instead in scripting
    .EXAMPLE
        Get-SystemUptime
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    [CmdletBinding()]
    param()

    # Verifies required binary
    Resolve-BinDep -Bins "uptime"

    $Data = [PSCustomObject]@{
        SystemBootTime = ($SystemBTime = uptime -s)
        SystemUptime   = (New-TimeSpan -Start $SystemBTime -End (Get-Date) )
        FriendlyView   = uptime -p
    }      
    $Data
}