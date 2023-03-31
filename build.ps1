<#
.SYNOPSIS
    Quick build script that will clone the repo to a PSModulePath and install the module locally.
.EXAMPLE
    ./build.ps1
    Clones, installs and imports the module.
.EXAMPLE
    ./build.ps1 -Force
    ReInstall and imports the module.
#>


param(
    [switch]$Force,
    $ModulePathToInstall = $env:PSModulePath.Split(":")[0]
)

function Install-LinuxInfo {
    try {
        $GoBack = $pwd
        Set-Location $env:PSModulePath.Split(":")[0]
        Write-Verbose "Cloning linuxinfo.." -Verbose
        $null = git clone https://github.com/ehmiiz/linuxinfo.git
        $null = New-Item -ItemType Directory -Name 0.0.1 -Path ./linuxinfo/
        Move-Item ./linuxinfo/src/* -Destination ./linuxinfo/0.0.1/
        Import-Module linuxinfo -Force
        Set-Location $GoBack
        Write-Verbose "Installed and Imported." -Verbose
        Get-Module linuxinfo
    }
    catch {
        Write-Error $error[0] -ErrorAction Stop
    }
    
}


if ((Test-Path "$ModulePathToInstall/linuxinfo") -and ($Force)) {
    # Remove since -Force was used
    Write-Verbose "Module found, and -Force was used. Removing.." -Verbose
    $null = Remove-Item $ModulePathToInstall/linuxinfo -Recurse -Force -Confirm:$false

    # Install
    Write-Verbose "Installing.." -Verbose
    Install-LinuxInfo

}
elseif (Test-Path "$ModulePathToInstall/linuxinfo") {
    Write-Warning 'Module already installed. Use -Force to reinstall.'
    Break
}
else {
    Install-LinuxInfo
    Write-Verbose "Installed." -Verbose
}