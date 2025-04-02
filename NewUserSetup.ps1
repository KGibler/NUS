###################### BEGIN USER SETUP ######################
# Self-elevate the script
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}

###################### REMOVE HKLM KEY ######################
Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "NUS"

###################### DISABLE UAC ######################
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0

###################### ENABLE NETWORKING ######################
Get-NetAdapter | Enable-NetAdapter -Confirm:$false

<# This checks to see if there is a wireless interface with property value of 71, which
is for IEEE 802.11 wireless network devices. Other devices that can be called out:

1   | Some other type of network interface.
6   | An Ethernet network interface
9   | A token ring network interface
23  | A PPP network device
24  | A software loopback network interace.
37  | An ATM network interface
71  | An IEEE 802.11 wireless network interface
131 | A tunnel type encapsulation network interface
144 | An IEEE 1394 (Firewire) High performance serial bus network interface. #>

$WA = ( Get-NetAdapter | Where-Object InterfaceType -eq 71 )
if ($null -eq $WA) {
    "No wireless adapter detected."
}
### install .xml files from folder for use with the wi-fi adapter. ###
else {
    $WF = 'C:\.installer\Wi-Fi'
    Get-ChildItem $WF | Where-Object { $_.extension -eq '.xml' } | ForEach-Object {
        netsh wlan add profile filename=($WF + '\' + $_.name)
    }    
}

###################### WAIT FOR NETWORK TO COME ONLINE ######################
Start-Sleep -seconds 30

###################### ATTACH NETWORKED DRIVES ######################
Write-Output "Attaching networked drives..."
Net Use L: \\0.0.0.0\Apps /savecred
Net Use P: \\0.0.0.0\Users /savecred
Start-Sleep -seconds 10

###################### FETCH SOFTWARE ######################
Push-Location "C:\.installer"
Write-Output "Fetching software from server..."
Copy-Item "Z:\NETWORK_LOCATION\Apps.zip" -Destination "C:\.installer" -Recurse -Force
#Unzip archive
Write-Output "Expanding Archive..."
Expand-Archive -Path 'C:\.installer\Apps.zip' -DestinationPath C:\.installer\Apps
#delete archive
Write-Output "Deleting Archive..."
Remove-Item "C:\.installer\Apps.zip"

###################### Update Winget & Install PowerToys ######################

winget update --all #-h --accept-package-agreements --accept-source-agreements --authentication-mode silent
Write-Output "Installing PowerToys..."
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco install powertoys
    
###################### TURN ON VIEWABLE FILE EXTENSIONS ######################
Write-Output "Enabling file extensions"
reg add HKCU\Software\Microsoft\Windows\CurrentVersionExplorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
Set-Itemproperty -path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -value 0

###################### SET TIME SERVER ######################
Write-Output "Setting local time"
Set-TimeZone -Id "Central Standard Time"

###################### CREATE ELEVATED LOCAL USER ######################
Write-Output "Create local admin password:"
$P = Read-Host -AsSecureString
$params = @{
    Name        = 'FalseAdmin'
    Password    = $P
    FullName    = 'Org Admin'
    Description = 'Local admin for machine'
}
New-LocalUser @params

###################### CHANGE PC NAME BASED ON SERVICE TAG ######################
#Note: You must reboot machine to change the name in order to join the domain properly
#If you do not change the name of the machine, you'll end up with inappropriately named 
#machines and will need to sort them out on the Domain Controller.

Write-Output "Gathering service tag information and setting the PC name"
# This works great for Dell PC's where the service tag is 7 digits long and appends the date (MMYY) to the end.  

# Get Service Tag information to join domain
$a = Read-Host -Prompt '[1] Automatic mode or [2] Manual mode?'
if (2 -eq $a) {
    $SN = (Get-WmiObject -class win32_bios).SerialNumber
    $PN = "$SN"
    # Get current month/year to append to service tag to create PCNAME
    $D = (Read-Host -Prompt "Enter Computer Ship Date (MMYY)")
    $PN = ("$SN$D")
    Rename-Computer -NewName "$PN"
}
else {
    $SN = (Get-WmiObject -class win32_bios).SerialNumber
    $PN = "$SN"
    # Get current month/year to append to service tag to create PCNAME
    $D = (Get-Date).ToString("MMyy")
    $PN = ("$SN$D")
    Rename-Computer -NewName "$PN"
}

###################### CONTINUE SCRIPT AFTER REBOOT ######################
Write-Output "Enabling script to continue after reboot..."
set-location "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
new-itemproperty . NUS0 -propertytype String -value "Powershell C:\.installer\NewUserSetup0.ps1"

######################  WAIT TO FINISH UP ######################
Write-Output "Finishing up..."
$TotalIterations = 100
$ProgressBar = $null

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