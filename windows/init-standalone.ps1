param(
  $portainer_image
)

## Fix for Docker Swarm Network
# Install-Module PSWindowsUpdate -Force -Confirm:$false
# Get-WindowsUpdate -Install -AutoReboot:$false -ForceDownload -Confirm:$false

docker volume create portainer_data
docker run -d -p 9000:9000 `
  --name portainer `
  --restart always `
  --constraint 'node.platform.os == windows' `
  --mount 'type=npipe,source=\\.\pipe\docker_engine,destination=\\.\pipe\docker_engine' `
  --mount 'type=bind,source=C:\ProgramData\docker\volumes,destination=C:\ProgramData\docker\volumes' `
  --mount 'type=volume,source=portainer_data,destination=C:/data' `
  $portainer_image  
