# Source me. Defines palette_load / palette_path. Caller declares: declare -A PAL
# Resolves the themes/ root relative to this file so it works whether deployed to
# ~/themes (cp install) or run from ~/git/dotfiles/themes (dev).
THEME_ROOT="${THEME_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." 2>/dev/null && pwd)}"

palette_path() { printf '%s/%s.theme\n' "$THEME_ROOT" "$1"; }

# palette_load <file>  -> populates global assoc array PAL. Returns 1 on failure.
palette_load() {
  local f="$1" k v
  [ -r "$f" ] || return 1
  while IFS='=' read -r k v; do
    case "$k" in ''|\#*) continue;; esac
    PAL["$k"]="$v"
  done < "$f"
  [ -n "${PAL[color0]:-}" ] || return 1
}

# palette_list -> theme names (basenames), one per line, sorted.
palette_list() {
  local f n
  for f in "$THEME_ROOT"/*.theme; do
    [ -e "$f" ] || return 0
    n="$(basename "$f" .theme)"; printf '%s\n' "$n"
  done | sort
}
