function Get-DisplayInfo {
    [CmdletBinding()]
    param()
    
    if (Get-Command xrandr) {
        $AspectRatio = ((xrandr | Select-Object -First 1).split(",")[1]).Replace(" current ",'')
        $RefreshRate = (xrandr --prop | Select-String -SimpleMatch '*+' -Raw).Split('     ')[1].Replace('*+','')
        $Monitors = (xrandr --listmonitors)[0].ToCharArray() | Select-Object -Last 1
    }
    else {
        Write-Error 'This function uses `xrandr` cli to gather its data. Please install it using your preferred package manager and try again.' -ErrorAction Stop
    }

    if (Get-Command lspci) {
        # DisplayData
        $DisplayData = (lspci | grep -i vga) -split ":" | Select-Object -Last 1
        if ($DisplayData -like " *") {
            $DisplayData = $DisplayData.TrimStart(" ")
        }
    }
    else {
        $DisplayData = 'N/A'
    }

    $Object = [pscustomobject] @{
        RefreshRate = $RefreshRate
        AspectRatio = $AspectRatio
        NumberOfMonitors = $Monitors
        GPU = $DisplayData
    }

    return $Object
}