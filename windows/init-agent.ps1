param(
  [Parameter(Mandatory = $True)]
  [string]
  $portainer_image
)

## Install Portainer on Swarm
docker volume create portainer_data
docker service create `
  --name portainer `
  --publish 9000:9000 `
  --publish 8000:8000 `
  --replicas=1 `
  --constraint 'node.role == manager' `
  --mount 'type=volume,source=portainer_data,destination=C:/data' `
  --mount 'type=npipe,source=\\.\pipe\docker_engine,destination=\\.\pipe\docker_engine' `
  --mount 'type=bind,source=C:\ProgramData\docker\volumes,destination=C:\ProgramData\docker\volumes' `
  $portainer_image
