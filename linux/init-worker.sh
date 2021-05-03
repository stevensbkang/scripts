credentials=$1
portainer_agent_image=$2
portainer_environment_is_agent=$3
portainer_environment_is_edge=$4
portainer_admin_password=$5

if [ $portainer_environment_is_agent = 'true' ]; then
  ## Leverage SSH to grab the Swarm join token
  echo y | plink 10.0.1.11 -P 22 -l local_admin -pw $credentials hostname
  token=$(echo y | plink 10.0.1.11 -P 22 -l local_admin -pw $credentials sudo docker swarm join-token -q worker)
  
  ## Join Swarm manager with the token above
  sudo docker swarm join --token $token 10.0.1.11:2377
  
elif [ $portainer_environment_is_edge = 'true' ]; then
  ## Get the current IP address
  ip_address=$(hostname -I | cut -d ' ' -f 1)
  
  ## Generate Portainer JWT via Authentication
  portainer_jwt=$(http POST http://10.0.1.11:9000/api/auth Username="admin" Password="${portainer_admin_password}" | jq .jwt | sed 's/\"//g')    
  
  ## Grab the Edge Key once the endpoint is deployed
  edge_key=$(http --form POST http://10.0.1.11:9000/api/endpoints \
    "Authorization: Bearer ${portainer_jwt}" \
    Name="edge-${ip_address}" EndpointCreationType=4 URL="http://10.0.1.11:9000" | jq .EdgeKey | sed 's/\"//g')
    
  ## Generate a random UUID for the Edge deployment
  edge_uuid=$(uuidgen)
  
  ## Deploy Edge  
  sudo docker run -d \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/docker/volumes:/var/lib/docker/volumes \
    -v /:/host \
    -v portainer_agent_data:/data \
    --restart always \
    -e EDGE=1 \
    -e EDGE_ID=$edge_uuid \
    -e EDGE_KEY=$edge_key \
    -e CAP_HOST_MANAGEMENT=1 \
    --name portainer_edge_agent \
    $portainer_agent_image
    
fi
