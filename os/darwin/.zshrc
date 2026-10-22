# Mac zsh config.
#
# Lives in os/darwin/, so the directory is what limits it to macOS. This file
# used to wrap its Homebrew section in a chezmoi `eq .chezmoi.os "darwin"`
# conditional for the same reason; the overlay directory replaced it.
#
# Shared aliases and tool inits live in common.sh, sourced below. Runtimes on
# mac come from fnm/pyenv/elixir-install (see RUNTIMES); mise is Linux-only.

# ========================================
# HOMEBREW
# ========================================

if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ========================================
# ZSH PLUGINS (via Homebrew)
# ========================================
BREW_PREFIX="$(brew --prefix 2>/dev/null || echo /opt/homebrew)"

[ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

[ -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# zsh-completions
if [ -d "$BREW_PREFIX/share/zsh-completions" ]; then
  FPATH="$BREW_PREFIX/share/zsh-completions:$FPATH"
  autoload -Uz compinit && compinit -u
fi

# GNU coreutils (use without g prefix)
[ -d "$BREW_PREFIX/opt/coreutils/libexec/gnubin" ] && \
  export PATH="$BREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"

# FZF
[ -f "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ] && \
  source "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
[ -f "$BREW_PREFIX/opt/fzf/shell/completion.zsh" ] && \
  source "$BREW_PREFIX/opt/fzf/shell/completion.zsh"

# rustup (keg-only, so not symlinked into the brew prefix; it conflicts with the rust formula)
[ -d "$BREW_PREFIX/opt/rustup/bin" ] && \
  export PATH="$BREW_PREFIX/opt/rustup/bin:$PATH"

# ========================================
# PATH (mac-specific; shared PATH lives in common.sh — incl. ~/.bun/bin)
# ========================================

# GNU coreutils handled in the darwin block above (gnubin).

# ========================================
# RUNTIMES (mac keeps its existing managers — NOT mise)
# Linux machines use mise instead (see dot_bashrc.tmpl); mise.toml pins the
# same versions this mac runs, so new machines reproduce this setup.
# ========================================
# Elixir (via elixir-lang official installer)
export PATH="$HOME/.elixir-install/installs/otp/28.1/bin:$PATH"
export PATH="$HOME/.elixir-install/installs/elixir/1.19.5-otp-28/bin:$PATH"

# fnm (node version manager)
command -v fnm &>/dev/null && eval "$(fnm env --use-on-cd)"

# pyenv (python version manager)
if command -v pyenv &>/dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

# ========================================
# HERDR
# ========================================
# smart-splits.nvim's herdr side claims ctrl+h/j/k/l globally so one chord moves
# between Neovim splits and herdr panes. TUIs that bind those keys themselves
# must be listed here, or they never see the keypress. Matched against the
# lower-cased foreground process name.
# NOTE: read by the herdr SERVER, so a running server must be restarted to pick
# up a change here — reload-config does not re-read the environment.
export SMART_SPLITS_HERDR_PASSTHROUGH_RE='^(lazygit|lazyjj|lazydocker|harlequin|btop|htop|yazi|k9s)$'

# ========================================
# CLAUDE & OPENCODE
# ========================================
export CLAUDE_CONFIG_DIR=~/.claude-work

# ZENNOTES (ZENNOTES_VAULT is shared in common.sh)
alias znv='open -a ZenNotes'

# Shared aliases + tool inits (cp = personal, cw = work)
[ -f ~/.config/shell/common.sh ] && source ~/.config/shell/common.sh

# ========================================
# ALIASES (Mac-specific only — shared aliases live in common.sh)
# ========================================
# Navigation
# Work-only shortcuts live in ~/.secrets (sourced below), not here.

# Editors / tools
alias f='yazi'
alias e='elixir'
alias weather='curl wttr.in'

# ========================================
# WINDOW MANAGER (macOS — AeroSpace + SketchyBar)
# ========================================
alias wm-start='open -a AeroSpace'
alias wm-stop='osascript -e "quit app \"AeroSpace\""'
alias wm-restart='wm-stop; sleep 1; wm-start'

# Zoxide (smarter cd) — must be last, after aliases
export _ZO_DOCTOR=0
[[ $- == *i* ]] && command -v zoxide &>/dev/null && eval "$(zoxide init zsh --cmd cd 2>/dev/null)"

# peon-ping quick controls
alias peon="bash ~/.claude-personal/hooks/peon-ping/peon.sh"
[ -f ~/.claude-personal/hooks/peon-ping/completions.bash ] && source ~/.claude-personal/hooks/peon-ping/completions.bash

# Bare `tmux` picks a session if any exist, else starts fresh
tmux() {
  if [ $# -eq 0 ] && [ -z "$TMUX" ] && command tmux has-session 2>/dev/null; then
    local s
    s=$(command tmux list-sessions -F '#S' | fzf --reverse --prompt='attach> ') \
      && command tmux attach -t "$s" \
      || command tmux new
  else
    command tmux "$@"
  fi
}

# Private secrets (not backed up)
[ -f ~/.secrets ] && source ~/.secrets

# Machine-local overrides, untracked. This replaced chezmoi's [data] block in
# ~/.config/chezmoi/chezmoi.toml. Anything that genuinely differs per machine
# goes here instead of becoming a template variable.
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
