# Self-elevate the script
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}

###################### REMOVE HKLM KEY ######################
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "NUS0"

###################### SYSTEM SETUP ######################
Write-Output "Installing system fonts"
# Install fonts
$FF = "C:\.installer\Apps\Fonts" #Set Font-Folder
$FI = Get-Item -Path $FF #Get Font-Items
$FL = Get-ChildItem -Path "$FI\*" -Include ('*.fon', '*.otf', '*.ttc', '*.ttf') #Build Font-List
foreach ($F in $FL) {
    Write-Host 'Installing font -' $F.BaseName
    Copy-Item $F "C:\Windows\Fonts"
    New-ItemProperty -Name $F.BaseName -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $F.name         
}

###################### BEGIN USER SOFTWARE INSTALLATION ######################
Push-Location "C:\.installer\Apps"
choco feature enable -n=useRememberedArgumentsForUpgrades

# Install user software
# Enable Global Confirmation
choco feature enable -n=allowGlobalConfirmation

# https://community.chocolatey.org/packages/GoogleChrome
# Depenencies:
choco install chocolatey-core.extension
choco install chocolatey-compatibility.extension
# Install Google Chrome
choco install googlechrome --ignorechecksums

# https://community.chocolatey.org/packages/Firefox
choco install firefox

# https://community.chocolatey.org/packages/adobereader
# Depenencies:
choco install kb2919442
choco install kb2919355
# Install Adobe Reader
choco install adobereader --params '"/DesktopIcon /EnableUpdateService /UpdateMode:3"'

# https://community.chocolatey.org/packages/vcredist140
# Depenencies:
choco install kb3033929
choco install kb3035131
choco install kb2999226
# Install VCRedist140
choco install vcredist140

# https://community.chocolatey.org/packages/jre8
choco install jre8 -PackageParameters --params "'/exclude:32'" -y

# https://community.chocolatey.org/packages/vcredist2015
choco install vcredist2015

# https://community.chocolatey.org/packages/7zip.install
choco install 7zip.install

# https://community.chocolatey.org/packages/netextender
choco install netextender

# https://community.chocolatey.org/packages/microsoft-teams-new-bootstrapper
choco install microsoft-teams-new-bootstrapper --params "'/VDI'";

# https://community.chocolatey.org/packages/dotnetfx/4.8.0.20220524
# Depenencies:
choco install chocolatey-dotnetfx.extension
choco install dotnetfx

# https://community.chocolatey.org/packages/netfx-4.7.2
choco install netfx-4.7.2

# https://community.chocolatey.org/packages/vcredist-all
# Depenencies:
choco install vcredist2005
choco install vcredist2008
choco install vcredist2010
choco install vcredist2012
choco install vcredist2013
choco install chocolatey-windowsupdate.extension
choco install vcredist2017
# Install VCRedist-all
choco install vcredist-all

# https://community.chocolatey.org/packages?q=dwgtrueview

choco install dwgtrueview

# https://community.chocolatey.org/packages/Silverlight
choco install silverlight

# https://community.chocolatey.org/packages/Office365Business
choco install office365business --params "'/productid:O365BusinessRetail /eula:TRUE'";
# More product codes:
# Microsoft 365 Apps for enterprise	                O365ProPlusEEANoTeamsRetail
# Office 365 Enterprise E3	                        O365ProPlusRetail
# Office 365 Enterprise E5	                        O365ProPlusRetail
# Microsoft 365 Apps for business	                O365BusinessEEANoTeamsRetail
# Microsoft 365 Business Standard	                O365BusinessRetail
# Microsoft 365 E3	                                O365ProPlusRetail
# Microsoft 365 E5	                                O365ProPlusRetail
# Microsoft 365 Business Premium	                O365BusinessRetail
# Office 365 E3	                                    O365ProPlusRetail
# Office 365 E5	                                    O365ProPlusRetail
# Office 365 E3 (no Teams)	                        O365ProPlusEEANoTeamsRetail
# Office 365 E5 (no Teams)	                        O365ProPlusEEANoTeamsRetail
# Microsoft 365 E3 (no Teams)	                    O365ProPlusEEANoTeamsRetail
# Microsoft 365 E5 (no Teams)	                    O365ProPlusEEANoTeamsRetail
# Microsoft 365 Business Standard (no Teams)	    O365BusinessEEANoTeamsRetail
# Microsoft 365 Business Premium (no Teams)	        O365BusinessEEANoTeamsRetail

# Disallow Global Confirmation
choco feature disable -n=allowGlobalConfirmation

# Update AppInstaller because it's finicky.
# This runs after software is installed because of a dependency on VClibs
Add-AppxPackage https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

###################### ATTACH NETWORKED DRIVES ######################
Write-Output "Accessing network drives..."
# Net Use F: \\0.0.0.0\FTP 
Net Use G: \\0.0.0.0\Folder1 /savecred
Net Use H: \\0.0.0.0\Folder2 /savecred
Net Use J: \\0.0.0.0\Folder3 /savecred
Net Use K: \\0.0.0.0\Folder4 /savecred
Net Use L: \\0.0.0.0\Folder5 /savecred
Net Use M: \\0.0.0.0\Folder6 /savecred
Net Use N: \\0.0.0.0\Folder7 /savecred
Net Use O: \\0.0.0.0\Folder8 /savecred
Net Use P: \\0.0.0.0\Folder9 /savecred
Net Use Q: \\0.0.0.0\Folder10 /savecred
Net Use R: \\0.0.0.0\Folder11 /savecred
Net Use S: \\0.0.0.0\Folder12 /savecred
Net Use T: \\0.0.0.0\Folder13 /savecred
Net Use U: \\0.0.0.0\Folder14 /savecred
Net Use X: \\0.0.0.0\Folder15 /savecred
Start-Sleep -seconds 10

################## Extra stuff for [Department] ##################
# Install [Application]]
# Manual: file://0.0.0.0/install.pdf
Write-Output "Install [Application]..."
$a = Read-Host -Prompt 'Would you like to install [Application]? [1] Yes [0] No'
if (0 -eq $a) {
    Write-Output "No changes have been made."
}
elseif (1 -eq $a) {
    do {
        $loop = {
            "Install [Application]? [1] Yes [0] No
                [1] Solidworks 2023
                [0] Exit"
        }
        Push-Location "C:\.installer"
        $loop
        $UC = Read-Host -Prompt "Selection #:"
        if (1 -eq $UC) {
            Write-Output "Installing [Application]..."
            Copy-Item "Z:\NETWORK_LOCATION\" -Destination "C:\.installer\[FOLDER]" -Recurse -Force
            Start-Process C:\.installer\[FOLDER]\Setup.exe
            $UC = Read-Host -Prompt "Package #"
        }
        if (0 -eq $UC) {
            Write-Output "Exiting..."
        }
    }
    until (0 -eq $UC) {
    }
}

# Install Selective Packages:
Write-Output "Install [Program Name]..."
$a = Read-Host -Prompt 'Is the user an [Title]? [1] Yes [2] No'
if (2 -eq $a) {
    Write-Output "No changes have been made."
}
elseif (1 -eq $a) {
    do {
        $loop = {
            Write-Output "Which Packages Would you like to install? (0-8)
                [1] PackageName 1
                [2] PackageName 2
                [3] PackageName 3
                [4] PackageName 4
                [5] PackageName 5
                [6] PackageName 6
                [7] PackageName 7
                [8] PackageName 8
                [0] Exit"
        }
        Push-Location "Z:\NETWORK_PATH"
        $loop
        $UC = Read-Host -Prompt "Selection #:"
        if (1 -eq $UC) {
            $vs = Read-Host -Prompt "Which version of [Package] to install? [1] {Package 1.1} [2] {Package 1.2}"
            if (2 -eq $vs) {
                Write-Output "Installing {Package 1.2}..."
                choco install [Package 1]
            }
            elseif (1 -eq $vs) {
                Write-Output "Installing {Package 1.1}..."
                choco install [Package 1.1]
            }
        }
        if (2 -eq $UC) {
            Write-Output "Installing {Package 2}..."
            Start-Process [.MSI Path]
        }
        if (3 -eq $UC) {
            Write-Output "Installing {Package 3}..."
            Start-Process [.MSI Path]
        }
        if (4 -eq $UC) {
            Write-Output "Installing {Package 4}..."
            Start-Process [.MSI Path]
        } 
        if (5 -eq $UC) {
            Write-Output "Installing {Package 5}..."
            Start-Process [.MSI Path]
        } 
        if (6 -eq $UC) {
            Write-Output "Installing {Package 6}..."
            Start-Process [.MSI Path]
        } 
        if (7 -eq $UC) {
            Write-Output "Installing {Package 7}..."
            Start-Process [.MSI Path]
        } 
        if (8 -eq $UC) {
            Write-Output "Installing {Package 8}..."
            Start-Process [.MSI Path]
        }
        if (9 -eq $UC) {
            Write-Host "Wait, what? You're not supposed to be here!"
            #List out all of the installed products on this machine
            wmic product get name
        }
    }
    until (0 -eq $UC) {
    }
}

################## Other useful tools ##################

### Place registry hacks and other useful tools here ###

###################### JOIN COMPUTER TO DOMAIN ######################
Write-Output "Joining Domain..."
add-computer -Computername $env:Computername -DomainName [REPLACEME].local -credential { Org }\Administrator
Start-Sleep -seconds 10


###################### WAIT TO FINISH UP ######################
Write-Output "Finishing up..."
$TotalIterations = 100
$ProgressBar = $null
 
##################### CONTINUE SCRIPT AFTER REBOOT ######################
Write-Output "Enabling script to continue after reboot..."
set-location HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce
new-itemproperty . NUS1 -propertytype String -value "Powershell C:\.installer\NewUserSetup1.ps1"

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