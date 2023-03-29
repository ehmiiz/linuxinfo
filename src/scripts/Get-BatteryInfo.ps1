function Get-BatteryInfo {
    <#
    .SYNOPSIS
        On a system with the binary `upower`, gets battery data
    .DESCRIPTION
        Uses `upower` binary to gather battery data on a laptop, filters it using regex and returns using a PSCustomObject
    .NOTES
        Author: Emil Larsson, 2023-03-26
    .EXAMPLE
        Get-BatteryInfo
        Gets status on current battery.
    #>
    
    
    [CmdletBinding()]
    param()

    # Verifies required binary
    $ValidateLinuxBinary = (Get-Command upower)
    if ([String]::IsNullOrEmpty($ValidateLinuxBinary) ) {
        throw 'Lacking required binary "upower"'
    }

    # Run upower, filter data
    $Battery = upower -e | Where-Object { $_ -match "BAT[0-9]" }
    if ( -not $Battery) {
        Write-Error '"upower -e" did not find a battery to gather data from. Must match "BAT[0-9].' -ErrorAction Stop
    } 
    
    $regex = '(?i)\b(model|rechargeable|state|warning-level|energy(-full(-design)?|-rate)?|voltage|charge-cycles|time to empty|percentage|capacity|technology)\b'
    $FilteredData = upower -i $Battery | Select-String $regex -Raw

    $FilteredData = $FilteredData.Replace('  ', '').Replace(": ", ":")

    # Time to empty
    if ($FilteredData -like "*time to empty*") {
        $TimeToEmpty = $FilteredData[11].Split(":")[1]
        $ArrayPatchInt = 0
    }
    else {
        $TimeToEmpty = $FilteredData[2].Split(":")[1]
        $ArrayPatchInt = 1
    }

    $RechargeableState = if ($FilteredData[1].Split(":")[1] -eq 'yes' ) { $true } else { $false }

    # Build Object
    $Object = [PSCustomObject]@{
        Model            = $FilteredData[0].Split(":")[1]
        Rechargeable     = $RechargeableState
        State            = $FilteredData[2].Split(":")[1]
        WarningLevel     = $FilteredData[3].Split(":")[1]
        Energy           = $FilteredData[4].Split(":")[1]
        EnergyEmpty      = $FilteredData[5].Split(":")[1]
        EnergyFull       = $FilteredData[6].Split(":")[1]
        EnergyFullDesign = $FilteredData[7].Split(":")[1]
        EnergyRate       = $FilteredData[8].Split(":")[1]
        Voltage          = $FilteredData[9].Split(":")[1]
        ChargeCycles     = $FilteredData[10].Split(":")[1]
        TimeToEmpty      = $TimeToEmpty
        Percentage       = $FilteredData[12 - $ArrayPatchInt].Split(":")[1]
        Capacity         = $FilteredData[13 - $ArrayPatchInt].Split(":")[1]
        Technology       = $FilteredData[14 - $ArrayPatchInt].Split(":")[1]
    }

    # Return object
    return $Object

}