<#
.SYNOPSIS
    Installs the LinuxInfo PowerShell module locally for development.
.DESCRIPTION
    This build script clones the LinuxInfo repository to a PSModulePath location and installs
    the module locally. It creates a version-specific directory structure and imports the module.
.PARAMETER Force
    Forces reinstallation of the module even if it already exists.
.PARAMETER ModulePathToInstall
    Specifies the target PSModulePath location for installation. Defaults to the first path in $env:PSModulePath.
.EXAMPLE
    ./build.ps1
    Clones and installs the module if not already present.
.EXAMPLE
    ./build.ps1 -Force
    Reinstalls the module even if already present.
.EXAMPLE
    ./build.ps1 -ModulePathToInstall "C:\CustomModules"
    Installs the module to a specific path.
.NOTES
    Author: Emil Larsson
    Version: 1.0
    Requires: Git
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage="Force reinstallation of the module even if it exists")]
    [switch]$Force,
    
    [Parameter(HelpMessage="Target PSModulePath location for installation")]
    [ValidateNotNullOrEmpty()]
    [string]$ModulePathToInstall = ($env:PSModulePath -split [IO.Path]::PathSeparator)[0]
)

function Install-LinuxInfo {
    [CmdletBinding()]
    param()
    
    try {
        # Store original location and change to module path
        $originalLocation = Get-Location
        Write-Verbose "Original location: $originalLocation"
        
        if (-not (Test-Path -Path $script:ModulePathToInstall)) {
            throw "Installation path does not exist: $script:ModulePathToInstall"
        }
        
        Set-Location -Path $script:ModulePathToInstall
        Write-Verbose "Changed location to: $script:ModulePathToInstall"
        
        # Verify git is available
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            throw "Git is not installed or not available in PATH"
        }
        
        # Remove existing module if present
        if (Test-Path -Path ./linuxinfo) {
            Write-Verbose "Removing existing module installation..."
            Remove-Item -Path ./linuxinfo -Recurse -Force
        }

        Write-Verbose "Cloning linuxinfo repository..."
        $null = git clone https://github.com/ehmiiz/linuxinfo.git
        if (-not $?) {
            throw "Git clone operation failed"
        }

        # Get module version from manifest
        $manifestPath = Join-Path -Path $script:ModulePathToInstall -ChildPath "linuxinfo/src/linuxinfo/linuxinfo.psd1"
        
        if (-not (Test-Path $manifestPath)) {
            throw "Module manifest not found at expected path: $manifestPath"
        }

        $moduleInfo = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop
        $version = $moduleInfo.Version.ToString()
        Write-Verbose "Module version: $version"

        # Create version directory and move files
        $versionPath = Join-Path -Path "./linuxinfo" -ChildPath $version
        $null = New-Item -ItemType Directory -Path $versionPath -Force
        Write-Verbose "Created version directory: $versionPath"
        
        Move-Item -Path ./linuxinfo/src/linuxinfo/* -Destination $versionPath -Force
        
        # Import module
        Write-Verbose "Importing module..."
        Import-Module -Name linuxinfo -Force -ErrorAction Stop
        
        # Return to original location
        Set-Location -Path $originalLocation

        # Get the actual installed manifest path for LastWriteTime
        $installedManifestPath = Join-Path $script:ModulePathToInstall "linuxinfo/$version/linuxinfo.psd1"

        # Create result object with installation details
        [PSCustomObject]@{
            Status = "Success" 
            Version = $version
            InstallPath = Join-Path $script:ModulePathToInstall "linuxinfo/$version"
            ExportedFunctions = @($moduleInfo.ExportedFunctions.Keys)
            Author = $moduleInfo.Author
            Description = $moduleInfo.Description
            LastWriteTime = (Get-Item $installedManifestPath).LastWriteTime
            PSVersion = $PSVersionTable.PSVersion.ToString()
        }

        Write-Verbose "Module installed and imported successfully"
    }
    catch {
        Write-Error -ErrorRecord $_
        Set-Location -Path $originalLocation
        throw
    }
}

# Main script logic
try {
    if (Test-Path -Path (Join-Path -Path $ModulePathToInstall -ChildPath "linuxinfo")) {
        if ($Force) {
            Write-Verbose "Force parameter specified - reinstalling module"
            Install-LinuxInfo | Format-List
        }
        else {
            Write-Warning "Module already installed. Use -Force to reinstall."
            return
        }
    }
    else {
        Write-Verbose "Installing module for the first time"
        Install-LinuxInfo | Format-List
    }
}
catch {
    Write-Error -ErrorRecord $_
    exit 1
}