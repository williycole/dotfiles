#!/bin/bash

# Define the target directory
TARGET_DIR=~/repos/dotfiles/wsl
NVIM_TARGET_DIR2=~/repos/dotfiles/windows

# Copy individual dotfiles
cp ~/.zshrc "$TARGET_DIR/"
cp ~/.bashrc "$TARGET_DIR/"

# Copy the entire .config directory
# cp -r ~/.config "$TARGET_DIR/"

# Backup nvim for WSL
cp -r ~/.config/nvim "$TARGET_DIR/"
# Backup nvim for Windows
cp -r ~/.config/nvim "$NVIM_TARGET_DIR2"

cp -r ~/.config/lazygit "$TARGET_DIR/"
cp -r ~/.config/go "$TARGET_DIR/"
cp -r ~/.config/dlv "$TARGET_DIR/"
cp -r ~/.config/scripts "$TARGET_DIR/"

echo "Dotfiles and .config copied successfully!"

