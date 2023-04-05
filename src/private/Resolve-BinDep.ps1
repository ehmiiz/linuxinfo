<#
    Resolves binary dependencies.
#>

function Resolve-BinDep {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        $Bins
    )

    # Verifies required binary
    $BinsLookup = Get-Command $Bins -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
    $Diff = Compare-Object -ReferenceObject $Bins -DifferenceObject $BinsLookup
    
    if ($Diff) {
        Write-Warning "Cannot process function. Missing required dependency: '$($diff.InputObject)'.`nInstall it and retry."
        Break
    }
    else {
        Write-Verbose "Passed binary dependency test."
    }

}
