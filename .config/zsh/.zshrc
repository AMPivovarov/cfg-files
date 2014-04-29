ZSH=~/.config/zsh
ZSH_PLUGINS=$ZSH/plugins

source /etc/profile
source $ZSH/.zsh_colors


alias zkbd='zsh /usr/share/zsh/functions/Misc/zkbd'
autoload zkbd
[[ ! -d $ZSH/.zkbd ]] && mkdir $ZSH/.zkbd
[[ ! -f $ZSH/.zkbd/$TERM-:0 ]] && zkbd 

source  $ZSH/.zkbd/$TERM-:0
[[ -n ${key[Home]}      ]]    && bindkey  "${key[Home]}"        beginning-of-line
[[ -n ${key[End]}       ]]    && bindkey  "${key[End]}"         end-of-line
[[ -n ${key[Insert]}    ]]    && bindkey  "${key[Insert]}"      overwrite-mode
[[ -n ${key[Delete]}    ]]    && bindkey  "${key[Delete]}"      delete-char
[[ -n ${key[Up]}        ]]    && bindkey  "${key[Up]}"          up-line-or-history
[[ -n ${key[Down]}      ]]    && bindkey  "${key[Down]}"        down-line-or-history
[[ -n ${key[Left]}      ]]    && bindkey  "${key[Left]}"        backward-char
[[ -n ${key[Right]}     ]]    && bindkey  "${key[Right]}"       forward-char
[[ -n ${key[Backspace]} ]]    && bindkey  "${key[Backspace]}"   backward-delete-char
[[ -n ${key[PageUp]}    ]]    && bindkey  "${key[PageUp]}"      up-line-or-history
[[ -n ${key[PageDown]}  ]]    && bindkey  "${key[PageDown]}"    down-line-or-history


fpath=($ZSH_PLUGINS/completions $fpath)
export PATH="$PATH:$HOME/.bin"

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

eval `dircolors ~/.dir_colors`


export EDITOR='vim'
export PAGER='/bin/vimpager'
alias less=$PAGER
alias zless=$PAGER

alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias ll='ls -lah'
alias s='subl'
alias pacman='yaourt'
alias poweroff='systemctl poweroff'
alias reboot='systemctl reboot'
alias memleak='valgrind --leak-check=yes'
alias open='xdg-open'
alias wlan='sudo netctl'

alias start_vm='setsid VBoxHeadless --startvm Kernel 1>~/.stdout 2>~/.stderr &'
alias stop_vm='VBoxManage controlvm Kernel poweroff'

alias ...='cd ../..'
alias ....='cd ../../..'