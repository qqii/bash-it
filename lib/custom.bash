TERM=xterm-256color

ulimit -S -c 0
set -o notify
set -o ignoreeof
shopt -s cdspell
shopt -s cdable_vars
shopt -s checkhash
shopt -s checkwinsize
shopt -s sourcepath
shopt -s no_empty_cmd_completion
shopt -s cmdhist
shopt -s histappend histreedit histverify
shopt -u mailwarn
unset MAILCHECK

export PAGER=less
export LESSCHARSET='utf-8'
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'
export TIMEFORMAT=$'real %3R\tuser %3U\tsys %3S\tpcpu %P'
export HISTTIMEFORMAT="$(echo -e ${BCyan})[%D %I:%M:%S %p]$(echo -e ${NC}) "
export HISTCONTROL=ignoreboth:erasedups
export PYTHONSTARTUP='/home/qqii/.pystart.py'

function ff() { find . -type f -iname '*'"$*"'*' -ls ; }
function fe() { find . -type f -iname '*'"${1:-}"'*' -exec ${2:-file} {} \;  ; }
function fstr() {
    OPTIND=1
    local mycase=""
    local usage="fstr: find string in files.
Usage: fstr [-i] \"pattern\" [\"filename pattern\"] "
    while getopts :it opt
    do
        case "$opt" in
           i) mycase="-i " ;;
           *) echo "$usage"; return ;;
        esac
    done
    shift $(( $OPTIND - 1 ))
    if [ "$#" -lt 1 ]; then
        echo "$usage"
        return;
    fi
    find . -type f -name "${2:-*}" -print0 | \
xargs -0 egrep --color=always -sn ${case} "$1" 2>&- | more
}
function swap() { # Swap 2 filenames around, if they exist.
    local TMPFILE=tmp.$$

    [ $# -ne 2 ] && echo "swap: 2 arguments needed" && return 1
    [ ! -e $1 ] && echo "swap: $1 does not exist" && return 1
    [ ! -e $2 ] && echo "swap: $2 does not exist" && return 1

    mv "$1" $TMPFILE
    mv "$2" "$1"
    mv $TMPFILE "$2"
}
function maketar() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }
function makezip() { zip -r "${1%%/}.zip" "$1" ; }
function sanitize() { chmod -R u=rwX,g=rX,o= "$@" ;}
function my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,bsdtime,command ; }
function pp() { my_ps f | awk '!/awk/ && $0~var' var=${1:-".*"} ; }
function killps() {
    local pid pname sig="-TERM"   # default signal
    if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
        echo "Usage: killps [-SIGNAL] pattern"
        return;
    fi
    if [ $# = 2 ]; then sig=$1 ; fi
    for pid in $(my_ps| awk '!/awk/ && $0~pat { print $1 }' pat=${!#} )
    do
        pname=$(my_ps | awk '$1~var { print $5 }' var=$pid )
        if ask "Kill process $pid <$pname> with signal $sig?"
            then kill $sig $pid
        fi
    done
}
function mydf() {       # Pretty-print of 'df' output.
    for fs ; do

        if [ ! -d $fs ]
        then
          echo -e $fs" :No such file or directory" ; continue
        fi

        local info=( $(command df -P $fs | awk 'END{ print $2,$3,$5 }') )
        local free=( $(command df -Pkh $fs | awk 'END{ print $4 }') )
        local nbstars=$(( 20 * ${info[1]} / ${info[0]} ))
        local out="["
        for ((j=0;j<20;j++)); do
            if [ ${j} -lt ${nbstars} ]; then
               out=$out"*"
            else
               out=$out"-"
            fi
        done
        out=${info[2]}" "$out"] ("$free" free on "$fs")"
        echo -e $out
    done
}
function my_ip() { # Get IP adress on ethernet.
    MY_IP=$(/sbin/ifconfig eth0 | awk '/inet/ { print $2 } ' | sed -e s/addr://)
    echo ${MY_IP:-"Not connected"}
}
function ii() {	# Get current host related info.
    echo -e "\nYou are logged on ${bold_red}$HOST"
    echo -e "\n${bold_red}Additionnal information:$normal " ; uname -a
    echo -e "\n${bold_red}Users logged on:$normal " ; w -hs |
             cut -d " " -f1 | sort | uniq
    echo -e "\n${bold_red}Current date :$normal " ; date
    echo -e "\n${bold_red}Machine stats :$normal " ; uptime
    echo -e "\n${bold_red}Memory stats :$normal " ; free
    echo -e "\n${bold_red}Diskspace :$normal " ; mydf / $HOME
    echo -e "\n${bold_red}Local IP Address :$normal" ; my_ip
    echo -e "\n${bold_red}Open connections :$normal "; netstat -pan --inet;
    echo
}
function repeat() {      # Repeat n times command.
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do  # --> C-like syntax
        eval "$@";
    done
}
function ask() {         # See 'killps' for example of use.
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}
function corename() {  # Get name of app that created a corefile.
    for file ; do
        echo -n $file : ; gdb --core=$file --batch | head -1
    done
}
