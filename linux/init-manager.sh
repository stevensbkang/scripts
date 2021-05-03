portainer_image=$1
portainer_agent_image=$2
portainer_environment_is_agent=$3
portainer_environment_is_edge=$4
portainer_admin_password=$5

## Initialise Docker Swarm mode
sudo docker swarm init --advertise-addr 10.0.1.11 --default-addr-pool 10.0.1.0/23

## Initialise Portainer environment
sudo docker volume create portainer_data
sudo docker network create --driver overlay --attachable portainer_agent_network  
echo -n $portainer_admin_password > /tmp/portainer_admin_password

## Install Portainer on Swarm
if [ $portainer_environment_is_agent == 'true' ]; then
  
  sudo docker service create \
    --name portainer_agent \
    --network portainer_agent_network \
    --mode global \
    --constraint 'node.platform.os == linux' \
    --mount type=bind,src=//var/run/docker.sock,dst=/var/run/docker.sock \
    --mount type=bind,src=//var/lib/docker/volumes,dst=/var/lib/docker/volumes \
    $portainer_agent_image
    
  sudo docker service create \
    --name portainer \
    --network portainer_agent_network \
    --publish 9000:9000 \
    --publish 8000:8000 \
    --replicas=1 \
    --constraint 'node.role == manager' \
    --mount type=bind,src=//tmp/portainer_admin_password,dst=/tmp/portainer_admin_password \
    $portainer_image \
    --admin-password-file /tmp/portainer_admin_password \
    -H "tcp://tasks.portainer_agent:9001" --tlsskipverify

elif [ $portainer_environment_is_edge == 'true' ]; then
  sudo docker service create \
    --name portainer \
    --publish 9000:9000 \
    --publish 8000:8000 \
    --replicas=1 \
    --constraint 'node.role == manager' \
    --mount type=bind,src=//var/run/docker.sock,dst=/var/run/docker.sock \
    --mount type=bind,src=//tmp/portainer_admin_password,dst=/tmp/portainer_admin_password \
    --mount type=bind,src=//var/lib/docker/volumes,dst=/var/lib/docker/volumes \
    $portainer_image \
    --admin-password-file /tmp/portainer_admin_password
fi
