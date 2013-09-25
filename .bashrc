# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Change the terminal to 256 colors
if [ -n "$COLORTERM" ]; then
  export TERM=xterm-256color
fi

#if ["$TERM" = "xterm" ]; then
#  export TERM=xterm-256color
#fi

#if [ "$TERM" = "vt220" ]; then
#    export TERM=vt220
#    elif [ -n "$TMUX" ]; then
#        export TERM=screen-256color
#fi

#for tmux: export 256color
[ -n "$TMUX" ] && export TERM=screen-256color-bce && color_prompt=yes

#export TERM="xterm-color"

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm*) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
export PATH="~/android/sdk/tools:${PATH}"
export PATH="~/android/sdk/platform-tools:${PATH}"
export PATH="${PATH}:."

# Config for Go

#This line will tell the Go installer where to place the source code before compilation
export GOROOT=$HOME/go
 
#With this line, you choose the architecture of your machine.  
#Those with 64 bit CPUs should enter "amd64" here.  
export GOARCH=amd64
 
#Your operating system
export GOOS=linux
 
#And now the location where the installer will place the finished files
#Don't forget to create this directory before installing
export GOBIN=$HOME/go/bin
 
#Include Go binaries in command path
export PATH=$PATH:$GOBIN

# Sets the News Server Environment as required by slrn
NNTPSERVER='news.eternal-september.org' && export NNTPSERVER

# My custom aliases
alias ttytter='$HOME/bin/ttytter -vcheck -ssl'
alias sl='ls'
alias ruby='ruby1.9.3'
alias irb='irb1.9.3'
alias python='python3'
alias slrn-grc='slrn -h news.grc.com -f .jnewsrc-grc -i .slrnrc-grc'
alias slrn-old='slrn -h nntp.olduse.net -f .jnewsrc-olduse -i .slrnrc-olduse'
alias bboard='ssh -t anthonyg@sverige bboard'
alias com='ssh -t anthonyg@sverige com'
