# Self-elevate the script
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}

Start-Sleep -Seconds 10

###################### RE-MAP DRIVES ######################
Write-Output "Accessing network drives..."
GPUpdate

<# Printers will be automatically assigned based on GPO, but we need to kickstart the spooler first. #>
Start-Service -Name Spooler

###################### Finish installing software ######################

##### Put software you'd like to install in this section for domain-user only #####

###################### BEGIN WINDOWS UPDATES ######################
Write-Output "Beginning Windows Updates..."
Install-Module -Name PSWindowsUpdate -Force
Get-Package -Name PSWindowsUpdate
Get-WUlist -MicrosoftUpdate
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll

###################### BEGIN WINDOWS MODIFICATIONS ######################
$RP = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced";
#Launch Explorer to "This PC"
New-ItemProperty -Path $RP -Name "LaunchTo" -Value 1 -PropertyType DWord -Force;
#Show Hidden Folders
New-ItemProperty -Path $RP -Name "Hidden" -Value 1 -PropertyType Dword -Force;
#Prefer to use legacy print dialogue rather than the new fancy Win11 one...
Windows Registry Editor Version 5.00
$RP = "HKEY_CURRENT_USER\Software\Microsoft\Print\UnifiedPrintDialog";
New-ItemProperty -Path $RP -name "PreferLegacyPrintDialog" -Value 1 -PropertyType DWord -Force;

###################### END WINDOWS UPDATES ######################
Write-Output "Removing mapped drives..."
net use /delete * /y
Write-Output "Updating Group Policy..."
gpupdate /sync /n
Start-Sleep -seconds 60

###################### CONTINUE SCRIPT AFTER REBOOT ######################
Write-Output "Enabling script to continue after reboot..."
set-location "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
new-itemproperty . NUS2 -propertytype String -value "Powershell C:\Temp\NewUserSetup2.ps1"

For ($i = 1; $i -le $TotalIterations; $i++) {
    # Code to be executed in each iteration
    if ($null -eq $ProgressBar) {
        $ProgressBar = Write-Progress -Activity "Processing" -Status "Please wait..." -PercentComplete ($i / $TotalIterations * 100)
    }
    else {
        $ProgressBar.PercentComplete = $i / $TotalIterations * 100
    }
    Start-Sleep -Milliseconds 300
}
shutdown -r -t 0