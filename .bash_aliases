alias rc='cp /vagrant/.bash_aliases ~; source ~/.bash_aliases'
alias l='ls -ACF'
alias ls='ls -ACF'
alias ll='ls -lAF'
alias lt='ls -lAFt'
unalias grep 2> /dev/null
alias g=grep
alias c=cd
alias p=pushd
alias p2='pushd +2'
alias p3='pushd +3'
alias p4='pushd +4'
alias pp=popd
alias d='dirs | dirs.pl'
alias h='history | tail -20'
alias ghist='history | grep'
alias gh='history | grep'
alias j=jobs
alias m='less -e -M -X'

#alias kc='/vagrant/kubernetes-0.2/cluster/kubecfg.sh'
#alias kubecfg='/vagrant/kubernetes-0.2/cluster/kubecfg.sh'
#alias kc='/vagrant/kubernetes-0.2/kc.sh'
#alias kubecfg='/vagrant/kubernetes-0.2/kc.sh'
# now getting kc from ~/bin

# make completion work like Windows?
#set show-all-if-ambiguous on
bind TAB:menu-complete

# PS1='
# ${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
# 
# PS1='
# \e[0;33mvagrant:\W$\e[0m '

reset='\e[0m'
brown='\e[0;33m'
#PS1='\e[0;33m\w
#vagrant$ \e[0m '
#PS1="$brown\w
#vagrant\$$reset "

PROMPT_COMMAND='if [ ${#PWD} -gt 20 ]; then myPWD=…${PWD:${#PWD}-20}; else myPWD=$PWD; fi'
PS1="
$brown\$myPWD\$$reset "

TERM=cygwin
CDPATH=.:/vagrant/git:~/b

PATH=~/bin:$PATH
