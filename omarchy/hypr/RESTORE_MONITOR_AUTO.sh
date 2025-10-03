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
