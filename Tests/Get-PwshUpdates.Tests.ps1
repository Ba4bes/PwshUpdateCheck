# $here = Split-Path -Parent $MyInvocation.MyCommand.Path
# $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
# . "$here\$sut"


$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace "\\Tests"
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

Set-Alias -Name Get-PwshUpdates -Value Out-Null
. "$here\$sut"
Remove-Alias Get-PwshUpdates

Describe "Get-PwshUpdates" {
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
        It "Skips asking for install when no new version is available" {
            Mock Get-ItemProperty {
                [pscustomobject]@{
                    DisplayName     = "PowerShell 6-x64"
                    DisplayVersion  = "6.2.1.0"
                    UNinstallString = "MsiExec.exe /X{20550CD1-4102-4984-BD59-6FE1666D98C0}"
                }
            }
            Get-PwshUpdates | should be "PowerShell 6-x64 : No Update needed"
        }
        It "Cancel update when it is asked" {
            Mock Get-ItemProperty {
                [pscustomobject]@{
                    DisplayName     = "PowerShell 6-x64"
                    DisplayVersion  = "6.2.0.0"
                    UNinstallString = "MsiExec.exe /X{20550CD1-4102-4984-BD59-6FE1666D98C0}"
                }
            }
            Mock Show-Alert { 7 }
            Get-PwshUpdates | should be "Update canceled by user."
        }
        It "Installation is performed when asked" {
            Mock Show-Alert { 6 }
            Mock Invoke-Expression { Return "Invoke has started"}
            Get-PwshUpdates | should be "Invoke has started"
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
        It "Skips asking for install when no new version is available" {
            Mock Get-ItemProperty {
                [pscustomobject]@{
                    DisplayName     = "PowerShell 7-preview-x64"
                    DisplayVersion  = "7.0.0.1"
                }
            }
            $Result = Get-PwshUpdates -Preview
            $Result | should be "PowerShell 7-preview-x64 : No Update needed"
        }
        It "Cancel update when it is asked" {
            Mock Get-ItemProperty {
                [pscustomobject]@{
                    DisplayName     = "PowerShell 7-preview-x64"
                    DisplayVersion  = "7.0.0.0"
                }
            }
            Mock Show-Alert { 7 }
            $Result = Get-PwshUpdates -Preview
            $Result | should be "Update canceled by user."
        }
        It "Installation is performed when asked" {
            Mock Show-Alert { 6 }
            Mock Invoke-Expression { Return "Invoke has started"}
            $Result = Get-PwshUpdates -Preview
            $Result |  should be "Invoke has started"
        }

    }
}
