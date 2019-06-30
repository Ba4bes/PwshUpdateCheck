
$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace "\\Tests"
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

. "$here\$sut"


Describe "Get-PwshUpdate" {
    Context "Regular tests" {
        Mock Invoke-RestMethod {
            [pscustomobject]@{
                StableReleaseTag    = "v6.2.1"
                PreviewReleaseTag   = "v7.0.0-preview.1"
                ServicingReleaseTag = "v6.1.4"
                ReleaseTag          = "v6.2.1"
                NextReleaseTag      = "v7.0.0-preview.2"
            }
        }
        Mock Get-PSVersion {
            "5.1"
        }
        It "Stops script without action when no new version is available" {
            Mock Get-ItemProperty {
                [pscustomobject]@{
                    DisplayName    = "PowerShell 6-x64"
                    DisplayVersion = "6.2.1.0"
                }
            }
            $Result = Get-PwshUpdate
            $Result | should be "PowerShell 6-x64 : No Update needed"
        }

        It "Cancels installation when user uses cancel" {
            Mock Get-ItemProperty {
                [pscustomobject]@{
                    DisplayName    = "PowerShell 6-x64"
                    DisplayVersion = "6.2.0.0"
                }
            }
            Mock Show-Alert { 7 }
            #   Mock Set-Content -ParameterFilter { $Path -eq "some_path" -and $Value -eq "Expected Value" }
            $Result = Get-PwshUpdate
            $Result | should be "Update canceled by user."
        }

        It "Starts installation when asked" {
            Mock Show-Alert { 6 }
            Mock Invoke-Expression { Return "Invoke has started" }
            $Result = Get-PwshUpdate
            $Result | should be "Invoke has started"
        }
        It "Start installation when no earlier version is available" {
            Mock Get-ItemProperty { $null }
            Mock Show-Alert { 6 }
            Mock Invoke-Expression { Return "Invoke has started" }
            $Result = Get-PwshUpdate
            $Result | should be "Invoke has started"
        }
        It "throws when installation gives an error" {
            Mock Show-Alert { 6 }
            Mock Invoke-RestMethod  { Throw "Installation failed" }
            #$Result = Get-PwshUpdate
            { Get-PwshUpdate } | should Throw "Installation failed"
        }
        It "throws when used with Core and installing Core" {
            Mock Get-PSVersion { "6.2.0" }
            { Get-PwshUpdate } | should -throw "The shell is running in PowerShell Core while trying to install Core. Please run script in PowerShell Core Preview or Windows PowerShell."
        }
        It "The Mocks are called" {
            Assert-MockCalled Get-ItemProperty
            Assert-MockCalled get-PSVersion
            Assert-MockCalled Invoke-Expression
            Assert-MockCalled Show-Alert
        }
    }
    Context "Preview tests" {
        Mock Invoke-RestMethod {
            [pscustomobject]@{
                StableReleaseTag    = "v6.2.1"
                PreviewReleaseTag   = "v7.0.0-preview.1"
                ServicingReleaseTag = "v6.1.4"
                ReleaseTag          = "v6.2.1"
                NextReleaseTag      = "v7.0.0-preview.2"
            }
        }
        Mock Get-PSVersion {
            "5.1"
        }
        It "Stops script without action when no new version is available" {
            Mock Get-ItemProperty {
                [pscustomobject]@{
                    DisplayName    = "PowerShell 7-preview-x64"
                    DisplayVersion = "7.0.0.1"
                }
            }
            $Result = Get-PwshUpdate -Preview
            $Result | should be "PowerShell 7-preview-x64 : No Update needed"
        }
        It "Cancels installation when user uses cancel" {
            Mock Get-ItemProperty {
                [pscustomobject]@{
                    DisplayName    = "PowerShell 7-preview-x64"
                    DisplayVersion = "7.0.0.0"
                }
            }
            Mock Show-Alert { 7 }
            $Result = Get-PwshUpdate -Preview
            $Result | should be "Update canceled by user."
        }
        It "Starts installation when asked" {
            Mock Show-Alert { 6 }
            Mock Invoke-Expression { Return "Invoke has started" }
            $Result = Get-PwshUpdate -Preview
            $Result | should be "Invoke has started"
        }
        It "Start installation when no earlier version is available" {
            Mock Get-ItemProperty { $null }
            Mock Show-Alert { 6 }
            Mock Invoke-Expression { Return "Invoke has started" }
            $Result = Get-PwshUpdate -Preview
            $Result | should be "Invoke has started"
        }
        It "throws when installation gives an error" {
            Mock Show-Alert { 6 }
            Mock Invoke-RestMethod  { Throw "Installation failed" }
            #$Result = Get-PwshUpdate
            { Get-PwshUpdate -Preview } | should Throw "Installation failed"
        }
        It "throws when used with Core Previeuw and installing Core Preview" {
            Mock Get-PSVersion { "6.2.0-rc.1" }
            { Get-PwshUpdate -Preview } | should -throw  "The shell is running in PowerShell Core Preview while trying to install Preview. Please run script in PowerShell Core or Windows PowerShell."
        }
        It "The Mocks are called" {
            Assert-MockCalled Get-ItemProperty
            Assert-MockCalled Get-PSVersion
            Assert-MockCalled Invoke-Expression
            Assert-MockCalled Show-Alert
        }
    }
}
