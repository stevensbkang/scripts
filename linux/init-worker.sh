credentials=$1
portainer_environment_is_agent=$2
portainer_environment_is_edge=$3

if [ "${portainer_environment_is_agent}" ]; then
  echo y | plink 10.0.1.11 -P 22 -l local_admin -pw $credentials hostname
  token=$(echo y | plink 10.0.1.11 -P 22 -l local_admin -pw $credentials sudo docker swarm join-token -q worker)
  sudo docker swarm join --token $token 10.0.1.11:2377
elif [ "${portainer_environment_is_edge}" ]; then
  echo "Edge to be configured"
fi
