# PWSHUpdateCheck

This Script Checks new PowerShell Core versions and installs them as needed on Windows devices

<https://4bes.nl/2019/01/04/powershell-challenge-check-pwsh-version-and-install/> describes how the script was created and how to use it in a Scheduled task.

## Common setup

### Installation

Run in a scheduled task or manually.
Want to Run it in a scheduled task? Execute the following code:
```PowerShell
# Run as administrator!
# Run in Windows PowerShell, this does not work in Core 😭

$ScriptPath = "C:\Scripts\Get-PwshUpdate.ps1"
#Format as Date-Time
[DateTime]$CheckTime = "10pm"

$Parameters = @{
"Execute" = "Powershell.exe"
"Argument" = "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -file $ScriptPath"
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

Version: 1.0
Last update: june 13th 2019

## Known Issues

View known issues [here](https://github.com/Ba4bes/PwshUpdateCheck/issues)
