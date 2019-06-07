<#PSScriptInfo

.VERSION 1.0

.GUID 89536fca-8990-49c0-86b4-8ebfeaa28095

.AUTHOR Barbara Forbes

.COPYRIGHT

.TAGS PowerShell Core

.LICENSEURI

.PROJECTURI https://github.com/Ba4bes/PWSHUpdateCheck

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

.PRIVATEDATA

#>
<#
.SYNOPSIS
This Script Checks new PowerShell Core versions and installs them as needed

.DESCRIPTION
The Script checks for the newest PowerShell-version in the Metadata provided by the PowerShell Github.
It compares it to the version installed on the computer.
If a newer version is available, it asks if it should be installed.
For installation, it uses a script provided in the Powershell GitHub

.PARAMETER Preview
Switch to look for Powershell Core Preview instead of the regular version

.EXAMPLE
. .\Get-PwshUpdates.ps1

Checks for new versions for both PowerShell Core and PowerShell Core Preview

.NOTES
Script used for install: https://aka.ms/install-powershell.ps1
Script should be ran from a different version then the shell then the one that's being updated
Script only works when a previous version of Powershell has been installed.
Functions are called beneath the script to use it in a scheduled task.
Created by Barbara Forbes

.LINK
https://github.com/Ba4bes/PWSHUpdateCheck

.LINK
https://4bes.nl/2019/01/04/powershell-challenge-check-pwsh-version-and-install/

#>
Function Show-Alert {
    param (
        [Parameter()]
        [String]$AlertText
    )
    $Alert = New-Object -comobject wscript.shell
    $Alert.popup($AlertText, 0, "PowershellCore Update", 32 + 4)
}
Function PSVersion {
    $PSVersionTable.PSVersion.ToString()
}

Function Get-PwshUpdate {
    param (
        [Parameter()]
        [Switch]$Preview
    )
    # Check the version, this script can't run from the same Powershell version as it would update.
    $PSVersionCheck = PSVersion
    If ($PSVersionCheck -like "*-rc*" -or $PSVersionCheck -like "*Preview*") {
        if ($null -eq $Preview) {
            Continue
        }
        if ($null -ne $Preview) {
            Throw "The shell is running in PowerShell Core Preview while trying to install Preview. Please run script in PowerShell Core or Windows PowerShell."
        }
    }
    elseif ($PSVersionCheck -notlike "5*" -and $false -eq $Preview) {
        Throw "The shell is running in PowerShell Core while trying to install Core. Please run script in PowerShell Core Preview or Windows PowerShell."
    }

    $PwshName = "PowerShell [0-9]-x"
    #Get the newest PWSHversion from the Powershell Github Metadata.
    $Metadata = Invoke-RestMethod https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/metadata.json

    # Change the tags so they are in the same format as the local version
    $PwshRelease = $Metadata.ReleaseTag -replace '^v'
    if ($Preview) {
        $PwshRelease = ($Metadata.PreviewReleaseTag -replace '^v') -replace '-preview'
        $PwshName = $PwshName -replace '-x', '-preview'
    }

    # Get the local version
    $PwshCurrent = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -match "$PwshName" } | Select-Object DisplayName, DisplayVersion

    #Compare and take action
    if ($null -eq $PwshCurrent) {
        $InstallUpdate = Show-Alert -AlertText "No active PowerShell Core (Preview) Installation found. Do you want to install it now?"
    }
    else {
        #Create a popup if the current version and the newest version are not the same
        if ($PwshCurrent.DisplayVersion -notlike "$PwshRelease*") {
            $InstallUpdate = Show-Alert -AlertText "A new version of $($PwshCurrent.DisplayName) is available!! Update now?"
        }
        else {
            Write-Output "$($PwshCurrent.DisplayName) : No Update needed"
            return
        }
    }
    # Install the update if the popup is answered with yes
    if ($InstallUpdate -eq 6) {
        try {
            if ($Preview) {
                Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI -Preview" -ErrorAction Stop
            }
            Else {
                Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI" -ErrorAction Stop
            }
        }
        catch {
            $Errormessage = $_
            $Alert.popup("Update has failed. $Errormessage", 0, "ALERT", 48)
        }
    }
    Else {
        Write-Output "Update canceled by user."
    }
}

if ($MyInvocation.InvocationName -ne '.'){
Get-PwshUpdate
Get-PwshUpdate -Preview
}


