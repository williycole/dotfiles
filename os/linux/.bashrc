# Linux (Nobara/Fedora) bash config.
#
# Lives in os/linux/, so the directory is what limits it to Linux. This file
# used to wrap its whole body in a chezmoi `ne .chezmoi.os "darwin"` conditional
# for the same reason.
#
# Shared aliases and tool inits live in common.sh. Runtimes come from mise, not
# fnm/pyenv.

# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# dev works directly on the HOST. CLI tools come from mise, uv, npm and
# flatpak --user — all user-level, so no container and no admin password.

# ========================================
# SHARED CONFIG (aliases, tool inits, PATH)
# ========================================
[ -f ~/.config/shell/common.sh ] && source ~/.config/shell/common.sh

# ========================================
# RUNTIMES (mise — replaces pyenv/fnm/elixir PATH hacks)
# ========================================
command -v mise &>/dev/null && eval "$(mise activate bash)"

# ========================================
# PATH (linux-specific)
# ========================================
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -d "$HOME/.config/emacs/bin" ] && export PATH="$HOME/.config/emacs/bin:$PATH"

# flyctl
export FLYCTL_INSTALL="$HOME/.fly"
[ -d "$FLYCTL_INSTALL/bin" ] && export PATH="$FLYCTL_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
[ -d "$PNPM_HOME/bin" ] && case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

# ========================================
# ALIASES (linux-specific)
# ========================================
alias dbeaver='~/Apps/dbeaver/dbeaver'
alias aseprite='~/Apps/aseprite/bin/aseprite'
alias znv='setsid -f zennotes >/dev/null 2>&1'   # open ZenNotes (host rpm), detached
alias p='python'
alias dfw='sudo ufw disable'
alias efw='sudo ufw enable'

# Atuin (shell history) — needs bash-preexec sourced first
[ -f ~/.bash-preexec.sh ] && source ~/.bash-preexec.sh
command -v atuin &>/dev/null && eval "$(atuin init bash)"

# Zoxide (smarter cd) — must be last
command -v zoxide &>/dev/null && eval "$(zoxide init bash --cmd cd)"

# Machine-local overrides, untracked. This replaced chezmoi's [data] block in
# ~/.config/chezmoi/chezmoi.toml. Anything that genuinely differs per machine
# goes here instead of becoming a template variable.
[ -f ~/.bashrc.local ] && source ~/.bashrc.local

# Pi
export PATH="/home/dev/.local/share/mise/installs/node/26.8.1/bin:$PATH"

# peon-ping quick controls
alias peon="bash /home/dev/.claude/hooks/peon-ping/peon.sh"
[ -f /home/dev/.claude/hooks/peon-ping/completions.bash ] && source /home/dev/.claude/hooks/peon-ping/completions.bash
