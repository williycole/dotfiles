#!/bin/bash

# Define the target directory
TARGET_DIR=~/repos/dotfiles/wsl

# Copy individual dotfiles
cp ~/.zshrc "$TARGET_DIR/"
cp ~/.bashrc "$TARGET_DIR/"

# Copy the entire .config directory
# cp -r ~/.config "$TARGET_DIR/"

# Optionally, you can copy specific subdirectories instead:
cp -r ~/.config/nvim "$TARGET_DIR/"
cp -r ~/.config/lazygit "$TARGET_DIR/"
cp -r ~/.config/go "$TARGET_DIR/"
cp -r ~/.config/dlv "$TARGET_DIR/"
cp -r ~/.config/scripts "$TARGET_DIR/"

echo "Dotfiles and .config copied successfully!"

