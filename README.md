# PWSHUpdateCheck

[![Build Status](https://dev.azure.com/Ba4bes/Get-PswhUpdate/_apis/build/status/Ba4bes.PwshUpdateCheck?branchName=master)](https://dev.azure.com/Ba4bes/Get-PswhUpdate/_build/latest?definitionId=10&branchName=master)

[![Gallery version](https://img.shields.io/powershellgallery/v/Get-PwshUpdate.svg)](https://img.shields.io/powershellgallery/v/Get-PwshUpdate.svg)
[![Download Status](https://img.shields.io/powershellgallery/dt/Get-PwshUpdate.svg)](https://img.shields.io/powershellgallery/dt/Get-PwshUpdate.svg)

This Script Checks new PowerShell Core versions and installs them as needed on Windows devices

 [4bes.nl - Check if there is a Powershell Update](http://4bes.nl/2019/06/30/get-pwshupdates-check-if-there-is-a-powershell-update-available-and-install-it) describes how to install and use the script

[4bes.nl - PowerShell Challenge: Check PWSH version and install](https://4bes.nl/2019/01/04/powershell-challenge-check-pwsh-version-and-install/) describes how the script was created

[Find the script in the Gallery]([https://www.powershellgallery.com/packages/Get-PwshUpdate)

## Common setup

### Installation

Install the script by using the following line

```cmd
Install-Script -Name Get-PwshUpdate
```

Run in a scheduled task or manually.
Want to Run it in a scheduled task? Execute the following code:

```PowerShell
# Run as administrator!
# Run in Windows PowerShell, this does not work in Core 😭

$InstalledScriptPath = (Get-InstalledScript -Name Get-PwshUpdate).InstalledLocation
$ScriptPath = "$InstalledScriptPath/Get-PwshUpdate.ps1"
#Format as Date-Time
[DateTime]$CheckTime = "10pm"

$Parameters = @{
    "Execute" = "Powershell.exe"
    "Argument" = "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -file `" $ScriptPath`" "
}
$Action = New-ScheduledTaskAction @Parameters

$Trigger =  New-ScheduledTaskTrigger -Daily -At $CheckTime

$Parameters = @{
    "Action" =  $Action
    "Trigger"= $Trigger
    "TaskName" = "PWSH Update check"
    "RunLevel" =  "Highest"
    "Description" = "Daily check for PWSH updates"
}

Register-ScheduledTask @Parameters
```

## To Contribute

Any ideas or contributions are welcome!
Please add an issue with your suggestions.

## Changelog

*Version 1.0.1*
22/12/2019
Changed handling of the metadata

*Version: 1.0*
Last update: june 30th 2019
Initial Commit


## Known Issues

View known issues [here](https://github.com/Ba4bes/PwshUpdateCheck/issues)
