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
        if (Test-Path ./linuxinfo) {
            Remove-Item ./linuxinfo -Recurse -Force
        }

        Write-Verbose "Cloning linuxinfo.." -Verbose
        $null = git clone https://github.com/ehmiiz/linuxinfo.git

        # Figure out module version
        [string]$V = (Test-ModuleManifest -Path linuxinfo/src/linuxinfo/linuxinfo.psd1).Version

        $null = New-Item -ItemType Directory -Name $V -Path ./linuxinfo/
        Move-Item ./linuxinfo/src/linuxinfo/* -Destination ./linuxinfo/$V/
        Import-Module linuxinfo -Force -ErrorAction SilentlyContinue
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