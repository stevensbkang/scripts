credentials=$1

## Install Docker CE
# sudo apt-get -y update
# sudo apt-get -y install \
#     apt-transport-https \
#     ca-certificates \
#     curl \
#     gnupg \
#     lsb-release

# curl -fsSL https://get.docker.com -o get-docker.sh
# sudo sh get-docker.sh
# sudo usermod -aG docker local_admin

## Install Putty tools for plink
# sudo apt-get install -y putty-tools

echo y | plink 10.0.1.11 -P 22 -l local_admin -pw $credentials hostname
token=$(echo y | plink 10.0.1.11 -P 22 -l local_admin -pw $credentials docker swarm join-token -q worker)

sudo docker swarm join --token $token 10.0.1.11:2377
