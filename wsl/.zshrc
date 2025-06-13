# If you come from bash you might have to change your $PATH.
#
# export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# NVM setup
export NVM_DIR="$HOME/.nvm"
# This loads nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  
# This loads nvm bash_completion
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  

# Better History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Lazygit Setup TODO: Fix this
export PATH=$PATH:/path/to/lazygit/directory
alias lg="/path/to/lazygit"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# 
# ZSH_THEME="darkblood"
# ZSH_THEME="bira"
# For OhMyPosh point to windows theme if using on windows and wsl
# 
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/pure.omp.json)"




# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions)

# source $ZSH/oh-my-zsh.sh # TODO: Delete this 

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Repos/Naviagtion
alias ktf="cd ~/repos/key-to-focus/" 
alias ggs="cd ~/repos/ggs" 
alias cnvim="cd ~/.config/nvim"
alias cbv="cd ~/repos/cb-vault/" 
alias r="cd ~/repos" 
alias h='cd ~'

# Basic commands
alias termset="cd ~/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbweLocalState"
alias lg='lazygit'
alias ld='lazydocker'
alias l='lsd'
alias n='nvim'
alias bat='batcat'
alias bdf='~/.config/scripts/backup_dotfiles.sh'
alias dfw='sudo ufw disable'
alias efw='sudo ufw enable'
alias rsf='rm -rf ~/.local/share/nvim/swap/*'
alias spt='ncspot'

#source python venv on ubuntu
alias pinit='python3.12 -m venv .venv'
alias psource='source .venv/bin/activate'
alias pinstall='pip install -r requirements.txt'

# Ghostty
alias lc="ghostty +list-keybinds"

# AI Tooling
alias ol='ollama'
alias olr='ollama run deepseek-r1:1.5b'

# Docker 
alias dsa='docker stop $(docker ps -a -q)'
alias dra='docker rm $(docker ps -a -q)'
alias dka='docker kill $(docker ps -q)'
alias dpa='docker system prune -a'

# GQL
alias rgql='go run github.com/99designs/gqlgen generate'
alias ggql='go run github.com/99designs/gqlgen generate'


# Devcontainers 
#
# for inital building of docker/devcontainer env
alias dci='USER_ID=$(id -u) GROUP_ID=$(id -g) DOCKER_GROUP_ID=$(getent group docker | cut -d: -f3) docker compose run --rm -it --build dev-init'
# spin up devcontainer
alias dcu='devcontainer up --workspace-folder .'
# attach to dev container
alias dca='~/.config/scripts/attach_to_dev_container.sh'
# clear cache for new dev container build 
# alias dcc='USER_ID=$(id -u) GROUP_ID=$(id -g) DOCKER_GROUP_ID=$(getent group docker | cut -d: -f3) docker compose build --no-cache'


# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(oh-my-posh init zsh)"
export PATH="$PATH:/usr/local/go/bin"

# if docker leavers your groups run `newgrp docker` then run `groups`
#

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH=$PATH:$HOME/go/bin
