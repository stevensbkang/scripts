param(
  $portainer_image,
  $portainer_admin_password
)

## Configuration of SSH Server
Add-WindowsCapability -Online -Name (Get-WindowsCapability -Online -Name 'OpenSSH.Server*').Name
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
Get-NetFirewallRule -Name *ssh*
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

docker run --name portainer -d -p 9000:9000 --restart always `
  --mount 'type=npipe,source=\\.\pipe\docker_engine,destination=\\.\pipe\docker_engine' `
  --mount 'type=bind,source=C:\ProgramData\docker\volumes,destination=C:\ProgramData\docker\volumes' `
  --mount 'type=volume,source=portainer_data,destination=C:\data' `
  $portainer_image

## Body for Portainer Admin password  
$credential_body = @{
  username = "admin"
  password = $portainer_admin_password
} | ConvertTo-Json
  
## Set Portainer admin password
Start-Sleep 10 
Invoke-RestMethod -Uri http://10.0.1.11:9000/api/users/admin/init -ContentType "application/json" -Method POST -Body $credential_body

$res = Invoke-WebRequest -Uri http://10.0.1.11:9000/api/auth -Method POST -Body $credential_body -UseBasicParsing

$portainer_jwt = ($res.Content | ConvertFrom-Json).jwt

$params = @{
    Uri         = 'http://10.0.1.11:9000/api/endpoints'
    Headers     = @{ 'Authorization' = "Bearer $portainer_jwt" }
    Method      = 'Post'
    Body        = @{ 'Name' = "local" ; EndpointCreationType = 1}
}

Invoke-WebRequest @params -UseBasicParsing
