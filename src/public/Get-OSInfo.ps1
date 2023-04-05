function Get-OSInfo {
    <#
    .SYNOPSIS
        Gathers information about the operating system and displays it to the user.
    .DESCRIPTION
        Uses uname & os-release file to build a PSCustomObject that describes the operating system,
    .NOTES
        Author: Emil Larsson, 2023-03-30
    .EXAMPLE
        Get-OSInfo
        Gets an object with operating system info on a linux system.
    #>
    
    
    [CmdletBinding()]
    param()

    # Verifies required binary
    Resolve-BinDep -Bins "stat", "awk", "uname"


    # Gather data
    $script:OSData = (Get-Content /etc/os-release) | Select-String -Pattern '(?<=NAME=|VERSION=|PRETTY_NAME=|HOME_URL=|SUPPORT_END=)[^,\n]+' -Raw
    $regex = '"([^"]*)"'

    $DistName = ([regex]::Match($OSData[0], $regex)).Value
    $DistNameData = $script:OSData | Where-Object {$_ -like "VERSION=*"}
    $DistVersion = ([regex]::Match($DistNameData, $regex)).Value
    
    if (Get-Command stat) {
        $InstallDate = stat / | awk '/Birth: /{print $2}'
    }
    else {
        $InstallDate = "Unknown"
    }

    # Build object
    $Object = [PSCustomObject]@{
        DistName = $DistName.Replace('"','')
        DistVersion = $DistVersion.Replace('"','')
        SupportURL = ($OSData | Where-Object {$_ -like "HOME_URL=*"}).TrimStart("HOME_URL=").Trim('"')
        OS = uname -o
        KernelRelease = uname -r
        OSInstallDate = $InstallDate
    }

    # Return object
    return $Object
}