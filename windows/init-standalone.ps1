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

## Deploy standalone Portainer instance
mkdir C:\Temp
echo $portainer_admin_password > C:/Temp/portainer_password.txt

docker run --name portainer -d -p 9000:9000 --restart always `
  --mount 'type=npipe,source=\\.\pipe\docker_engine,destination=\\.\pipe\docker_engine' `
  --mount 'type=bind,source=C:\ProgramData\docker\volumes,destination=C:\ProgramData\docker\volumes' `
  --mount 'type=volume,source=portainer_data,destination=C:/data' `
  --mount 'type=bind,source=C:\Temp,destination=C:/Temp' `
  portainerci/portainer:develop `
  --admin-password-file "C:/Temp/portainer_password.txt"
