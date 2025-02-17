function Get-USBInfo {
    <#
    .SYNOPSIS
        Gets information about USB devices connected to the system.
    .DESCRIPTION
        Retrieves basic information about USB devices from lsusb command.
        Each device is returned as a PowerShell object with standardized properties.
        Use -Full to include detailed troubleshooting data.
    .PARAMETER Full
        If specified, includes detailed troubleshooting data from lsusb -v -d
        for each device.
    .PARAMETER Id
        Specifies a specific device ID to return. The ID is the sequential number
        shown in the basic listing (1,2,3...).
    .OUTPUTS
        [PSCustomObject[]] USBDevice objects containing:
        * Id          - Sequential device number (1,2,3...)
        * Bus         - USB bus number
        * Device      - Device number on bus
        * VendorID    - Vendor ID (hex)
        * ProductID   - Product ID (hex) 
        * DeviceID    - Combined VendorID:ProductID format
        * Description - Device description
        
        When -Full is specified, adds:
        * TroubleshootingData - Raw output from lsusb -v -d
    .EXAMPLE
        Get-USBInfo
        Lists all USB devices with basic information.
    .EXAMPLE
        Get-USBInfo -Id 1
        Gets information for a specific USB device.
    .EXAMPLE
        Get-USBInfo -Full
        Lists all USB devices including detailed troubleshooting data.
    .EXAMPLE
        Get-USBInfo -Id 1 -Full
        Gets detailed information for a specific USB device.
    .EXAMPLE
        $devices = Get-USBInfo
        $devices | Where-Object VendorID -eq '0951'
        Gets all USB devices and filters for a specific vendor.
    .NOTES
        Requires lsusb command to be available on the system.
        The DeviceID property can be used directly with 'lsusb -v -d'.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param (
        [Parameter(HelpMessage="Include detailed troubleshooting data")]
        [switch]$Full,

        [Parameter(HelpMessage="Get information for a specific device by ID")]
        [int]$Id
    )

    # Verify required binary
    if (-not (Resolve-BinDep -Bins "lsusb")) {
        return
    }

    try {
        Write-Verbose "Retrieving USB device information"
        $lsUsbOutput = lsusb 2>$null

        $counter = 1
        $devices = foreach ($line in $lsUsbOutput) {
            if ($line -match '^Bus (\d{3}) Device (\d{3}): ID ([0-9A-Fa-f]{4}):([0-9A-Fa-f]{4})\s*(.*)$') {
                $vendorId = $matches[3]
                $productId = $matches[4]
                $deviceId = "$vendorId`:$productId"
                
                $device = [PSCustomObject]@{
                    PSTypeName = 'LinuxInfo.USBDevice'
                    Id = $counter++
                    Bus = $matches[1]
                    Device = $matches[2]
                    VendorID = $vendorId
                    ProductID = $productId
                    DeviceID = $deviceId
                    Description = $matches[5].Trim()
                }

                if ($Full) {
                    Write-Verbose "Getting detailed information for device $deviceId"
                    $troubleshootingData = $(lsusb -v -d $deviceId 2>$null)
                    $device | Add-Member -NotePropertyName 'TroubleshootingData' -NotePropertyValue ($troubleshootingData -join "`n")
                }
                
                $device
            }
        }

        # Filter by Id if specified
        if ($Id) {
            $devices = $devices | Where-Object { $_.Id -eq $Id }
            if (-not $devices) {
                Write-Error "No USB device found with ID: $Id"
                return
            }
        }

        return $devices
    }
    catch {
        Write-Error "Failed to retrieve USB information: $_"
    }
}