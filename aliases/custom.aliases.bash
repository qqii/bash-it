alias debug="set -o nounset; set -o xtrace"
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|cut -c 40-)"'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias h='history'
alias j='jobs -l'
# alias which='type -a'
alias ..='cd ..'
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'
alias du='du -kh'
alias df='df -kTh'
alias ls='ls -h --color=auto'
alias lx='ls -lXB'
alias lk='ls -lSr'
alias lt='ls -ltr'
alias lc='ls -ltcr'
alias lu='ls -ltur'
alias ll="ls -lv --group-directories-first"
alias lm='ll |more'
alias lr='ll -R'
alias la='ll -A'
alias tree='tree -Csuh'
alias more='less'
function cdls() { 
	cd $1
	ls ${@:2}
}
#alias cd='cdls'
alias cwd='pwd'
alias sublime='subl'
alias term='pantheon-terminal'
alias terminal='pantheon-terminal'
alias files='nohup pantheon-files &'
alias calculator='pantheon-calculator &'
#alias chrome='google-chrome'
