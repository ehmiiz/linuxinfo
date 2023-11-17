$ModulePath = "$PSScriptRoot/src/linuxinfo"

# Publish-Module -Path  -NuGetApiKey 

Publish-PSResource -Path $ModulePath -ApiKey $Env:APIKEY