param(
  $portainer_image,
  $portainer_agent_image,
  $portainer_environment_is_agent,
  $portainer_environment_is_edge,
  $portainer_admin_password
)

## Configuration of SSH Server
Add-WindowsCapability -Online -Name (Get-WindowsCapability -Online -Name 'OpenSSH.Server*').Name
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
Get-NetFirewallRule -Name *ssh*
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

## Body for Portainer Admin password  
$credential_body = @{
  username = "admin"
  password = $portainer_admin_password
} | ConvertTo-Json

## Install Portainer on Swarm
if ( $portainer_environment_is_agent ) {
  ## Open Firewall for Docker Swarm mode Initialisation
  New-NetFirewallRule -DisplayName 'Allow Swarm TCP' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 2377, 7946 | Out-Null
  New-NetFirewallRule -DisplayName 'Allow Swarm UDP' -Direction Inbound -Action Allow -Protocol UDP -LocalPort 4789, 7946 | Out-Null

  ## Initialise Docker Swarm mode
  docker swarm init --advertise-addr 10.0.1.11 --listen-addr 10.0.1.11:2377 --default-addr-pool 10.0.1.0/23
  
  docker volume create portainer_data
  docker network create -d overlay portainer_agent_network --subnet 192.168.0.0/24
  
  docker service create `
    --name portainer_agent `
    --mode=global `
    --network=portainer_agent_network `
    --constraint 'node.platform.os == windows' `
    --mount 'type=npipe,source=\\.\pipe\docker_engine,destination=\\.\pipe\docker_engine' `
    --mount 'type=bind,source=C:\ProgramData\docker\volumes,destination=C:\ProgramData\docker\volumes' `
    $portainer_agent_image
  
  docker service create `
    --name portainer `
    --publish 9000:9000 `
    --publish 8000:8000 `
    --replicas=1 `
    --network=portainer_agent_network `
    --constraint 'node.role == manager' `
    --constraint 'node.platform.os == windows' `
    --mount 'type=volume,source=portainer_data,destination=C:/data' `
    $portainer_image -H "tcp://tasks.portainer_agent:9001" --tlsskipverify
  
  ## Set Portainer admin password
  Start-Sleep 10 
  Invoke-RestMethod -Uri http://10.0.1.11:9000/api/users/admin/init -Headers -ContentType "application/json" -Method POST -Body $credential_body
  
} elseif ( $portainer_environment_is_edge ) {
  docker volume create portainer_data
    
  docker run --name portainer -d -p 9000:9000 --restart always `
    --mount 'type=npipe,source=\\.\pipe\docker_engine,destination=\\.\pipe\docker_engine' `
    --mount 'type=bind,source=C:\ProgramData\docker\volumes,destination=C:\ProgramData\docker\volumes' `
    --mount 'type=volume,source=portainer_data,destination=C:/data' `
    $portainer_image
  
  ## Set Portainer admin password
  Start-Sleep 10 
  Invoke-RestMethod -Uri http://10.0.1.11:9000/api/users/admin/init -Headers -ContentType "application/json" -Method POST -Body $credential_body  
}
