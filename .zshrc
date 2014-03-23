source /etc/profile
source ~/.zsh_colors

alias zkbd='zsh /usr/share/zsh/functions/Misc/zkbd'
autoload zkbd
[[ ! -d ~/.zkbd ]] && mkdir ~/.zkbd
[[ ! -f ~/.zkbd/$TERM-:0 ]] && zkbd 

source  ~/.zkbd/$TERM-:0
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

autoload -U compinit promptinit
compinit
promptinit

autoload -U colors
colors

if [ $HOST = 'ASUS-LEMM' ] ; then
    PROMPT="${fg_lred}%n${fg_default}:${fg_blue}%~${fg_default}$ "
else
    PROMPT="${fg_lred}%n${fg_default}@${fg_green}%m${fg_default}:${fg_blue}%~${fg_default}$ "
fi

HISTSIZE=1000
SAVEHIST=1000
HISTFILE=$HOME/.zhistory
WORDCHARS='*?_-.[]~=&;!@#$%^(){}<>'

setopt APPEND_HISTORY HIST_REDUCE_BLANKS HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE
setopt NO_BEEP 
setopt AUTO_CD
setopt extendedglob

typeset -U path cdpath fpath manpath

eval `dircolors ~/.dir_colors`
export PATH="$PATH:$HOME/.dynamic-colors/bin"
source $HOME/.dynamic-colors/completions/dynamic-colors.zsh

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

unpack () {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.tar.xz)    tar xJf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be uppacked via unpack()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

pack () {
    if [ $1 ] ; then
        case $1 in
            tbz)    tar cjvf $2.tar.bz2 $2      ;;
            tgz)    tar czvf $2.tar.gz  $2      ;;
            tar)    tar cpvf $2.tar  $2         ;;
            bz2)    bzip $2                     ;;
            gz)     gzip -c -9 -n $2 > $2.gz    ;;
            zip)    zip -r $2.zip $2            ;;
            7z)     7z a $2.7z $2               ;;
            *)      echo "'$1' cannot be packed via pack()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

display () {
    if [ $2 ] ; then
        case $2 in
            best)   mode=1920x1080      ;;
            good)   mode=1280x1024      ;;
            bad)    mode=1024x768       ;;
            *)      mode=$2             ;;
        esac
    else
        mode=1024x768
    fi

    if [ $1 ] ; then
        case $1 in
            auto)       xrandr --output eDP1 --auto                                                     ;;
            default)    xrandr --output eDP1 --auto         --output VGA1 --off                         ;;
            native)     xrandr --output eDP1 --mode $mode   --output VGA1 --off                         ;;
            external)   xrandr --output eDP1 --off          --output VGA1 --mode $mode                  ;;
            mirror)     xrandr --output eDP1 --mode $mode   --output VGA1 --mode $mode --same-as eDP1   ;;
            *)          echo "Unknown command: try $0 <command> [mode]"
                        echo ""
                        echo "Commands:"   
                        echo -e "\tauto"   
                        echo -e "\tdefault"   
                        echo -e "\tnative"   
                        echo -e "\texternal"   
                        echo -e "\tmirror"   
                        echo ""
                        echo "Modes:"
                        echo -e "\tbest - 1920x1080"   
                        echo -e "\tgood - 1280x1024"   
                        echo -e "\tbad  - 1024x768"   
                        echo -e "\t<...>"   
                        ;;
        esac
    else
        xrandr --output eDP1 --auto
    fi
}

zstyle ':completion:*' menu yes select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

