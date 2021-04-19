# param(
#   [Parameter(Mandatory = $True)]
#   [string]
#   $portainer_image
# )

## Open Firewall for Docker Swarm mode Initialisation
New-NetFirewallRule -DisplayName 'Allow Swarm TCP' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 2377, 7946 | Out-Null
New-NetFirewallRule -DisplayName 'Allow Swarm UDP' -Direction Inbound -Action Allow -Protocol UDP -LocalPort 4789, 7946 | Out-Null

## Initialise Docker Swarm mode
docker swarm init --advertise-addr 10.0.1.11 --default-addr-pool 10.0.1.0/23

## Configuration of SSH Server
Add-WindowsCapability -Online -Name (Get-WindowsCapability -Online -Name 'OpenSSH.Server*').Name
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
Get-NetFirewallRule -Name *ssh*
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

## Install Portainer on Swarm
# docker volume create portainer_data
# docker service create `
#   --name portainer `
#   --publish 9000:9000 `
#   --publish 8000:8000 `
#   --replicas=1 `
#   --constraint 'node.role == manager' `
#   --mount 'type=volume,source=portainer_data,destination=C:/data' `
#   --mount 'type=npipe,source=\\.\pipe\docker_engine,destination=\\.\pipe\docker_engine' `
#   --mount 'type=bind,source=C:\ProgramData\docker\volumes,destination=C:\ProgramData\docker\volumes' `
#   $portainer_image
