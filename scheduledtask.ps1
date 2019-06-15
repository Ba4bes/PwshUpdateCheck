# Run as administrator!
# Run in Windows PowerShell, this does not work in Core 😭
$ScriptPath = "C:\Scripts\GIT\Github - Public\PwshUpdateCheck\Get-PwshUpdate.ps1"
#Format as Date-Time
[DateTime]$CheckTime = "20:00"

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

