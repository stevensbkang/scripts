portainer_image=$1
portainer_agent_image=$2
portainer_environment_is_agent=$3
portainer_environment_is_edge=$4

## Install Docker CE
sudo apt-get -y remove docker docker-engine docker.io containerd runc
sudo apt-get -y update
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
    
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker local_admin

## Initialise Docker Swarm mode
sudo docker swarm init --advertise-addr 10.0.1.11 --default-addr-pool 10.0.1.0/23

## Install Portainer on Swarm
if [ "${portainer_environment_is_agent}" ]; then
  sudo docker volume create portainer_data
  sudo docker network create --driver overlay --attachable portainer_agent_network
  
  echo -n '1nTegr@tion' | sudo docker secret create portainer-pass -
  
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
    $portainer_image \
    --admin-password-file '/run/secrets/portainer-pass' \
    -H "tcp://tasks.portainer_agent:9001" --tlsskipverify

elif [ "${portainer_environment_is_edge}" ]; then
  echo "Hello World"
fi
