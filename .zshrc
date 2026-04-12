# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ~/.zshrc — Main zsh config, shared across all machines.
# OS-specific config is delegated to ~/.zshrc.{macos,fedora,linux,etc.}
# Local (unsynced) config lives in ~/.zshrc.local

# --- oh-my-zsh setup (must come before source oh-my-zsh.sh) ---
export ZSH=~/.oh-my-zsh

ZSH_THEME="powerlevel10k/powerlevel10k"

ZSH_DISABLE_COMPFIX="true"

# Plugins: macos plugin excluded (macOS-only; can't be added post-source)
plugins=(git tmux colored-man-pages mosh sudo docker docker-compose extract z nmap command-not-found zsh-autosuggestions zsh-syntax-highlighting)

ZSH_TMUX_DEFAULT_SESSION_NAME=main

DISABLE_UPDATE_PROMPT='true'

# Locale and PATH must be set before sourcing oh-my-zsh
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/sbin:$PATH"

# Homebrew must be in PATH before oh-my-zsh loads so the tmux plugin can find tmux
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

source $ZSH/oh-my-zsh.sh

# --- powerlevel10k ---
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- tmux ---
# Nesting guard: prevents launching tmux inside an existing tmux session
unalias tmux 2>/dev/null
tmux() {
  if [[ -n "$TMUX" ]]; then
    echo "Already inside a tmux session"
    return 1
  fi
  _zsh_tmux_plugin_run "$@"
}

# --- Environment ---
export TZ=US/Pacific

export NVIM_NERD_FONT=1

# --- OS-specific config ---
case "$(uname -s)" in
  Darwin)
    [[ -f ~/.zshrc.macos ]] && source ~/.zshrc.macos
    ;;
  Linux)
    if [[ -f /etc/fedora-release ]]; then
      [[ -f ~/.zshrc.fedora ]] && source ~/.zshrc.fedora
    else
      [[ -f ~/.zshrc.linux ]] && source ~/.zshrc.linux
    fi
    ;;
  FreeBSD)
    [[ -f ~/.zshrc.freebsd ]] && source ~/.zshrc.freebsd
    ;;
  OpenBSD)
    [[ -f ~/.zshrc.openbsd ]] && source ~/.zshrc.openbsd
    ;;
  NetBSD)
    [[ -f ~/.zshrc.netbsd ]] && source ~/.zshrc.netbsd
    ;;
esac

# --- Additional sources ---
source ~/.aliases         # shared aliases
[[ -f ~/.claude/env ]] && source ~/.claude/env      # Claude Code environment
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local     # machine-local env (not synced)
