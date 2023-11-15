BeforeAll {
    Import-Module ../../src/linuxinfo/linuxinfo.psd1 -Function Get-SystemUpTime -Verbose
}

Describe "Get-SystemUptime" {
    It "Should return type DateTime" {
        (Get-SystemUptime).SystemBootTime | Should -BeOfType [System.DateTime]
    }
}