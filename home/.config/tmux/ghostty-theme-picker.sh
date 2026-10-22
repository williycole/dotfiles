#!/bin/sh
# Ghostty theme picker with auto-reload after save (w) or exit.

PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

CONFIG_DIR="${GHOSTTY_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/ghostty}"
THEME_FILE="$CONFIG_DIR/auto/theme.ghostty"
RELOAD="$HOME/.config/tmux/ghostty-reload.sh"

reload() {
  if [ -x "$RELOAD" ]; then
    "$RELOAD"
  else
    pkill -SIGUSR2 ghostty 2>/dev/null || true
  fi
}

watcher_pid=
if command -v fswatch >/dev/null 2>&1; then
  mkdir -p "$(dirname "$THEME_FILE")"
  touch "$THEME_FILE"
  fswatch -o "$THEME_FILE" | while read -r _; do reload; done &
  watcher_pid=$!
fi

ghostty +list-themes
status=$?

if [ -n "$watcher_pid" ]; then
  kill "$watcher_pid" 2>/dev/null || true
  pkill -P "$watcher_pid" 2>/dev/null || true
fi

reload
exit "$status"
