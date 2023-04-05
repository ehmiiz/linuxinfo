<#
 # Gets:
    Plugged in USB devices
    
#>

# Verifies required binary
Resolve-BinDep -Bins "lsusb"

$lsUsbOutput = lsusb

$lsUsbOutput