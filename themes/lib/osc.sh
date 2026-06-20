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

# osc_reset -> tell the emulator to drop all forced palette overrides and revert
# to its own profile/native colors. OSC 104 (no params) resets the whole ANSI
# palette; 110/111/112 reset default fg/bg/cursor. Needs no PAL.
osc_reset() {
  _osc_emit "]104"   # reset ANSI colors 0-15
  _osc_emit "]110"   # reset default foreground
  _osc_emit "]111"   # reset default background
  _osc_emit "]112"   # reset cursor color
}
