# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
alias dbeaver='~/Apps/dbeaver/dbeaver'
alias ol='ollama'
alias olr='ollama run deepseek-r1:1.5b'
alias aseprite='~/Apps/aseprite/bin/aseprite'
alias p='python'
alias cnvim="cd ~/.config/nvim"
alias cbv="cd ~/Repos/cb-vault/"
alias r="cd ~/Repos"
alias h='cd ~'
alias lg='lazygit'
alias ld='lazydocker'
alias l='lsd'
alias n='nvim'
alias bat='batcat'
alias bdf='~/Scripts/backup_dotfiles.sh'
alias dfw='sudo ufw disable'
alias efw='sudo ufw enable'
alias rsf='rm -rf ~/.local/share/nvim/swap/*'
# docker
alias dsa='docker stop $(docker ps -a -q)'
alias dra='docker rm $(docker ps -a -q)'
alias dka='docker kill $(docker ps -q)'
alias dpa='docker system prune -a'

. "$HOME/.local/share/../bin/env"
. "$HOME/.cargo/env"
