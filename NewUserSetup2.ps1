###################### BEGIN CLEANUP ######################
Write-Output "Cleaning up..."
Write-Output "Wait here until installers are finished to delete setup directories."
Start-Sleep -Seconds 30 
Remove-Item "C:\.installer" -Recurse -Force
Write-Progress -Completed -Activity "Completed"

###################### REMOVE HKLM KEY ######################
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "NUS2"

###################### ENABLE UAC ######################
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 1
