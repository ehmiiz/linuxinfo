<#
 # Gets:
    Plugged in USB devices
    
#>

function Get-USBInfo {
    [CmdletBinding()]
    param (
        [Switch]$Tree
    )
    
    # Verifies required binary
    Resolve-BinDep -Bins "lsusb"
    $Object = @()

    if ($Tree) {
        lsusb -t
        Break
    }

    $lsUsbOutput = lsusb

    foreach ($l in $lsUsbOutput) {

        $SplittedLines = $l.Split(' ').Trim()
        $Bus = $SplittedLines[1]
        $DeviceID = $ProductID = $SplittedLines[5].Split(":")[0]
        $ProductID = $SplittedLines[5].Split(":")[1]
        $DeviceName = (-join " " + $SplittedLines[6..50]).Trim() 

        $Object += [PSCustomObject]@{
            DeviceName = $DeviceName
            ProductID = $ProductID
            DeviceID = $DeviceID
            Bus = $Bus
        }
    }

    $Object
}