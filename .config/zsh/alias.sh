alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias ll='ls -lah'
alias l='ls -lh'
alias g='git'
alias s='subl'

alias memleak='valgrind --leak-check=yes'
alias open='xdg-open'

alias pacman='yaourt'

if hash netctl 2>/dev/null; then
	alias wlan='sudo netctl'
fi
if hash systemctl 2>/dev/null; then
	alias poweroff='systemctl poweroff'
	alias reboot='systemctl reboot'
fi

# alias start_vm='setsid VBoxHeadless --startvm Kernel 1>~/.stdout 2>~/.stderr &'
# alias stop_vm='VBoxManage controlvm Kernel poweroff'

alias ...='cd ../..'
alias ....='cd ../../..'