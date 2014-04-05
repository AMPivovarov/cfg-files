unpack () {
    if hash atool 2>/dev/null ; then
        aunpack "$@"
    else
        if [[ -f "$1" ]] ; then
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
    fi
}

pack () {
    if hash atool 2>/dev/null; then
        if [[ -z "$1" || "$#" -eq 1 ]]; then 
            echo " ${0##*/} <type> [files] - pack common archive formats"
            return 
        fi
    
        case $1 in
                tbz)    ext='tar.bz2'      ;;
                tgz)    ext='tar.gz'       ;;
                *)      ext="$1"           ;;
        esac
    
        if [[ "$#" -eq 2 ]]; then 
            apack "$2.$ext" "$2"
        else
            apack "pack.$ext" "${@:2}" 
        fi
    else
        if [[ ! -z "$1" ]] ; then
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
            echo "'$1' is not a valid file type"
        fi
    fi
}