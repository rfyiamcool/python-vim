

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi
__mikespook_ps1() {
    local none='\[\033[00m\]'
    local g='\[\033[0;32m\]'
    local c='\[\033[0;36m\]'
    local emy='\[\033[1;33m\]'
    local br='\[\033[1;41m\]'
    black=$'\[\e[1;30m\]'
    red=$'\[\e[1;31m\]'
    green=$'\[\e[1;32m\]'
    yellow=$'\[\e[1;33m\]'
    blue=$'\[\e[1;34m\]'
    magenta=$'\[\e[1;35m\]'
    cyan=$'\[\e[1;36m\]'
    white=$'\[\e[1;37m\]'
    normal=$'\[\e[m\]'




    local uc=$none
    local p='$'
    if [ $UID -eq "0" ] ; then
        uc=$CBR
        p='#'
    fi
    local u="${uc}${debian_chroot:+($debian_chroot)}\u${none}"
    local h="${c}\h${none}:${g}\w${none}"
    echo "${cyan}[$u@$h]\$(__git_ps1 '[$red%s${none}]')${uc}${p}${none}${cyan}"
}

#git-prompt.sh PS1
#source ~/.git-prompt.sh
#PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$'

export PS1=$(__mikespook_ps1)

. /usr/local/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh
