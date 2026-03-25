# Initialize Homebrew early so plugins can find brew-installed tools (e.g. tmux)
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

ZSH_THEME="cypher"

ZSH_DISABLE_COMPFIX="true"

plugins=(git tmux colored-man-pages mosh npm node macos)

source $ZSH/oh-my-zsh.sh

# Enable utf-8 for tmux support
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

DISABLE_UPDATE_PROMPT='true'

export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/sbin:$PATH"

# Color for term
export CLICOLOR="Yes"

# Add newsserver
NNTPSERVER="news.eternal-september.org"
export NNTPSERVER

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
esac

# load the alias file
source ~/.aliases

