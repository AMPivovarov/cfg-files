ZSH=$HOME/.config/zsh
ZSH_PLUGINS=$ZSH/plugins
SCRIPTS_DIR=$HOME/.config/scripts

source /etc/profile
source $ZSH/zsh_colors

source $ZSH/zkbd.sh
source $ZSH/alias.sh

eval `dircolors ~/.dir_colors`


fpath=($ZSH/completions $SCRIPTS_DIR/completions $ZSH_PLUGINS/zsh-completions/src $fpath)
export PATH="$PATH:$HOME/.bin/:$SCRIPTS_DIR"
export EDITOR='vim'

export DYNAMIC_COLORS_ROOT=$ZSH_PLUGINS/dynamic-colors
export PATH="$PATH:$DYNAMIC_COLORS_ROOT/bin"
source $ZSH_PLUGINS/dynamic-colors/completions/dynamic-colors.zsh

source $ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source $ZSH_PLUGINS/fzf/key-bindings.zsh

autoload -U compinit promptinit colors
compinit
promptinit
colors


setopt prompt_subst

if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]] ; then
    PROMPT="${fg_lred}%n${fg_default}@${fg_green}%m${fg_default}:${fg_blue}%~${fg_default}$ "
else
    PROMPT="${fg_lred}%n${fg_default}:${fg_blue}%~${fg_default}$ "
fi

function check_last_exit_code() {
  local LAST_EXIT_CODE=$?
  if [[ $LAST_EXIT_CODE -ne 0 ]]; then
    local EXIT_CODE_PROMPT=' '
    EXIT_CODE_PROMPT+="%{$fg[red]%}-%{$reset_color%}"
    EXIT_CODE_PROMPT+="%{$fg_bold[red]%}$LAST_EXIT_CODE%{$reset_color%}"
    EXIT_CODE_PROMPT+="%{$fg[red]%}-%{$reset_color%}"
    echo "$EXIT_CODE_PROMPT"
  fi
}
RPROMPT='$(check_last_exit_code) '


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

