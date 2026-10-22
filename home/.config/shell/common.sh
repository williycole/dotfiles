#!/bin/sh
# Shared shell config — sourced by .zshrc and .bashrc on all platforms
# Edit this file to add aliases/tool inits that apply everywhere.

# ========================================
# PATH
# ========================================
export PATH="$HOME/Scripts:$HOME/.local/bin:$PATH"
[ -d "$HOME/.bun/bin" ] && export PATH="$HOME/.bun/bin:$PATH"   # bun (both OSes)

# ========================================
# TOOL INITS
# ========================================
# Starship prompt
if command -v starship &>/dev/null; then
  [ -n "$ZSH_VERSION" ]  && eval "$(starship init zsh)"
  [ -n "$BASH_VERSION" ] && eval "$(starship init bash)"
fi

# Atuin shell history
if command -v atuin &>/dev/null; then
  [ -n "$ZSH_VERSION" ]  && eval "$(atuin init zsh)"
  [ -n "$BASH_VERSION" ] && eval "$(atuin init bash)"
fi

# Language runtimes are activated per-platform in .zshrc/.bashrc, not here:
# mac uses fnm/pyenv/elixir-install; Linux uses mise (see mise.toml for pinned versions).

# ========================================
# LS / BAT TOOL ALIASES
# ========================================
# bat: ubuntu/debian installs it as 'batcat' due to naming conflict
if ! command -v bat &>/dev/null && command -v batcat &>/dev/null; then
  alias bat='batcat'
fi

# cat a single .md file to a terminal -> render with glow instead.
# Guards: tty output only (pipes/redirects use real cat), single .md arg, glow present.
cat() {
  if [[ -t 1 && $# -eq 1 && "$1" == *.md && -f "$1" ]] && command -v glow &>/dev/null; then
    glow -p "$1"
  else
    command cat "$@"
  fi
}

# ls: prefer eza, fall back to lsd, then plain ls
if command -v eza &>/dev/null; then
  alias ls='eza --icons=auto'
  alias ll='eza -la --icons=auto'
  alias lt='eza --tree --icons=auto'
  alias l='eza --icons=auto'
elif command -v lsd &>/dev/null; then
  alias ls='lsd'
  alias ll='lsd -la'
  alias lt='lsd --tree'
  alias l='lsd'
fi

# ========================================
# NAVIGATION
# ========================================
alias h='cd ~'
alias r='cd ~/Repos'
alias cbv='cd ~/Repos/cb-vault/'
alias cnvim='cd ~/.config/nvim'

# ========================================
# EDITORS / TOOLS
# ========================================
export EDITOR=nvim
export VISUAL=nvim
export ZENNOTES_VAULT="$HOME/Repos/personal/cb-vault"   # zen CLI default vault (both OSes)
alias n='nvim'
alias lg='lazygit'
alias ld='lazydocker'
alias lj='lazyjj'
alias ju='jjui'
alias bdf='~/Scripts/backup_dotfiles.sh'
alias rsf='rm -rf ~/.local/share/nvim/swap/*'
alias ccp='CLAUDE_CONFIG_DIR=~/.claude-personal $(which claude)'
alias ccw='CLAUDE_CONFIG_DIR=~/.claude-work $(which claude)'

# cliamp opens on its own radio provider by default, which fails outright here —
# radio.cliamp.stream does not resolve here. Spotify is the reason it is
# installed, so go straight there. Nothing in config.toml sets a default
# provider; the flag is the only way.
alias cliamp='cliamp --provider spotify'

# pi profiles, the pi half of ccp/ccw. Only credentials differ per profile.
# pi's own auth.json (openai-codex, opencode-go) follows PI_CODING_AGENT_DIR.
# The claude-bridge provider follows CLAUDE_CONFIG_DIR, the same dir ccp/ccw set,
# so pi reuses those logins instead of adding a third. cursor keeps its creds in
# the cursor CLI and google reads $GEMINI_API_KEY, so neither one is per-profile.
# The rest (settings.json, extensions, the 1.4G npm dir) links back to
# ~/.pi/agent, which keeps one config to maintain instead of three. Credentials
# and projects-memory are the exceptions, since work project notes have no
# business showing up in a personal session.
# ponytail: the links get made once, on first run. Add a NEW file to
# ~/.pi/agent that the profiles should see, then: rm -rf ~/.pi-personal ~/.pi-work
_pi() {
  profile=$1; shift
  dir="$HOME/.pi-$profile/agent"
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
    for f in "$HOME"/.pi/agent/*; do
      case "${f##*/}" in
        auth.json|sessions|projects-memory|*-store.json|*cache*|*.bak) continue ;;
      esac
      ln -sfn "$f" "$dir/${f##*/}"
    done
    # Linear is a work server, so it is not in the base mcp.json. Any profile
    # with an mcp-<profile>.json next to it gets that one as its mcp.json.
    if [ -f "$HOME/.pi/agent/mcp-$profile.json" ]; then
      ln -sfn "$HOME/.pi/agent/mcp-$profile.json" "$dir/mcp.json"
    fi
  fi
  CLAUDE_CONFIG_DIR="$HOME/.claude-$profile" PI_CODING_AGENT_DIR="$dir" pi "$@"
}
alias pp='_pi personal --provider claude-bridge --models "claude-bridge/*,openai-codex/*"'
alias pw='_pi work --models "cursor/*,google/*,claude-bridge/*"'
alias f='yazi'

# ========================================
# DOCKER
# ========================================
alias dsa='docker stop $(docker ps -a -q)'
alias dra='docker rm $(docker ps -a -q)'
alias dka='docker kill $(docker ps -q)'
alias dpa='docker system prune -a'

# ========================================
# SEVERED LINK NUDGE
# ========================================
# Was a chezmoi drift check. Drift is no longer possible for a linked file: the
# repo file and the live file are one inode, so there is nothing to differ.
#
# What replaced it is the failure that IS still possible. Some applications save by
# replacing a file rather than writing through it, which turns a symlink back into a
# regular file and silently detaches it from the repo. Prompt Security rewriting
# .claude/settings.json was the original example of a tool doing this behind your
# back — that file is now deliberately unmanaged, but the class of problem remains.
#
# `dots status` names any such path as `severed`; `just adopt <path>` recovers it.
#
# Once a DAY, not every prompt: the check walks ~120 paths, which is fine daily and
# unacceptable per-shell when herdr opens a dozen panes. The stamp is written before
# the check runs, so a failure costs one skipped day rather than a hang on every new
# shell.
#
# Manual equivalent, no waiting: `just status` in ~/Repos/dotfiles.
case $- in
  *i*)
    if [ -x "$HOME/Repos/dotfiles/bin/dots" ]; then
      _dots_stamp="${XDG_CACHE_HOME:-$HOME/.cache}/dots-link-check"
      if [ ! -f "$_dots_stamp" ] || [ -n "$(find "$_dots_stamp" -mtime +0 2>/dev/null)" ]; then
        mkdir -p "$(dirname "$_dots_stamp")" 2>/dev/null
        : > "$_dots_stamp"
        _dots_sev="$("$HOME/Repos/dotfiles/bin/dots" status 2>/dev/null | grep -c 'should be a link, is a real file')"
        if [ "${_dots_sev:-0}" -gt 0 ]; then
          printf '\033[33m⚠ %s severed link(s)\033[0m — an app replaced a managed file. `just status` in ~/Repos/dotfiles\n' "$_dots_sev"
        fi
        unset _dots_sev
      fi
      unset _dots_stamp
    fi
    ;;
esac
