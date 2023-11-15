BeforeAll {
    ../../build.ps1 -Force
}

Describe "Get-ComputerInfo" {
    It "Should only consider System Drive" {
        ((Get-ComputerInfo).SystemDiskSizeGB).Count | Should -BeExactly 1
    }
}