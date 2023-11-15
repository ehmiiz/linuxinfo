BeforeAll {
    ../../build.ps1 -Force
}

Describe "Get-OSInfo" {
    It "Should return type DateTime" {
        (Get-OSInfo).OSInstallDate | Should -BeOfType [System.DateTime]
    }
}