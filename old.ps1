#Function is called at bottom of the script for the scheduled task.
Function Get-PwshUpdates {
    param (
        [Parameter()]
        [Switch]$Preview
    )
    $PwshName = "PowerShell 6-x"
    $Metadata = Invoke-RestMethod https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/metadata.json
    $PwshRelease = $Metadata.ReleaseTag -replace '^v'
    if ($Preview) {
        $PwshRelease = ($Metadata.PreviewReleaseTag -replace '^v') -replace '-rc'
        $PwshName = $PwshName -replace '-x', '-preview'
    }
    $PwshCurrent = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*  | Where-Object {$_.DisplayName -match "$PwshName" } | Select-Object DisplayName, DisplayVersion, UnInstallString
    $Alert = new-object -comobject wscript.shell
    #Compare and take action
    if ($PwshCurrent) {
        if ($PwshCurrent.DisplayVersion -notlike "$PwshRelease*") {
            $InstallUpdate = $Alert.popup("A new version of $($PwshCurrent.DisplayName) is available!! Update now?", 0, "PowershellCore Update", 32 + 4)
        }
        else {
            Write-output "$($PwshCurrent.DisplayName) : No Update needed"
            return
        }
    }
    #using https://github.com/PowerShell/PowerShell/blob/master/tools/install-powershell.ps1
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

Get-PwshUpdates
Get-PwshUpdates -Preview