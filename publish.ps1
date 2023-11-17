$ModulePath = "$PSScriptRoot/src/linuxinfo"

# Publish-Module -Path  -NuGetApiKey 

if (-not (Get-Command Publish-PSResource) ) {
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module PSResourceGet -Force
}

Publish-PSResource -Path $ModulePath -ApiKey $Env:APIKEY