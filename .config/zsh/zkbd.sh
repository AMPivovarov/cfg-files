ZKBD=$ZSH/zkbd
alias zkbd='zsh /usr/share/zsh/functions/Misc/zkbd'
autoload zkbd
[[ ! -d $ZKBD ]] && mkdir $ZKBD
[[ ! -f $ZKBD/$TERM-:0 ]] && zkbd 

# Use 'cat > /dev/null' to manually discover codes 
source  $ZKBD/$TERM-:0
bindkey -e
[[ -n ${key[Home]}      ]]    && bindkey  "${key[Home]}"        beginning-of-line
[[ -n ${key[End]}       ]]    && bindkey  "${key[End]}"         end-of-line
[[ -n ${key[Insert]}    ]]    && bindkey  "${key[Insert]}"      overwrite-mode
[[ -n ${key[Delete]}    ]]    && bindkey  "${key[Delete]}"      delete-char
[[ -n ${key[Up]}        ]]    && bindkey  "${key[Up]}"          up-line-or-history
[[ -n ${key[Down]}      ]]    && bindkey  "${key[Down]}"        down-line-or-history
[[ -n ${key[Left]}      ]]    && bindkey  "${key[Left]}"        backward-char
[[ -n ${key[Right]}     ]]    && bindkey  "${key[Right]}"       forward-char
[[ -n ${key[Backspace]} ]]    && bindkey  "${key[Backspace]}"   backward-delete-char
[[ -n ${key[PageUp]}    ]]    && bindkey  "${key[PageUp]}"      history-beginning-search-backward
[[ -n ${key[PageDown]}  ]]    && bindkey  "${key[PageDown]}"    history-beginning-search-forward

# Codes not discovered by zkbd
[[ -n ${key[CtrlLeft]}  ]]    && bindkey  "${key[CtrlLeft]}"    emacs-backward-word
[[ -n ${key[CtrlRight]} ]]    && bindkey  "${key[CtrlRight]}"   emacs-forward-word
