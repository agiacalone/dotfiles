# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

ZSH_THEME="cypher"

ZSH_DISABLE_COMPFIX="true"

plugins=(git tmux colored-man-pages mosh)

ZSH_TMUX_DEFAULT_SESSION_NAME=main

DISABLE_UPDATE_PROMPT='true'

# Enable utf-8 for tmux support
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/sbin:$PATH"

source $ZSH/oh-my-zsh.sh

# Wrap tmux with a nesting guard
unalias tmux 2>/dev/null
tmux() {
  if [[ -n "$TMUX" ]]; then
    echo "Already inside a tmux session"
    return 1
  fi
  _zsh_tmux_plugin_run "$@"
}

# Add newsserver
export NNTPSERVER="news.eternal-september.org"

# Add local timezone
export TZ=US/Pacific

# Source OS-specific config automatically
case "$(uname -s)" in
  Darwin)
    [[ -f ~/.zshrc-macos ]] && source ~/.zshrc-macos
    ;;
  Linux)
    if [[ -f /etc/fedora-release ]]; then
      [[ -f ~/.zshrc-fedora ]] && source ~/.zshrc-fedora
    else
      [[ -f ~/.zshrc-linux ]] && source ~/.zshrc-linux
    fi
    ;;
  FreeBSD)
    [[ -f ~/.zshrc-freebsd ]] && source ~/.zshrc-freebsd
    ;;
  OpenBSD)
    [[ -f ~/.zshrc-openbsd ]] && source ~/.zshrc-openbsd
    ;;
  NetBSD)
    [[ -f ~/.zshrc-netbsd ]] && source ~/.zshrc-netbsd
    ;;
esac

# Nerd Font available on this machine
export NVIM_NERD_FONT=1

# load the alias file
source ~/.aliases

# load env for claude code
source ~/.claude/env

# load local env (not synced)
source ~/.zshrc-local
