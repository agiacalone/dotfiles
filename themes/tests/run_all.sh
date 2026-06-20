#!/usr/bin/env bash
# Run the full theme-switcher test suite + an end-to-end switch-all smoke.
set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
B="$DIR/../../bin/theme"
fail=0
for t in validate_palettes test_palette test_osc test_gen test_theme_cli test_nvim test_zsh test_install; do
  if out="$(bash "$DIR/$t.sh" 2>&1)"; then
    printf '✓ %-18s %s\n' "$t" "$(echo "$out" | tail -1)"
  else
    printf '✗ %-18s FAIL\n%s\n' "$t" "$out"; fail=1
  fi
done
# e2e: every theme switches cleanly with no emulator side effects
st="$(mktemp)"; e2e=ok
for n in $("$B" list --names); do
  THEME_STATE="$st" "$B" --no-emulator --quiet "$n" || { e2e=fail; break; }
done
rm -f "$st"
if [ "$e2e" = ok ]; then printf '✓ %-18s OK\n' "e2e-switch-all"; else printf '✗ %-18s FAIL\n' "e2e-switch-all"; fail=1; fi
echo "------------------------------------"
[ $fail -eq 0 ] && echo "ALL GREEN" || echo "SOME FAILED"
exit $fail
