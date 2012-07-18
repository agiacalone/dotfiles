# .zshrc: ZSH config file

###################################################################
#                           Tautologies                           #
###################################################################

# Aliases
alias dir='dir --color'  # Colors are pretty...
alias g++='g++ -g -Wall -W -Wcast-qual -Wcast-align -Wsign-compare -Wredundant-decls -Wfloat-equal  -Wmissing-format-attribute -Wshadow -static '
alias lock='clear && lock -p -t 120'  # Nice to lock the screen when I'm away
alias pd=pushd
alias bd=popd
alias kterm='pkill -9 -t'
alias pterm='pkill -STOP -t'
alias cterm='pkill -CONT -t'
#alias sl='ls'  # I get lazy and type fast sometimes. Hate the train!!
alias sl='echo "Type ls, not sl! Do you really want the train back??"'
alias -g PG='|grep '
alias xclock='xclock -d -chime -update 1 &'
alias slrn='slrn -n'
alias ttytter='ttytter -vcheck' # CLI Twitter client
alias sendtweet='ttytter -status=' # Send tweets without running the prog
alias pine='alpine'  # Because old habits die hard.
alias udate='date -u'  # Nice, fast way to see GMT
alias unixdate='date +%s'  # Love UNIX time!!!
alias xcalc='xcalc -rpn &' # If I need a calculator, RPN is the way to go
alias ls='ls -C'
alias tt++='tt++ ~/.ttrc'  # TinTin++ - Mud client
alias slrn-grc='slrn -h news.grc.com -f .jnewsrc-grc -i .slrnrc-grc'
alias slrn-old='slrn -h nntp.olduse.net -f .jnewsrc-olduse -i .slrnrc-olduse'
alias slrn-es='slrn -h news.eternal-september.org -f .jnewsrc-es -i .slrnrc-es'

# Exports
#export ARGV0="Hey, no peeking!"
export EDITOR=/usr/pkg/bin/vim  # VIM is the preferred editor. Or ed. ;)
export PAGER=/usr/bin/less  # Less is more. Remember that!
export TZ=US/Pacific  # Timezone setting
export PATH=/usr/pkg/libexec/git-core/:${PATH}  # git path setting
export PATH=${PATH}:$HOME/bin:.

if [[ $TERM == 'xterm-256color' ]]; then
    export TERM="xterm-color"
fi

# Some sufixes
alias -s net=links
alias -s org=links
alias -s edu=links
alias -s com=links

# Set Backspace
#stty erase '^H' echoe  # Only for stupid, MS Windows programs
stty erase '^?' echoe   # Most used - preferred setting

# Enable history
HISTFILE=~/.zsh_hist
HISTSIZE=1000
SAVEHIST=1000

# Script to determine architecture of current machine
#case `uname -m`
# alpha) export PATH=$PATH:$HOME/alpha_bin ;;
# amd64) export PATH=$PATH:$HOME/amd64_bin ;;
#esac

# Set key bindings to vi (The way, the truth, and the light)
bindkey -v 

###################################################################
#                      Added for GNU screen                       #
###################################################################
if [[ $TERM == "screen" ]]; then
	# Set extension (current job; trunc to cut out path)
	TAB_TITLE_EXEC='$cmd[1]:t'

	# Set the prompt (EOPath)
	TAB_HARDSTATUS_PROMPT='$SHELL:t'
	# Set extension (current job + args; trunc to cut out path)
	TAB_HARDSTATUS_EXEC='$cmd'

# Send info to GNU screen:
function screen_set() {
	# Set the %t title
	print -nR $'\033k'$1$'\033'\\\
	# Set the hardstatus %h of each tab
	print -nR $'\033]0;'$2$'\a'
}

function preexec() {
	local -a cmd; cmd=(${(z)1}) #cmd string
	eval "tab_title=$TAB_TITLE_EXEC" 
	eval "tab_hardstatus=$TAB_HARDSTATUS_PROMPT\:$TAB_HARDSTATUS_EXEC"
	screen_set $tab_title $tab_hardstatus
}

function precmd() {
	# Enable next line for time on right side
	#export RPS1="[$(print '%{\e[1;31m%}')%T %?$(print '%{\e[0m%}')]"
	eval "tab_title=$TAB_TITLE_EXEC" 
	eval "tab_hardstatus=$TAB_HARDSTATUS_PROMPT$TAB_HARDSTATUS_EXEC"
	screen_set $tab_title $tab_hardstatus
}
	

###################################################################
#                        Added for xterm                          #
###################################################################

elif [[ $TERM == "xterm-color" ]]; then
    TAB_TITLE_EXEC='$cmd[1]:t'
	# Right prompt($RPS1)
	function precmd {
		# Enable next line for time on right side prompt
		#export RPS1="[$(print '%{\e[1;31m%}')%T %?$(print '%{\e[0m%}')]"
	}

	# Left prompt($PS1)
 	export PS1="$(print '%{\e[1;32m%}')%m@%c$(print '%{\e[0m%}')%# "

# Humor for the startup shell
echo ""
/usr/pkg/games/fortune
echo ""

# Check to see if there are any urgent messages
/usr/pkg/bin/notes -c
echo ""
fi

# end .zshrc
