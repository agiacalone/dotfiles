# Source after palette.sh; needs PAL populated.
# osc_string -> emits OSC 4 (palette 0-15), 10 (fg), 11 (bg), 12 (cursor).
# When $TMUX is set, each sequence is wrapped in tmux passthrough so it reaches
# the real terminal (requires `set -g allow-passthrough on`).
_osc_emit() {  # $1 = OSC body after ESC, e.g. "]11;#1a1b26"
  local body="$1" ESC=$'\033' BEL=$'\007'
  if [ -n "${TMUX:-}" ]; then
    printf '%sPtmux;%s%s%s%s\\' "$ESC" "$ESC" "$ESC$body$BEL" "$ESC"
  else
    printf '%s%s' "$ESC$body" "$BEL"
  fi
}

osc_string() {
  local i
  for i in $(seq 0 15); do _osc_emit "]4;$i;${PAL[color$i]}"; done
  _osc_emit "]10;${PAL[fg]}"
  _osc_emit "]11;${PAL[bg]}"
  _osc_emit "]12;${PAL[cursor]}"
}
