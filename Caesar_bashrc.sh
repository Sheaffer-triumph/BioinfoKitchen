# .bashrc
# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

#Predefined environment
export PS1="\[\e[33;1m\]\u@\h \[\e[35;1m\]\d \t \[\e[36;1m\]\w\[\e[0m\]\n\[\e[32;1m\]$ \[\e[0m\]"
export TERMINFO=/usr/share/terminfo
export PATH="/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/meme/bin:$PATH"
export PATH="/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/hamburger/bin/:$PATH"
export PATH="/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/amita/bin/:$PATH"
#export THEANO_FLAGS='base_compiledir=/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/'

#Predefined shortcut commands
alias ll='ls -lthr'
alias compute='ssh cngb-xcompute-0-10'
alias software='ssh cngb-software-0-1'
alias lzr1='cd /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1'
alias lzr2='cd /hwfssz5/ST_HEALTH/P17Z10200N0246/USER/lizhuoran1'
alias bashinit='source ~/.bashrc'
alias where='realpath'
alias jobs='jobs -l'
alias htop-u='/usr/bin/htop -u lizhuoran1'
alias htop='/usr/bin/htop'
#alias qsub-h='cat /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/.store/qsub.txt'
alias quota='lfs quota -gh st_p17z10200n0246 /ldfssz1/'
alias mambainit='source ~/.mamba_init.sh'
alias activate='mamba activate'
alias deactivate='mamba deactivate'
alias rm=trash
alias rm!='/usr/bin/rm -rf'
alias clt=cleantrash
alias rc=trashrecycle
alias rl='ll -a /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/.Trash'

#Predefined Functions
function trash()
{
	for file in "$@"; do
	path=`realpath $file`
	i=`echo $path | sed 's/\//~/g' | sed 's/~ldfssz1~ST_HEALTH~P17Z10200N0246~lizhuoran1//g'`
	date=`echo $(date +%F-%R)`
	mv -f $file /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/.Trash/${date}$i
	done
}
function cleantrash()
{
	read -p "Confirm if you want to empty the Trash (y or n):" confirm
	[ $confirm == 'y' ] && /usr/bin/rm -rf /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/.Trash/*
}
function trashrecycle()
{
	for file in "$@"; do
	mv -i /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/.Trash/$@ ./
	i=`echo $file | awk -F '~' '{print $NF}'`
	mv $file $i
	done
}
function his()
{
	history > /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/.store/.history
	cat /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/.store/.history | grep "$@"
	/usr/bin/rm /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/.store/.history
}
function qg()
{
	qstat | grep $1
}
function qcd()
{
	a=`qstat -j $1 | grep cwd | awk '{print $2}'`
	cd $a
}
function qs()
{
	qsub -cwd -q st.q -P P17Z10200N0246 -l vf=${1}g,num_proc=$2 -binding linear:$3 $4
}
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
#__conda_setup="$('/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
#if [ $? -eq 0 ]; then
#    eval "$__conda_setup"
#else
#    if [ -f "/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/etc/profile.d/conda.sh" ]; then
#        . "/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/etc/profile.d/conda.sh"
#    else
#        export PATH="/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/bin:$PATH"
#    fi
#fi
#unset __conda_setup

#if [ -f "/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/etc/profile.d/mamba.sh" ]; then
#    . "/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/etc/profile.d/mamba.sh"
#fi
# <<< conda initialize <<<
