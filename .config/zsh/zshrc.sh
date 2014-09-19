ZSH=$HOME/.config/zsh
ZSH_PLUGINS=$ZSH/plugins

source /etc/profile
source $ZSH/zsh_colors

source $ZSH/zkbd.sh
source $ZSH/alias.sh

eval `dircolors ~/.dir_colors`


fpath=($ZSH_PLUGINS/completions $fpath)
export PATH="$PATH:$HOME/.bin"
export EDITOR='vim'

source $ZSH_PLUGINS/display.zsh
source $ZSH_PLUGINS/pack.zsh

export DYNAMIC_COLORS_ROOT=$ZSH_PLUGINS/dynamic-colors
export PATH="$PATH:$DYNAMIC_COLORS_ROOT/bin"
source $ZSH_PLUGINS/dynamic-colors/completions/dynamic-colors.zsh


autoload -U compinit promptinit colors
compinit
promptinit
colors


if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]] ; then
    PROMPT="${fg_lred}%n${fg_default}@${fg_green}%m${fg_default}:${fg_blue}%~${fg_default}$ "
else
    PROMPT="${fg_lred}%n${fg_default}:${fg_blue}%~${fg_default}$ "
fi


HISTSIZE=1000
SAVEHIST=1000
HISTFILE=$ZSH/.zhistory
WORDCHARS='*?_-.[]~=&;!@#$%^(){}<>'

setopt APPEND_HISTORY HIST_REDUCE_BLANKS HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE
setopt NO_BEEP 
setopt AUTO_CD
setopt extendedglob

typeset -U path cdpath fpath manpath

zstyle ':completion:*' menu yes select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

