# Programmed by Kameron Gibler
# Horizon Systems Inc.
# 2024-2025
# Revision 3.4.0.1

<# Open location of installation scripts and copy files to root directory of machine#>
Push-Location "D:\"
new-item -path "C:\.installer" -ItemType Directory
new-item -path "C:\Temp" -ItemType Directory
Copy-Item -Path "D:\*.ps1", "D:\*.bat", "D:\*.xml", "D:\*.cmd", "D:\Wi-Fi\*" -Destination "C:\.installer" -recurse -Force

<# Copy script to Temp folder to allow script removal after installtion is complete.#>
Copy-Item "C:\.installer\NewUserSetup2.ps1" -Destination "C:\Temp"

<# Unblock files from use with Powershell#>
Get-Item C:\.installer\NewUserSetup.ps1 | Unblock-File
Get-Item C:\.installer\NewUserSetup0.ps1 | Unblock-File
Get-Item C:\.installer\NewUserSetup1.ps1 | Unblock-File
Get-Item C:\.installer\NewUserSetup2.ps1 | Unblock-File

##################### CONTINUE SCRIPT AFTER REBOOT ######################
# Even though the computer no longer reboots during user creation, this still ruins the script upon login.
Write-Output "Enabling script to continue after reboot..."
set-location HKLM:\Software\Microsoft\Windows\CurrentVersion\Run
new-itemproperty . NUS -propertytype String -value "Powershell C:\.installer\NewUserSetup.ps1"
Get-NetAdapter | Disable-NetAdapter -Confirm:$false
Start-Sleep -seconds 5
Push-Location "C:\Windows\System32"
#Begin process to create a new local user
start ms-cxh:localonly

<#]=--{(> About this script <)}=[#>

<# This Script is designed to do the following, and do it well:
-Creates .installer and copies files from flash drive to C:\.installer
-Disable network and bypass the Network requirement for Windows, allowing for a local user to be added
-Re-enable networking and copies configuration to interface for auto-wifi if a wireless interface is detected
-Stores scripts and removes them in the regsitry for automatic launching after expected reboots.
-Attaches drives at the local level
-Modifies the following Windows options:
    -Turn on Viewable File Extensions
    -Launch Explorer to "This PC"
    -Show hidden folders
    -Use legacy print dialogue
-Fetches software (apps.zip) from server and stores it in C:\.installer, then unzips it.
-Installs all neccessary user software, some with selected options
-Removal of select programs
-Turns on viewable file extensions in the registry
-Changes the PC Name based on service tag, current month, and last 2 digits of the year
-Sets time to server, modify time zone.
-Sets up system fonts for users
-Automatically adds printers upon joining domain
-Updates Windows (One instance only. Should cover a bulk of pending updates)
-Creates elevated local user "FalseAdmin" in case "Admin" gets locked out, and there's no network. (Doomsday mode)
-Sets local admin password
-Joins computer to domain
-Self-cleanup (Aside from installer leftovers, which is not covered) #>

<#
Working locations:
Z:\NETWORK_LOCATION\
*\apps.zip
C:\.installer
C:\Temp

Registry locations:
HKLM:\Software\Microsoft\Windows\CurrentVersion\Run
HKCU:\Software\Microsoft\Windows\CurrentVersion\Run
#>