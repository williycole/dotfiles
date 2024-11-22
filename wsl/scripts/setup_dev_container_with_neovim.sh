# setup_dev_container_with_neovim() {
#   # Find the container ID of the ggs-dev image
#   container_id=$(docker ps -q --filter ancestor=ggs-dev)
#
#   if [ -z "$container_id" + "1" ]; then
#     echo "No running container found for ggs-dev-1 image"
#     return 1
#   fi
#
#   # Install Neovim and required dependencies
#   docker exec -u root $container_id bash -c '
#     apt-get update
#     apt-get install -y neovim unzip wget
#   '
#
#   # Install StyLua
#   docker exec -u root $container_id bash -c '
#     wget https://github.com/JohnnyMorganz/StyLua/releases/download/v0.20.0/stylua-linux-x86_64.zip
#     unzip stylua-linux-x86_64.zip
#     mv stylua /usr/local/bin/
#     rm stylua-linux-x86_64.zip
#   '
#
#   # Clone and set up your Neovim configuration
#   docker exec $container_id bash -c '
#     git clone https://github.com/williycole/dotfiles.git /tmp/dotfiles
#     mkdir -p ~/.config/nvim
#     cp -r /tmp/dotfiles/wsl/nvim/* ~/.config/nvim/
#     rm -rf /tmp/dotfiles
#   '
#
#   echo "Neovim, StyLua, and dependencies set up in container: $container_id"
#   echo "To attach to the container, run: docker exec -it $container_id bash"
# }
#
# setup_dev_container_with_neovim
#
setup_dev_container_with_neovim() {
  # Find the container ID of the ggs-dev-1 container
  container_id=$(docker ps -q --filter name=ggs-dev-1)

  if [ -z "$container_id" ]; then
    echo "No running container found with name ggs-dev-1"
    return 1
  fi

  # Install Neovim and required dependencies
  docker exec -u root $container_id bash -c '
    apt-get update
    apt-get install -y neovim unzip wget
  '

  # Install StyLua
  docker exec -u root $container_id bash -c '
    wget https://github.com/JohnnyMorganz/StyLua/releases/download/v0.20.0/stylua-linux-x86_64.zip
    unzip stylua-linux-x86_64.zip
    mv stylua /usr/local/bin/
    rm stylua-linux-x86_64.zip
  '

  # Clone and set up your Neovim configuration
  docker exec $container_id bash -c '
    git clone https://github.com/williycole/dotfiles.git /tmp/dotfiles
    mkdir -p ~/.config/nvim
    cp -r /tmp/dotfiles/wsl/nvim/* ~/.config/nvim/
    rm -rf /tmp/dotfiles
  '

  echo "Neovim, StyLua, and dependencies set up in container: $container_id"
  echo "To attach to the container, run: docker exec -it $container_id bash"
}

setup_dev_container_with_neovim

