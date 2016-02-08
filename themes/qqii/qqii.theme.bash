SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=" ${bold_red}✗${normal}"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓${normal}"
SCM_GIT_CHAR="${bold_green}±${normal}"
SCM_SVN_CHAR="${cyan}⑆${normal}"
SCM_HG_CHAR="${bold_red}☿${normal}"

load() {
    top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9\.]*\).id.*/\1/" | awk '{print 100 - $1}'
}

getreturn_prompt() {
    RETURN_PROMPT="${bold_red}${background_white}\${?##0}${normal}"
}

gettime_prompt() {
    SYSLOAD="$(load)"
    TIME="$(date +%I:%M:%S)"
    TIME1="$(date +%p)"
    
    if [ $(echo "$SYSLOAD > 80" | bc) -eq 1 ]; then
        TIME_PROMPT=${bold_red}${background_white}
    elif [ $(echo "$SYSLOAD > 60" | bc) -eq 1 ]; then
        TIME_PROMPT=${bold_red}
    elif [ $(echo "$SYSLOAD > 40" | bc) -eq 1 ]; then
        TIME_PROMPT=${bold_orange}
    else
        TIME_PROMPT=${cyan}
    fi
    TIME_PROMPT+="$TIME $TIME1${normal}"
}

gethost_prompt() {
    if [[ ${USER} == "root" ]]; then
        HOST_PROMPT=${bold_red}${background_white}
    elif [[ ${USER} != $(logname) ]]; then
        HOST_PROMPT=${bold_red}
    else
        HOST_PROMPT=${cyan}
    fi
    HOST_PROMPT+="\u${normal}"

    if [ $(jobs -s | wc -l) -gt 0 ]; then
        HOST_PROMPT+=${bold_red}
    elif [ $(jobs -r | wc -l) -gt 0 ] ; then
        HOST_PROMPT+=${green}
    else
        HOST_PROMPT+=${cyan}
    fi
    HOST_PROMPT+="@${normal}"

    if [ -n "${SSH_CONNECTION}" ]; then
        HOST_PROMPT+=${green}
    elif [[ "${DISPLAY%%:0*}" != "" ]]; then
        HOST_PROMPT+=${bold_red}${background_white}
    else
        HOST_PROMPT+=${cyan}
    fi    
    HOST_PROMPT+="\h${normal}"
}

getpwd_prompt() {
    if [ ! -w "${PWD}" ] ; then
        PWD_PROMPT=${bold_red}
    elif [ -s "${PWD}" ] ; then
        local used=$(command df -P "$PWD" |
                   awk 'END {print $5} {sub(/%/,"")}')
        if [ ${used} -gt 95 ]; then
            PWD_PROMPT=${bold_red}${background_white}
        elif [ ${used} -gt 90 ]; then
            PWD_PROMPT=${bold_red}
        else
            PWD_PROMPT=${green}
        fi
    else
        PWD_PROMPT=${cyan}
    fi
    PWD_PROMPT+="\W${normal}"
}

getscm_prompt() {
    scm_prompt_vars

    SCM_PROMPT=""
    if [[ "${SCM_NONE_CHAR}" != "${SCM_CHAR}" ]]; then
        if [[ "${SCM_DIRTY}" -eq 1 ]]; then
            SCM_PROMPT+="${orange}"
        else
            SCM_PROMPT+="${green}"
        fi
        [[ "${SCM_GIT_CHAR}" == "${SCM_CHAR}" ]] && SCM_PROMPT+="${cyan}┌─[${normal}${SCM_CHAR}${SCM_BRANCH}${SCM_STATE}${SCM_GIT_BEHIND}${SCM_GIT_AHEAD}${SCM_GIT_STASH}${cyan}]${normal}"
        SCM_PROMPT="${SCM_PROMPT}${cyan}\n├─${normal}"
    else
        SCM_PROMPT="${cyan}┌─"
    fi
}

# ┌─ [ ]

# ├─ ─ ▪

# └─

prompt() {
    getreturn_prompt
    gettime_prompt
    gethost_prompt
    getpwd_prompt
    getscm_prompt
    
    PS1="${SCM_PROMPT}${cyan}"
    PS1+="[${TIME_PROMPT}${cyan}][${HOST_PROMPT}${cyan}][${PWD_PROMPT}${cyan}]"
    PS1+="\n${cyan}└─[${RETURN_PROMPT}${cyan}] ${normal}"

}

export PROMPT_COMMAND=prompt
