#!/bin/bash
# save as start-devcontainer.sh

# Get Docker group ID
export DOCKER_GROUP_ID=$(getent group docker | cut -d: -f3)

# Start the container with the devcontainer CLI
devcontainer up --workspace-folder . --config .devcontainer/custom/devcontainer.json

# Connect to the container (optional)
echo "Container started. Connect with:"
echo "devcontainer exec --workspace-folder . bash"
