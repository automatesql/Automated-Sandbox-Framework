# Setting view options
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideDrivesWithNoMedia" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowSyncProviderNotifications" 0

# Hide Edge first run experience
New-Item "HKLM:\Software\Policies\Microsoft\Edge"  
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Name "HideFirstRunExperience" -Value 1 -PropertyType DWORD

#set to the highperformance profile
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Disable password expiration for Administrator.  CAUTION: Typically, you'll override this setting with a group policy once the machine is added to a domain.
Set-LocalUser Administrator -PasswordNeverExpires $true