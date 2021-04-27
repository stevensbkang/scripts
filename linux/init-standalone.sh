portainer_image=$1

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

echo -n '1nTegr@tion' > /tmp/portainer_password

sudo docker volume create portainer_data
sudo docker run -d -p 8000:8000 -p 9000:9000 \
  --name=portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /tmp/portainer_password:/tmp/portainer_password \
  -v portainer_data:/data $portainer_image \
  --admin-password-file /tmp/portainer_password
