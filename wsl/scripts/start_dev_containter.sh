#!/bin/bash

# Get correct IDs
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
export DOCKER_GROUP_ID=$(getent group docker | cut -d: -f3)

# Ensure Docker socket has correct permissions
sudo chown root:docker /var/run/docker.sock
sudo chmod 660 /var/run/docker.sock

# Create a temporary docker-compose override file
cat >docker-compose.override.yml <<EOL
services:
  dev-init:
    user: "${USER_ID}:${DOCKER_GROUP_ID}"
    volumes:
      - ~/.config/gcloud:/home/dev/.config/gcloud
    environment:
      - GOOGLE_APPLICATION_CREDENTIALS=/home/dev/.config/gcloud/application_default_credentials.json
  dev:
    user: "${USER_ID}:${DOCKER_GROUP_ID}"
    volumes:
      - ~/.config/gcloud:/home/dev/.config/gcloud
    environment:
      - GOOGLE_APPLICATION_CREDENTIALS=/home/dev/.config/gcloud/application_default_credentials.json
EOL

# Start the development environment
docker compose up -d

# Clean up
rm docker-compose.override.yml

echo "Development environment started. Connect with:"
echo "docker exec -it -u dev ggs-dev-1 bash"
##!/bin/bash
## save as start-dev.sh
#
## Clean up existing containers
#docker kill $(docker ps -q) 2>/dev/null
#docker system prune -f
#
## Get user and group IDs
#export USER_ID=$(id -u)
#export GROUP_ID=$(id -g)
#export DOCKER_GROUP_ID=$(getent group docker | cut -d: -f3)
#
## Create writable directory for gcloud credentials
#mkdir -p ~/.config/gcloud-dev-container
#
## Copy current credentials to the writable directory
#cp -r ~/.config/gcloud/* ~/.config/gcloud-dev-container/
#
## Set permissions
#chmod -R 777 ~/.config/gcloud-dev-container
#
## Set environment variable for Docker Compose
#export GCLOUD_CONFIG_PATH="${HOME}/.config/gcloud-dev-container"
#
## Start dev container
#docker compose up --build
