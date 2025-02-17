function Get-OSInfo {
    <#
    .SYNOPSIS
        Gathers operating system information from a Linux system.
    .DESCRIPTION
        Collects and returns operating system information including:
        - Distribution name and version
        - Support URL
        - Kernel details
        - Installation date (where available)
        
        Uses uname and the os-release file to gather system information.

    .OUTPUTS
        PSCustomObject with the following properties:
        - DistName: Linux distribution name
        - DistVersion: Distribution version
        - SupportURL: Distribution's support website
        - OS: Operating system type
        - KernelRelease: Kernel version
        - OSInstallDate: System installation date (if available)

    .EXAMPLE
        Get-OSInfo
        Returns detailed operating system information.

    .NOTES
        Author: Emil Larsson
        Requires: stat, awk, uname
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    # Verify required binaries are available
    if (-not (Resolve-BinDep -Bins "stat", "awk", "uname")) {
        return
    }

    try {
        # Gather OS release data
        $OSData = (Get-Content /etc/os-release) | 
                  Select-String -Pattern '(?<=NAME=|VERSION=|PRETTY_NAME=|HOME_URL=|SUPPORT_END=)[^,\n]+' -Raw
        
        $regex = '"([^"]*)"'
        $DistName = ([regex]::Match($OSData[0], $regex)).Value
        $DistNameData = $OSData | Where-Object { $_ -like "VERSION=*" }
        $DistVersion = ([regex]::Match($DistNameData, $regex)).Value

        # Get install date
        if (Get-Command stat) {
            $InstallDate = (stat / | Where-Object { $_ -like " *Birth*" }).TrimStart(" Birth:")
            if ($InstallDate -match '[0-9][0-9][0-9]') {
                $InstallDate = [DateTime]$InstallDate
            }
            else {
                $InstallDate = "N/A"
            }
        }
        else {
            $InstallDate = "Unknown"
        }
    }
    catch {
        Write-Warning "Error gathering OS information: $_"
        return
    }

    [PSCustomObject]@{
        DistName = $DistName.Replace('"', '')
        DistVersion = $DistVersion.Replace('"', '')
        SupportURL = ($OSData | Where-Object { $_ -like "HOME_URL=*" }).TrimStart("HOME_URL=").Trim('"')
        OS = uname -o
        KernelRelease = uname -r
        OSInstallDate = $InstallDate
    }
}