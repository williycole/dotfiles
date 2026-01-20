#!/bin/bash
# Dotfile Synchronization Script
# This script synchronizes dotfiles and specific config directories to a backup location.
# It uses rsync to efficiently handle file changes, renames, and deletions.
# Usage: ./sync_dotfiles.sh
# Run this script from any directory to backup your dotfiles.

# Define the target directories
WSL_DIR=~/Repos/dotfiles/wsl
WIN_DIR=~/Repos/dotfiles/windows
UBUNTU_DIR=~/Repos/dotfiles/ubuntu/
OMARCHY_DIR=~/Repos/dotfiles/omarchy

# Function to sync files/directories using rsync
# Arguments:
# $1: Source path
# $2: Destination path
sync_dotfiles() {
  rsync -avh --delete "$1" "$2"
  # -a: Archive mode (preserves permissions, timestamps, symlinks)
  # -v: Verbose
  # -h: Human-readable
  # --delete: Remove files in dest that don't exist in source
}

# ========================================
# INDIVIDUAL DOTFILES
# ========================================
sync_dotfiles ~/.zshrc "$WSL_DIR/"
sync_dotfiles ~/.bashrc "$WSL_DIR/"

# ========================================
# OMARCHY-SPECIFIC: FULL AUTO MONITOR SWITCH
# ========================================
# This backs up:
# 1. The monitor-auto.sh script (the brain)
# 2. The autostart entry (so it runs on boot)
# 3. (Optional) monitors.conf if you ever use it
# CRITICAL: Without these, auto monitor switching breaks on restore!

# 1. Backup the auto-monitor script
sync_dotfiles ~/.local/bin/monitor-auto.sh "$OMARCHY_DIR/bin/"

# 2. Backup the autostart line (inside autostart.conf)
# We sync the whole file — safe and simple
sync_dotfiles ~/.config/hypr/autostart.conf "$OMARCHY_DIR/hypr/"

# 3. (Optional) Backup monitors.conf in case you tweak it later
sync_dotfiles ~/.config/hypr/monitors.conf "$OMARCHY_DIR/hypr/"

# 4. Make sure ~/.local/bin/ exists on restore (create placeholder)
mkdir -p "$OMARCHY_DIR/bin"
touch "$OMARCHY_DIR/bin/README.txt"
echo "# Place monitor-auto.sh here" > "$OMARCHY_DIR/bin/README.txt"

# 5. Add a restore helper (optional but GOLD)
cat > "$OMARCHY_DIR/hypr/RESTORE_MONITOR_AUTO.sh" << 'EOF'
#!/bin/bash
# RUN THIS AFTER RESTORING DOTFILES
# Makes monitor auto-switching work again

mkdir -p ~/.local/bin
cp ~/Repos/dotfiles/omarchy/bin/monitor-auto.sh ~/.local/bin/
chmod +x ~/.local/bin/monitor-auto.sh

# Ensure autostart
grep -q "monitor-auto.sh" ~/.config/hypr/autostart.conf || \
  echo "exec-once = sleep 3 && ~/.local/bin/monitor-auto.sh" >> ~/.config/hypr/autostart.conf

echo "Monitor auto-switching restored! Run: hyprctl reload"
EOF
chmod +x "$OMARCHY_DIR/hypr/RESTORE_MONITOR_AUTO.sh"

# ========================================
# TIMEWARRIOR BACKUP
# ========================================
sync_dotfiles ~/.local/share/timewarrior/data/ "$WSL_DIR/timewarrior/data/"
sync_dotfiles ~/.local/share/timewarrior/timewarrior.cfg "$WSL_DIR/timewarrior/" 2>/dev/null || true

sync_dotfiles ~/.local/share/timewarrior/data/ "$UBUNTU_DIR/timewarrior/data/"
sync_dotfiles ~/.local/share/timewarrior/timewarrior.cfg "$UBUNTU_DIR/timewarrior/" 2>/dev/null || true

sync_dotfiles ~/.local/share/timewarrior/data/ "$OMARCHY_DIR/timewarrior/data/"
sync_dotfiles ~/.local/share/timewarrior/timewarrior.cfg "$OMARCHY_DIR/timewarrior/" 2>/dev/null || true

# ========================================
# SCRIPTS BACKUP (~/Scripts)
# ========================================
sync_dotfiles ~/Scripts/ "$WSL_DIR/Scripts/"
sync_dotfiles ~/Scripts/ "$UBUNTU_DIR/Scripts/"
sync_dotfiles ~/Scripts/ "$OMARCHY_DIR/Scripts/"

# ========================================
# UBUNTU DOTFILES
# ========================================
sync_dotfiles ~/.config/nvim/ "$UBUNTU_DIR/nvim/"
sync_dotfiles ~/.config/ghostty/config "$UBUNTU_DIR/ghostty/"
sync_dotfiles ~/.config/lazygit/ "$UBUNTU_DIR/lazygit/"
sync_dotfiles ~/.config/nvim.bak/ "$UBUNTU_DIR/archived/nvim"

# ========================================
# WSL DOTFILES
# ========================================
sync_dotfiles ~/.config/nvim/ "$WSL_DIR/nvim/"
sync_dotfiles ~/.config/lazygit/ "$WSL_DIR/lazygit/"
sync_dotfiles ~/.config/nvim.bak/ "$WSL_DIR/archived/nvim"

# ========================================
# WINDOWS DOTFILES
# ========================================
sync_dotfiles ~/.config/nvim/ "$WIN_DIR/nvim/"
sync_dotfiles ~/.config/nvim.bak/ "$WIN_DIR/archived/nvim"

# ========================================
# OMARCHY: OTHER CONFIGS
# ========================================
sync_dotfiles ~/.zshrc "$OMARCHY_DIR/"
sync_dotfiles ~/.bashrc "$OMARCHY_DIR/"
sync_dotfiles ~/.config/nvim/ "$OMARCHY_DIR/nvim/"
sync_dotfiles ~/.config/lazygit/ "$OMARCHY_DIR/lazygit/"
sync_dotfiles ~/.config/ghostty/config "$OMARCHY_DIR/ghostty/"
sync_dotfiles ~/.config/nvim.bak/ "$OMARCHY_DIR/archived/nvim"
sync_dotfiles ~/.config/omarchy/branding/ "$OMARCHY_DIR/branding/"

# ========================================
# FINAL MESSAGE
# ========================================
echo "Dotfiles synchronized successfully!"
echo "MONITOR AUTO-SWITCH BACKED UP!"
echo "After restore, run: ~/Repos/dotfiles/omarchy/hypr/RESTORE_MONITOR_AUTO.sh"
