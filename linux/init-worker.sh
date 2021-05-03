credentials=$1
portainer_environment_is_agent=$2
portainer_environment_is_edge=$3
portainer_admin_password=$4

if [ "${portainer_environment_is_agent}" ]; then
  echo y | plink 10.0.1.11 -P 22 -l local_admin -pw $credentials hostname
  token=$(echo y | plink 10.0.1.11 -P 22 -l local_admin -pw $credentials sudo docker swarm join-token -q worker)
  sudo docker swarm join --token $token 10.0.1.11:2377
elif [ "${portainer_environment_is_edge}" ]; then
  # portainer_jwt=$(curl -d "{\"username\":\"admin\", \"password\":\"${portainer_admin_password}\"}" -X POST http://20.193.66.178:9000/api/auth | jq .jwt | sed 's/\"//g')
  
  portainer_jwt=$(http POST http://20.193.66.178:9000/api/auth Username="admin" Password="${portainer_admin_password}" | jq .jwt | sed 's/\"//g')
    
  edge_key=$(http --form POST http://20.193.66.178:9000/api/endpoints \
    "Authorization: Bearer ${portainer_jwt}" \
    Name="edge-agent" EndpointCreationType=4 | jq .EdgeKey | sed 's/\"//g')
      
  
fi
