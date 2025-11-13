# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
alias cnvim="cd ~/.config/nvim"
alias cbv="cd ~/repos/cb-vault/"
alias r="cd ~/repos"
alias h='cd ~'
alias lg='lazygit'
alias ld='lazydocker'
alias l='lsd'
alias n='nvim'
alias bat='batcat'
alias bdf='~/.config/scripts/backup_dotfiles.sh'
alias dfw='sudo ufw disable'
alias efw='sudo ufw enable'
alias rsf='rm -rf ~/.local/share/nvim/swap/*'
alias ol='ollama'
alias olr='ollama run deepseek-r1:1.5b'

# docker
alias dsa='docker stop $(docker ps -a -q)'
alias dra='docker rm $(docker ps -a -q)'
alias dka='docker kill $(docker ps -q)'
alias dpa='docker system prune -a'

. "$HOME/.local/share/../bin/env"
