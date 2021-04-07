param(
  [Parameter(Mandatory = $True)]
  [string]
  $registration_token
)

while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 } 
while ((Get-Service WindowsAzureTelemetryService).Status -ne 'Running') { Start-Sleep -s 5 } 
while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 } 

$registration_token = "eyJhbGciOiJSUzI1NiIsImtpZCI6Ijg2Mjg0QjJDMkE5RTNFRTQxMzdFMTU3RTVFNzhCMzc4M0Y2QzA5NjEiLCJ0eXAiOiJKV1QifQ.eyJSZWdpc3RyYXRpb25JZCI6IjJhOTI0MjEzLWZkOTctNDFiYi04MTc0LWI2NDYxYzM4MGYzNCIsIkJyb2tlclVyaSI6Imh0dHBzOi8vcmRicm9rZXItZy11cy1yMC53dmQubWljcm9zb2Z0LmNvbS8iLCJEaWFnbm9zdGljc1VyaSI6Imh0dHBzOi8vcmRkaWFnbm9zdGljcy1nLXVzLXIwLnd2ZC5taWNyb3NvZnQuY29tLyIsIkVuZHBvaW50UG9vbElkIjoiNzQxNGUyMDAtODkyNS00ZTUwLTg5ZDAtMDNmNjk1YzNmMWExIiwiR2xvYmFsQnJva2VyVXJpIjoiaHR0cHM6Ly9yZGJyb2tlci53dmQubWljcm9zb2Z0LmNvbS8iLCJHZW9ncmFwaHkiOiJVUyIsIm5iZiI6MTYxNzc1NTIwNCwiZXhwIjoxNjE4MjcyMDAwLCJpc3MiOiJSREluZnJhVG9rZW5NYW5hZ2VyIiwiYXVkIjoiUkRtaSJ9.Tyne9L4SF2L-sntG65eBdezRItRce3_mZSnFvPUxTNYxjInBqoqfBVd9MbC7VNN7_VrylpODujmn_kwg3PRy6Nyt5WNatAmtVplH-qupbVDDLaZu2XeHUEJ4lHHeYv7u80cYsn01DAOQFhyttVnS9TX8Mv_mX2c40A_kR7GgYe-NHpHDulf2cVjp5VZ0TWm8sGlm-omwTpEn5iS9RwAgiIh_-NLsEKSxRzHB9K4zu6wlqEpIwfTz-YmI3jYNj08hgLn-I5sqWZTh2y-thqwDS_rEAJ93PKVKrR_Ci7szvN47UOtTIx5cPo1x1CDkoDdBA2h_eiCLpDe4p5ZE2lHN9Q"

curl https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv -o desktop_agent.msi
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i desktop_agent.msi", "/quiet", "/qn", "/norestart", "/passive", "REGISTRATIONTOKEN=$registration_token", "/l* C:\Users\AgentInstall.txt" -Wait -Passthru

curl https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH -o desktop_agent_bootloader.msi
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i desktop_agent_bootloader.msi", "/quiet", "/qn", "/norestart", "/passive", "/l* C:\Users\AgentBootloaderInstall.txt" -Wait -Passthru

