# ~/.zshrc — Main zsh config, shared across all machines.
# OS-specific config is delegated to ~/.zshrc-{macos,fedora,linux,etc.}
# Local (unsynced) config lives in ~/.zshrc-local

# --- oh-my-zsh setup (must come before source oh-my-zsh.sh) ---
export ZSH=~/.oh-my-zsh

ZSH_THEME="cypher"

ZSH_DISABLE_COMPFIX="true"

# Plugins: macos plugin excluded (macOS-only; can't be added post-source)
plugins=(git tmux colored-man-pages mosh)

ZSH_TMUX_DEFAULT_SESSION_NAME=main

DISABLE_UPDATE_PROMPT='true'

# Locale and PATH must be set before sourcing oh-my-zsh
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/sbin:$PATH"

source $ZSH/oh-my-zsh.sh

# --- Prompt enhancements (extends cypher theme) ---
ZSH_THEME_GIT_PROMPT_PREFIX=" %{${fg[yellow]}%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="%{${fg[yellow]}%}]%{${reset_color}%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{${fg[red]}%}*"
ZSH_THEME_GIT_PROMPT_CLEAN=""

_venv_info() {
  [[ -n "$VIRTUAL_ENV" ]] && echo "%{${fg[cyan]}%}(${VIRTUAL_ENV:t})%{${reset_color}%} "
}

PROMPT='$(_venv_info)%m %{${fg_bold[red]}%}:: %{${fg[green]}%}%3~$(git_prompt_info)%(1j. %{${fg[cyan]}%}[%j]%{${reset_color}%}.)%(0?. . %{${fg[red]}%}%? )%{${fg[blue]}%}»%{${reset_color}%} '

zmodload zsh/datetime
_cmd_start=0
_cmd_delta=""

_cmd_timer_preexec() { _cmd_start=$EPOCHREALTIME }

_cmd_timer_precmd() {
  if (( _cmd_start > 0 )); then
    local delta=$(( EPOCHREALTIME - _cmd_start ))
    _cmd_start=0
    if (( delta >= 60 )); then
      local -i m=$(( int(delta) / 60 ))
      local -i s=$(( int(delta) % 60 ))
      _cmd_delta="${m}m${s}s  "
    elif (( delta >= 1 )); then
      _cmd_delta="$(printf '%.1f' $delta)s  "
    else
      _cmd_delta=""
    fi
  else
    _cmd_delta=""
  fi
}

preexec_functions=(${preexec_functions:#_cmd_timer_preexec} _cmd_timer_preexec)
precmd_functions=(${precmd_functions:#_cmd_timer_precmd} _cmd_timer_precmd)

RPROMPT='%F{white}${_cmd_delta}%*%f'

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

# --- Additional sources ---
source ~/.aliases         # shared aliases
source ~/.claude/env      # Claude Code environment
source ~/.zshrc-local     # machine-local env (not synced)
