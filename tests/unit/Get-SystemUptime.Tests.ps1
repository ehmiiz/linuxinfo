BeforeAll {
    ../../build.ps1 -Force
}

Describe "Get-SystemUptime" {
    It "Should return type DateTime" {
        (Get-SystemUptime).SystemBootTime | Should -BeOfType [System.DateTime]
    }
}