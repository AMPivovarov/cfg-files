#!/bin/sh

# wmctrl -l \
# | awk '{if ($2 != -1) {printf $2+1 "\n" $4; {for(i=5;i<=NF;i++) printf " " $i;}; printf "\n" $1 "\n"}}' \
# | zenity --print-column=3 --title "Window List" --list --column WS --column Title --column Id 2>/dev/null \
# | xargs wmctrl -i -a

wmctrl -l \
| awk '{if ($2 != -1) {printf "[" $2+1 "] " $4; {for(i=5;i<=NF;i++) printf " " $i;}; printf " (" $1 ")\n"}}' \
| dmenu -i -l 20  \
| sed -n 's/.*[\(]\([^\(]*\)[\)]$/\1/p' \
| xargs wmctrl -i -a
