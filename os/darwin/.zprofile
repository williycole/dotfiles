# Mac login shell: put brew on PATH for login shells (deduped).
#
# Lives in os/darwin/; the directory is the gate a chezmoi
# `eq .chezmoi.os "darwin"` conditional used to be.

eval "$(/opt/homebrew/bin/brew shellenv zsh)"
