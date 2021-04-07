param(
  [Parameter(Mandatory = $True)]
  [string]
  $registration_token
)

curl https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv -o desktop_agent.msi
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i desktop_agent.msi", "/quiet", "/qn", "/norestart", "/passive", "REGISTRATIONTOKEN=$registration_token", "/l* C:\Users\AgentInstall.txt" -Wait -Passthru

curl https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH -o desktop_agent_bootloader.msi
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i desktop_agent_bootloader.msi", "/quiet", "/qn", "/norestart", "/passive", "/l* C:\Users\AgentBootloaderInstall.txt" -Wait -Passthru
