# Get functions
$Functions = @( Get-ChildItem -Path $PSScriptRoot\*.ps1 -Recurse -ErrorAction SilentlyContinue )


foreach($import in @($Functions )){
    try {
        . $import.FullName
        $import
    }
    catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

# Aliases
New-Alias -Name 'ldexplain' -Value 'Get-FileSystemHelp'

# Export everything in the directory
Export-ModuleMember -Function @("Get-FileSystemHelp","Get-BatteryInfo", "Get-SystemUptime", "Get-ComputerInfo", "Get-OSInfo", "Get-DisplayInfo") -Cmdlet * -Alias *