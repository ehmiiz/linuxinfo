function Convert-USBDataToObject {
    <#
    .SYNOPSIS
        Converts raw USB device data into structured PowerShell objects.

    .DESCRIPTION
        Parses raw USB device information (typically from lsusb output) and converts it into 
        structured PowerShell objects. The function processes device headers, descriptors, and 
        their properties, converting numeric values into appropriate types and organizing the 
        data hierarchically.

    .PARAMETER Data
        The raw USB device data string to parse. This is typically the output from lsusb or 
        similar commands. The data should contain device headers and descriptor information 
        in a structured format.

    .EXAMPLE
        $usbData = Get-Content -Path "./usb-output.txt" -Raw
        $usbData | Convert-USBDataToObject

        Converts the contents of a file containing USB device information into structured objects.

    .EXAMPLE
        # Get detailed information for a specific USB device and convert it to an object
        $usbDevice = Convert-USBDataToObject -Data (Get-USBInfo -id 1 -full)
        
        # Display all descriptor types
        $usbDevice.Descriptors.Keys

        # Examine specific descriptor properties
        $usbDevice.Descriptors.Device.Properties
        $usbDevice.Descriptors.Configuration.Properties

        This example shows how to:
        1. Get detailed USB information for device ID 1
        2. Convert it to a structured object
        3. View available descriptor types
        4. Access specific descriptor properties

    .EXAMPLE
        # Get and analyze all USB devices with their descriptors
        Get-USBInfo -full | Convert-USBDataToObject | ForEach-Object {
            Write-Host "Device: $($_.Manufacturer)" -ForegroundColor Yellow
            foreach ($descriptor in $_.Descriptors.Keys) {
                Write-Host "`nDescriptor: $descriptor" -ForegroundColor Cyan
                $_.Descriptors[$descriptor].Properties | Format-Table -AutoSize
            }
        }

        This example demonstrates how to:
        1. Get information for all USB devices
        2. Convert them to objects
        3. Format and display each device's descriptors in a readable way

    .OUTPUTS
        [PSCustomObject] Objects containing structured USB device information with the following properties:
        - Bus: Integer representing the USB bus number
        - Device: Integer representing the device number
        - VendorId: String containing the vendor ID in hexadecimal
        - ProductId: String containing the product ID in hexadecimal
        - Manufacturer: String containing the manufacturer/device description
        - Descriptors: Hashtable of descriptor objects containing device properties
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Alias("Content")]
        [string]$Data
    )

    begin {
        # Define regex patterns with named capture groups
        $deviceHeaderPattern = @'
(?x)                   # Enable comment mode
^Bus\s+(?<bus>\d+)\s+ # Bus number
Device\s+(?<dev>\d+): # Device number
\s*ID\s+              # ID label
(?<vendorId>[\da-f]{4}): # Vendor ID (4 hex digits)
(?<productId>[\da-f]{4}) # Product ID (4 hex digits)
\s+
(?<manufacturer>[^\r\n]+) # Manufacturer/description
'@
        
        $descriptorPattern = '^(?<type>\w+)\s+Descriptor:$'
        $propertyPattern = '^\s+(?<key>\w+)\s+(?<value>.+)$'
    }

    process {
        # Split input into lines
        $lines = $Data -split '\r?\n'
        
        # Track current parsing state
        $currentDevice = $null
        $currentDescriptor = $null

        foreach ($line in $lines) {
            # Skip empty lines
            if ([string]::IsNullOrWhiteSpace($line)) { continue }

            Write-Verbose "Processing line: $line"

            switch -Regex ($line) {
                $deviceHeaderPattern {
                    Write-Verbose "Found device header"
                    # Create new device object
                    $currentDevice = [PSCustomObject]@{
                        Bus = [int]$matches.bus
                        Device = [int]$matches.dev
                        VendorId = $matches.vendorId
                        ProductId = $matches.productId
                        Manufacturer = $matches.manufacturer
                        Descriptors = @{}
                    }
                    $currentDescriptor = $null
                    continue
                }

                $descriptorPattern {
                    Write-Verbose "Found descriptor: $($matches.type)"
                    # Create new descriptor section
                    $descriptorType = $matches.type
                    $currentDevice.Descriptors[$descriptorType] = [PSCustomObject]@{
                        Type = $descriptorType
                        Properties = @{}
                    }
                    $currentDescriptor = $currentDevice.Descriptors[$descriptorType]
                    continue
                }

                $propertyPattern {
                    if ($currentDescriptor) {
                        Write-Verbose "Found property: $($matches.key)"
                        $key = $matches.key
                        $value = $matches.value.Trim()
                        
                        # Handle special cases like hex values
                        if ($value -match '^0x[\da-f]+$') {
                            $value = [Convert]::ToInt32($value.Substring(2), 16)
                        }
                        elseif ($value -match '^\d+$') {
                            $value = [int]$value
                        }
                        
                        $currentDescriptor.Properties[$key] = $value
                    }
                    continue
                }

                default {
                    # Handle continuation lines or additional information
                    if ($currentDescriptor -and $line.StartsWith('    ')) {
                        Write-Verbose "Found continuation line"
                        if (-not $currentDescriptor.Properties.ContainsKey('Notes')) {
                            $currentDescriptor.Properties['Notes'] = @()
                        }
                        $currentDescriptor.Properties['Notes'] += $line.Trim()
                    }
                }
            }
        }

        # Output the device object
        if ($currentDevice) {
            $currentDevice
        }
    }
}