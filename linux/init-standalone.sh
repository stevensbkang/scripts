portainer_image=$1
portainer_admin_password=$2

## Add local_admin account to the docker group
sudo usermod -aG docker local_admin

echo -n $portainer_admin_password > /tmp/portainer_password

sudo docker volume create portainer_data
sudo docker run -d -p 8000:8000 -p 9000:9000 \
  --name=portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /tmp/portainer_password:/tmp/portainer_password \
  -v portainer_data:/data $portainer_image \
  --admin-password-file /tmp/portainer_password
