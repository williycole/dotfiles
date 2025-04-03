#!/bin/bash

# Dotfile Synchronization Script
# This script synchronizes dotfiles and specific config directories to a backup location.
# It uses rsync to efficiently handle file changes, renames, and deletions.

# Usage: ./sync_dotfiles.sh
# Run this script from any directory to backup your dotfiles.

# Define the target directories
WSL_DIR=~/repos/dotfiles/wsl
WIN_DIR=~/repos/dotfiles/windows

# Function to sync files/directories using rsync
# Arguments:
#   $1: Source path
#   $2: Destination path
sync_dotfiles() {
  rsync -avh --delete "$1" "$2"
  # Flags explanation:
  # -a: Archive mode (preserves permissions, timestamps, etc.)
  # -v: Verbose output (shows what's being transferred)
  # -h: Human-readable output (file sizes in KB, MB, etc.)
  # --delete: Remove files in dest that don't exist in source
}

# Sync individual dotfiles
sync_dotfiles ~/.zshrc "$WSL_DIR/"
sync_dotfiles ~/.bashrc "$WSL_DIR/"

# Sync specific .config subdirectories
# For each directory, we sync the contents to a similarly named
# directory in the backup location

# NOTE: Synce dotfiles for WSL
sync_dotfiles ~/.config/nvim/ "$WSL_DIR/nvim/"
sync_dotfiles ~/.config/lazygit/ "$WSL_DIR/lazygit/"
sync_dotfiles ~/.config/nvim.bak/ "$WSL_DIR/archived/nvim"
sync_dotfiles ~/.config/go/ "$WSL_DIR/go/"
sync_dotfiles ~/.config/dlv/ "$WSL_DIR/dlv/"
sync_dotfiles ~/.config/scripts/ "$WSL_DIR/scripts/"

# NOTE: Sync dotfiles for Windows
sync_dotfiles ~/.config/nvim/ "$WIN_DIR/nvim/"
sync_dotfiles ~/.config/nvim.bak/ "$WIN_DIR/archived/nvim"

echo "Dotfiles synchronized successfully!"

# Note: After running this script, remember to:
# 1. Review the changes in your dotfiles repository
# 2. Commit the changes
# 3. Push the commits to your remote repository if applicable
