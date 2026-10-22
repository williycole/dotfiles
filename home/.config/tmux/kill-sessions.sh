#!/usr/bin/env sh
# kill-sessions.sh — pick one or more tmux sessions to kill.
# Tab marks multiple, Enter kills everything marked, Esc cancels.
# ponytail: no confirm prompt; killing the current session just switches the
# client to another, killing the last one exits the server. Add a guard if that bites.

sel=$(tmux list-sessions -F '#S' | fzf --multi --reverse \
  --prompt='kill> ' \
  --header='Tab: mark  Enter: kill  Esc: cancel') || exit 0

[ -z "$sel" ] && exit 0

printf '%s\n' "$sel" | while IFS= read -r s; do
  [ -n "$s" ] && tmux kill-session -t "$s"
done
