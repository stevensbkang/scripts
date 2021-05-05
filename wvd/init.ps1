param(
  [Parameter(Mandatory = $True)]
  [string] $registration_token,
  [string] $vhd_location
)

curl https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv -o desktop_agent.msi
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i desktop_agent.msi", "/quiet", "/qn", "/norestart", "/passive", "REGISTRATIONTOKEN=$registration_token", "/l* C:\Users\AgentInstall.txt" -Wait -Passthru

curl https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH -o desktop_agent_bootloader.msi
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i desktop_agent_bootloader.msi", "/quiet", "/qn", "/norestart", "/passive", "/l* C:\Users\AgentBootloaderInstall.txt" -Wait -Passthru

## Install FSLogix
curl https://go.microsoft.com/fwlink/?linkid=2084562 -o FSLogix.zip
Expand-Archive .\FSLogix.zip
Start-Process -Wait -FilePath ".\FSLogix\x64\Release\FSLogixAppsSetup.exe" -ArgumentList "/install", "/quiet"

New-Item –Path "HKLM:\SOFTWARE\FSLogix" –Name "Profiles"
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name "Enabled" -Value "1" -PropertyType "DWORD"
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name "VHDLocations" -Value $vhd_location -PropertyType "MultiString"
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name "PreventLoginWithFailure" -Value "1" -PropertyType "DWORD"
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name "PreventLoginWithTempProfile" -Value "1" -PropertyType "DWORD"
