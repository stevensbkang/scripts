param(
  $portainer_image,
  $portainer_agent_image,
  $portainer_environment_is_agent,
  $portainer_environment_is_edge
)

## Fix for Docker Swarm Network
wusa /install /kb:4580390

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
if ( $portainer_environment_is_agent ) {

    
} elseif ( $portainer_environment_is_edge ) {

}
