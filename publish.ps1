$ModulePath = "$PSScriptRoot/src/linuxinfo"

# Publish-Module -Path  -NuGetApiKey 

if (-not (Get-Command Publish-PSResource -ErrorAction SilentlyContinue) ) {
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module Microsoft.PowerShell.PSResourceGet -Force
}

Publish-PSResource -Path $ModulePath -ApiKey $Env:APIKEY