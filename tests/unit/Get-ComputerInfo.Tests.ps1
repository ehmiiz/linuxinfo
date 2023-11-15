BeforeAll {
    Import-Module ../../src/linuxinfo/linuxinfo.psd1 -Function Get-ComputerInfo -Verbose
}

Describe "Get-ComputerInfo" {
    It "Should only consider System Drive" {
        ((Get-ComputerInfo).SystemDiskSizeGB).Count | Should -BeExactly 1
    }
}