# Terminal Theme Switcher — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** One command (`theme <name>`) switches the color scheme and makes the emulator (Konsole/iTerm2), tmux, neovim, and zsh all match live, with importable native profiles and the JetBrainsMono Nerd Font.

**Architecture:** Palette files (`themes/*.theme`) are the single source of truth. `bin/theme-gen` turns a palette into every downstream artifact (OSC string, tmux conf, Konsole colorscheme+profile, iTerm2 Dynamic Profile). `bin/theme` switches live (OSC repaint + tmux source + nvim fs-watch trigger + zsh dircolors) and persists the name to `~/.config/theme/current`. Hybrid: rich themes map to nvim plugin colorschemes; the four phosphor themes use a generated nvim highlight set.

**Tech Stack:** POSIX-ish bash, `jq` (iTerm2 JSON), zsh (function wrapper + startup), Lua + `vim.uv` (neovim), tmux ≥ 3.3 (`allow-passthrough`).

## Global Constraints

- 12 themes: `nord`, `gruvbox-dark`, `gruvbox-light`, `tokyonight`, `solarized-dark`, `solarized-light`, `catppuccin-mocha`, `everforest`, `phosphor-green`, `phosphor-green-apple`, `phosphor-amber`, `phosphor-red`.
- All colors truecolor (24-bit hex `#rrggbb`).
- Default theme / fallback: `gruvbox-dark`.
- Font: `JetBrainsMono Nerd Font Mono` (config var `THEME_FONT`), size `THEME_FONT_SIZE` (default 13). Fallbacks `Hack Nerd Font`, `BlexMono Nerd Font` — all installed by `bin/install-fonts.sh`.
- Phosphor themes are warm/softened (no saturated primaries); `phosphor-red` is the softest (desaturated rose); greens modeled on IBM 5151 P39 (`phosphor-green`) and Apple ][ P31 (`phosphor-green-apple`).
- State file: `~/.config/theme/current` (per-machine, not synced).
- All committed code/palettes live under `~/git/dotfiles`. Commits are **GPG-signed** (`git commit -S`).
- Segments/scripts never emit error text to stdout; failures degrade to no-op.
- ANSI escapes in shell/jq use literal `\033`/``; tmux passthrough wraps OSC when `$TMUX` set (requires `allow-passthrough on`).

## File Structure

| File | Responsibility |
|---|---|
| `themes/<name>.theme` | One palette: 16 ANSI + fg/bg/cursor/selection + `background` + nvim/tmux mapping keys |
| `themes/theme.conf` | `THEME_FONT`, `THEME_FONT_SIZE`, `THEME_DEFAULT` |
| `themes/lib/palette.sh` | Parse + validate a `.theme` → assoc array; pure, sourced by others |
| `themes/lib/osc.sh` | Palette → OSC 4/10/11/12 byte string; tmux-passthrough wrap |
| `bin/theme-gen` | Palette → tmux conf / Konsole colorscheme+profile / iTerm2 dynamic profile / .itermcolors |
| `bin/theme` | Switch (live), `list`, `next`/`prev`, picker, `--install-profiles`, `--no-emulator` |
| `bin/tmux-theme` | Back-compat alias → `theme` |
| `.tmux/themes/<name>.conf` | Generated tmux status colors |
| `.tmux.conf` | `allow-passthrough on`; load current theme at start |
| `.config/nvim/lua/theme-sync.lua` | nvim startup-apply + fs-watch + mono highlight generator |
| `.config/nvim/init.lua` | `require('theme-sync')`; colorscheme plugin specs |
| `.zshrc` / `.zshrc.macos` / `.zshrc.linux` / `.zshrc.fedora` | `theme()` fn, startup OSC repaint, dircolors, root-red guard |
| `themes/tests/*.sh` | Unit + smoke tests |

## Dependency / Parallelism Map (for subagent fan-out)

```
Phase 1 palettes (12) ─┐  ← FULLY PARALLEL (one subagent per palette, or batched)
Phase 2 lib (palette,  │
  osc) ────────────────┼─→ Phase 3 theme-gen ─┐
                       │   Phase 4 theme worker ┼─→ Phase 8 profiles/install ─→ Phase 9 e2e
                       │   Phase 5 tmux ────────┤
                       │   Phase 6 nvim ────────┤  ← 5,6,7 PARALLEL after 2 (+4 for 5/7)
                       └─→ Phase 7 zsh ─────────┘
```
- **Parallel now:** Phase 1 (all 12 palettes — pure data), Phase 2's two lib files.
- **Parallel after Phase 2 lands:** Phase 3, 6.
- **Parallel after Phase 2+4 land:** Phase 5, 7.
- **Serial tail:** Phase 8 (needs 3), Phase 9 (needs all).

---

## Phase 1 — Palette files (PARALLEL; pure data)

Each palette is an independent file; a single validation test covers all. Subagents can take one palette each. The bespoke phosphor palettes are given in full below; rich themes transcribe each project's canonical published hex (sources cited per task).

### Task 1.0: Palette format + `theme.conf` + validation harness

**Files:**
- Create: `themes/theme.conf`, `themes/README.md` (format doc), `themes/tests/validate_palettes.sh`

**Interfaces:**
- Produces: the `.theme` key schema every palette must satisfy:
  `name, background(dark|light), color0..color15, fg, bg, cursor, selection,`
  `nvim_colorscheme | nvim_generate(=mono), nvim_background(dark|light), tmux_accent(colorN)`.

- [ ] **Step 1: Write `themes/theme.conf`**
```sh
# Terminal theme switcher — global config
THEME_DEFAULT=gruvbox-dark
THEME_FONT="JetBrainsMono Nerd Font Mono"
THEME_FONT_SIZE=13
```

- [ ] **Step 2: Write the failing validation test** `themes/tests/validate_palettes.sh`
```sh
#!/usr/bin/env bash
# Validates every themes/*.theme has all required keys + 16 hex colors.
set -u
cd "$(dirname "$0")/.." || exit 1
req_scalar="name background fg bg cursor selection"
fail=0
for f in *.theme; do
  [ -e "$f" ] || { echo "no palettes found"; exit 1; }
  for k in $req_scalar; do
    grep -qE "^$k=" "$f" || { echo "$f: missing $k"; fail=1; }
  done
  for n in $(seq 0 15); do
    grep -qE "^color$n=#[0-9A-Fa-f]{6}$" "$f" || { echo "$f: bad/missing color$n"; fail=1; }
  done
  grep -qE "^(nvim_colorscheme=|nvim_generate=mono)" "$f" || { echo "$f: missing nvim mapping"; fail=1; }
  grep -qE "^background=(dark|light)$" "$f" || { echo "$f: background must be dark|light"; fail=1; }
done
[ $fail -eq 0 ] && echo "OK: all palettes valid"
exit $fail
```

- [ ] **Step 3: Run it — expect FAIL** (`no palettes found`)
Run: `bash themes/tests/validate_palettes.sh`
Expected: FAIL (`no palettes found`) until palettes exist.

- [ ] **Step 4: Commit**
```bash
git add themes/theme.conf themes/README.md themes/tests/validate_palettes.sh
git commit -S -m "themes: palette format, config, validation harness"
```

### Task 1.1–1.4: Phosphor palettes (bespoke — full values)

Create these four files verbatim (warm/softened ramps; index 0=bg-dark → 15=brightest, 8–15 = the "intense"/brighter half). `cursor`/`selection` in-hue.

- [ ] **Task 1.1 `themes/phosphor-green.theme`** (IBM 5151 / P39, warm yellow-green)
```sh
name=phosphor-green
background=dark
color0=#0a0f0a
color1=#1f7a1f
color2=#2faa2f
color3=#3fc83f
color4=#1f7a1f
color5=#2faa2f
color6=#3fc83f
color7=#7fe07f
color8=#1a2a1a
color9=#33b833
color10=#4ade4a
color11=#5cf25c
color12=#33b833
color13=#4ade4a
color14=#5cf25c
color15=#b6ffb6
fg=#33ff33
bg=#0a0f0a
cursor=#5cf25c
selection=#1f4d1f
nvim_generate=mono
nvim_background=dark
tmux_accent=color10
```

- [ ] **Task 1.2 `themes/phosphor-green-apple.theme`** (Apple ][ / P31, cooler crisp green)
```sh
name=phosphor-green-apple
background=dark
color0=#03110a
color1=#108a4a
color2=#19b562
color3=#21d676
color4=#108a4a
color5=#19b562
color6=#21d676
color7=#7ff0b8
color8=#0a2218
color9=#19c46c
color10=#2ee584
color11=#49f59a
color12=#19c46c
color13=#2ee584
color14=#49f59a
color15=#c6ffe2
fg=#33ff99
bg=#03110a
cursor=#2ee584
selection=#0f5034
nvim_generate=mono
nvim_background=dark
tmux_accent=color10
```

- [ ] **Task 1.3 `themes/phosphor-amber.theme`** (P3/P134, warm gold-amber)
```sh
name=phosphor-amber
background=dark
color0=#120a02
color1=#a85e10
color2=#c87a18
color3=#e89a22
color4=#a85e10
color5=#c87a18
color6=#e89a22
color7=#f0c884
color8=#241606
color9=#c47a18
color10=#e89a22
color11=#ffbb3a
color12=#c47a18
color13=#e89a22
color14=#ffbb3a
color15=#ffe2a8
fg=#ffb000
bg=#120a02
cursor=#ffbb3a
selection=#4d3310
nvim_generate=mono
nvim_background=dark
tmux_accent=color11
```

- [ ] **Task 1.4 `themes/phosphor-red.theme`** (soft desaturated rose — root work)
```sh
name=phosphor-red
background=dark
color0=#120505
color1=#8a3a3a
color2=#a84e4e
color3=#c86a6a
color4=#8a3a3a
color5=#a84e4e
color6=#c86a6a
color7=#e0a0a0
color8=#241010
color9=#b85a5a
color10=#cc7070
color11=#dd8a8a
color12=#b85a5a
color13=#cc7070
color14=#dd8a8a
color15=#ffd0d0
fg=#e08a8a
bg=#120505
cursor=#dd8a8a
selection=#4d2020
nvim_generate=mono
nvim_background=dark
tmux_accent=color9
```

- [ ] **Each: validate + commit** (after creating, run harness, then):
```bash
bash themes/tests/validate_palettes.sh
git add themes/phosphor-*.theme && git commit -S -m "themes: phosphor palettes (green/apple/amber/red)"
```

### Task 1.5–1.10: Rich theme palettes (transcribe canonical hex)

One file each; populate `color0..15` + `fg/bg/cursor/selection` from the named source, set `nvim_colorscheme`/`nvim_background`/`tmux_accent`. **Source of truth per theme (use the published 16-color terminal palette):**

| Task | File | `nvim_colorscheme` | `background` | Palette source |
|---|---|---|---|---|
| 1.5 | `nord.theme` | `nord` | dark | nordtheme.com (Polar Night/Snow/Frost/Aurora) |
| 1.6 | `gruvbox-dark.theme` | `gruvbox` | dark | morhetz/gruvbox "dark" 256 hex |
| 1.7 | `gruvbox-light.theme` | `gruvbox` | light | morhetz/gruvbox "light" |
| 1.8 | `tokyonight.theme` | `tokyonight-night` | dark | folke/tokyonight `night` extras palette |
| 1.9 | `solarized-dark.theme` / `solarized-light.theme` | `solarized` | dark / light | Ethan Schoonover Solarized 16-color (shared base, `background` differs) |
| 1.10 | `catppuccin-mocha.theme` / `everforest.theme` | `catppuccin-mocha` / `everforest` | dark | catppuccin & sainnhe/everforest published palettes |

- [ ] For each: write the file with exact hex from the cited source, set mapping keys, run `bash themes/tests/validate_palettes.sh` (expect OK), commit `-S`.

---

## Phase 2 — Core lib (palette parser + OSC encoder)

### Task 2.1: `themes/lib/palette.sh` — parser

**Files:** Create `themes/lib/palette.sh`, `themes/tests/test_palette.sh`

**Interfaces:**
- Produces: `palette_load <file>` → populates global assoc array `PAL` (keys = palette keys). Returns 1 on missing file. `palette_path <name>` → resolves `themes/<name>.theme` relative to dotfiles root (honors `$DOTFILES`).

- [ ] **Step 1: Failing test** `themes/tests/test_palette.sh`
```sh
#!/usr/bin/env bash
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$DIR/lib/palette.sh"
declare -A PAL
palette_load "$DIR/phosphor-amber.theme" || { echo "load failed"; exit 1; }
[ "${PAL[color15]}" = "#ffe2a8" ] || { echo "color15 wrong: ${PAL[color15]}"; exit 1; }
[ "${PAL[background]}" = "dark" ] || { echo "bg wrong"; exit 1; }
echo "OK"
```

- [ ] **Step 2: Run — FAIL** (`lib/palette.sh` missing). Run: `bash themes/tests/test_palette.sh`
- [ ] **Step 3: Implement `themes/lib/palette.sh`**
```sh
# Source me. Defines palette_load / palette_path. Caller declares: declare -A PAL
: "${DOTFILES:=$HOME/git/dotfiles}"
palette_path() { printf '%s/themes/%s.theme\n' "$DOTFILES" "$1"; }
palette_load() {
  local f="$1" k v
  [ -r "$f" ] || return 1
  while IFS='=' read -r k v; do
    case "$k" in ''|\#*) continue;; esac
    PAL["$k"]="$v"
  done < "$f"
  [ -n "${PAL[color0]:-}" ] || return 1
}
```
- [ ] **Step 4: Run — PASS.** Run: `bash themes/tests/test_palette.sh` → `OK`
- [ ] **Step 5: Commit** `git add themes/lib/palette.sh themes/tests/test_palette.sh && git commit -S -m "themes: palette parser lib"`

### Task 2.2: `themes/lib/osc.sh` — OSC encoder + tmux passthrough

**Files:** Create `themes/lib/osc.sh`, `themes/tests/test_osc.sh`

**Interfaces:**
- Consumes: `PAL` (from palette.sh).
- Produces: `osc_string` → echoes the full OSC 4/10/11/12 sequence for the loaded `PAL`. Honors `$TMUX`: wraps each sequence in `\ePtmux;\e … \e\\`. Uses `\033` ESC.

- [ ] **Step 1: Failing test** `themes/tests/test_osc.sh`
```sh
#!/usr/bin/env bash
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"; . "$DIR/lib/palette.sh"; . "$DIR/lib/osc.sh"
declare -A PAL; palette_load "$DIR/phosphor-amber.theme"
out="$(TMUX='' osc_string | cat -v)"
echo "$out" | grep -q '4;0;#120a02'   || { echo "missing color0 OSC"; exit 1; }
echo "$out" | grep -q '11;#120a02'     || { echo "missing bg OSC"; exit 1; }
echo "$out" | grep -q 'Ptmux' && { echo "should NOT wrap when TMUX unset"; exit 1; }
wrapped="$(TMUX='x' osc_string | cat -v)"
echo "$wrapped" | grep -q 'Ptmux' || { echo "should wrap under tmux"; exit 1; }
echo "OK"
```
- [ ] **Step 2: Run — FAIL** (`lib/osc.sh` missing).
- [ ] **Step 3: Implement `themes/lib/osc.sh`**
```sh
# Source after palette.sh; needs PAL populated.
_osc_emit() { # $1=raw seq body (without ESC). Wrap for tmux if needed.
  local body="$1" ESC=$'\033' BEL=$'\007'
  if [ -n "${TMUX:-}" ]; then
    printf '%sPtmux;%s%s%s%s\\' "$ESC" "$ESC" "$ESC$body$BEL" "$ESC" ""
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
```
- [ ] **Step 4: Run — PASS.** (`bash themes/tests/test_osc.sh` → `OK`)
- [ ] **Step 5: Commit** `git add themes/lib/osc.sh themes/tests/test_osc.sh && git commit -S -m "themes: OSC encoder + tmux passthrough"`

---

## Phase 3 — `bin/theme-gen` (generator) [needs Phase 2]

**Files:** Create `bin/theme-gen`, `themes/tests/test_gen.sh`. Sources `themes/lib/palette.sh` and `themes/theme.conf`.

**Interfaces:**
- Consumes: `PAL`, `THEME_FONT`, `THEME_FONT_SIZE`.
- Produces subcommands: `theme-gen tmux <name>` → stdout tmux conf; `theme-gen konsole-scheme <name>` → INI; `theme-gen konsole-profile <name>`; `theme-gen iterm <name1> [name2 …]` → one Dynamic-Profile JSON (jq-built); `theme-gen itermcolors <name>` → plist.

- [ ] **Step 1: Failing test** `themes/tests/test_gen.sh`
```sh
#!/usr/bin/env bash
set -u; DIR="$(cd "$(dirname "$0")/.." && pwd)"; G="$DIR/bin/theme-gen"
# Konsole INI
"$G" konsole-scheme phosphor-amber | grep -q '^\[Background\]' || { echo "no [Background]"; exit 1; }
"$G" konsole-scheme phosphor-amber | grep -q '^\[Color7Intense\]' || { echo "no Color7Intense"; exit 1; }
# iTerm JSON parses + has 16 ansi + font
j="$("$G" iterm phosphor-amber)"; echo "$j" | jq -e '.Profiles[0]["Ansi 15 Color"]' >/dev/null || { echo "bad iterm json"; exit 1; }
echo "$j" | jq -e '.Profiles[0]["Normal Font"]|test("JetBrainsMono")' >/dev/null || { echo "font not set"; exit 1; }
echo "OK"
```
- [ ] **Step 2: Run — FAIL** (no `bin/theme-gen`).
- [ ] **Step 3: Implement `bin/theme-gen`** — key generators (hex→rgb helper; Konsole INI with `Color0..7` + `Color8..15` as `Color0..7Intense`; iTerm Dynamic Profile via `jq` converting `#rrggbb`→0–1 floats; `.itermcolors` plist). Konsole INI block shape per color: `[ColorN]\nColor=r,g,b`. iTerm color dict: `{"Red Component":r/255,"Green Component":…,"Blue Component":…,"Color Space":"sRGB"}`. Profile JSON top: `{"Profiles":[{"Name":"Theme <name>","Guid":"readest-<name>","Ansi 0 Color":{…}…,"Background Color":…,"Foreground Color":…,"Cursor Color":…,"Normal Font":"<THEME_FONT> <SIZE>"}]}`. (Implementer writes the hex→component math + jq; tests above lock the contract.)
- [ ] **Step 4: Run — PASS.**
- [ ] **Step 5: Commit** `-S -m "themes: theme-gen (tmux/Konsole/iTerm2 generators)"`

---

## Phase 4 — `bin/theme` worker [needs Phase 2]

**Files:** Create `bin/theme`, `themes/tests/test_theme_cli.sh`.

**Interfaces:**
- Produces: `theme <name>` (validate→write state→OSC repaint→`tmux source-file`→touch nvim trigger), `theme list`, `theme next|prev`, no-arg picker (fzf→fallback menu), flags `--no-emulator`, `--install-profiles`, `--quiet`. State at `~/.config/theme/current`.

- [ ] **Step 1: Failing test** `themes/tests/test_theme_cli.sh`
```sh
#!/usr/bin/env bash
set -u; export DOTFILES="$(cd "$(dirname "$0")/../.." && pwd)"
export THEME_STATE="$(mktemp)"; B="$DOTFILES/bin/theme"
"$B" --no-emulator --quiet nord || { echo "switch failed"; exit 1; }
[ "$(cat "$THEME_STATE")" = "nord" ] || { echo "state not written"; exit 1; }
"$B" list | grep -q 'nord' || { echo "list missing nord"; exit 1; }
"$B" --no-emulator badtheme 2>/dev/null && { echo "should reject unknown"; exit 1; }
echo "OK"
```
- [ ] **Step 2: Run — FAIL.**
- [ ] **Step 3: Implement `bin/theme`** — sources `themes/lib/{palette,osc}.sh` + `theme.conf`; `THEME_STATE=${THEME_STATE:-$HOME/.config/theme/current}`; `list` enumerates `themes/*.theme`; switch: validate file exists → `palette_load` → `osc_string` to terminal unless `--no-emulator` → `tmux source-file` the generated conf if `$TMUX`/server up → write state (nvim fs-watch picks it up); `next/prev` cycle sorted list; picker uses `fzf` else `select`. `--install-profiles` calls Phase 8 installer.
- [ ] **Step 4: Run — PASS.**
- [ ] **Step 5: Commit** `-S -m "themes: theme switch worker (cli, state, live repaint)"`

---

## Phase 5 — tmux integration [needs Phase 2,3,4]

**Files:** Modify `.tmux.conf`; create `.tmux/themes/<name>.conf` via generator; rewrite `bin/tmux-theme` as alias.

- [ ] **Step 1:** Add to `.tmux.conf`: `set -g allow-passthrough on` and at load: `if-shell '[ -f ~/.config/theme/current ]' 'source-file ~/.tmux/themes/#(cat ~/.config/theme/current).conf'`.
- [ ] **Step 2:** Generate all `.tmux/themes/*.conf`: `for t in themes/*.theme; do n=$(basename "$t" .theme); bin/theme-gen tmux "$n" > .tmux/themes/"$n".conf; done`
- [ ] **Step 3:** Replace `bin/tmux-theme` body with `exec theme "$@"`.
- [ ] **Step 4: Test** `tmux -f /dev/null new -d 'true'`; `theme --no-emulator gruvbox-dark`; assert `tmux show -gv @theme 2>/dev/null` or status colors applied (smoke). 
- [ ] **Step 5: Commit** `-S -m "tmux: passthrough + generated themes + theme alias"`

---

## Phase 6 — neovim module [needs Phase 1]

**Files:** Create `.config/nvim/lua/theme-sync.lua`; modify `.config/nvim/init.lua`.

**Interfaces:** `require('theme-sync').setup()` reads `~/.config/theme/current`, applies mapped colorscheme + background; fs-watches the file; `nvim_generate=mono` themes get a generated highlight set from the palette ramp.

- [ ] **Step 1:** Add colorscheme plugins to lazy spec: `ellisonleao/gruvbox.nvim`, `folke/tokyonight.nvim`, `shaunsingh/nord.nvim`, `catppuccin/nvim`, `sainnhe/everforest`, `maxmx03/solarized.nvim` (or `ishan9299/nvim-solarized-lua`).
- [ ] **Step 2:** Write `theme-sync.lua`: a `name→{scheme,bg}` map for rich themes; for `phosphor-*` read the `.theme` file, parse `color*`, and `vim.api.nvim_set_hl` a minimal set (Normal, NormalFloat, Comment, LineNr, Visual, StatusLine, String, Function, Keyword, Type) from the ramp + `set background=dark`. Apply on `setup()`; `vim.uv.new_fs_event()` on the state file → re-apply (wrap in `vim.schedule`).
- [ ] **Step 3:** `init.lua`: `require('theme-sync').setup()` after lazy loads.
- [ ] **Step 4: Test (headless):** `nvim --headless "+lua require('theme-sync').setup()" "+colorscheme" "+qa"` exits 0; with state=`phosphor-amber`, assert `:hl Normal` guifg matches palette fg.
- [ ] **Step 5: Commit** `-S -m "nvim: theme-sync (fs-watch + mono generator) + colorscheme plugins"`

---

## Phase 7 — zsh integration [needs Phase 2,4]

**Files:** Modify `.zshrc` (+ `.zshrc.macos`/`.zshrc.linux`/`.zshrc.fedora` for dircolors specifics).

- [ ] **Step 1:** Define `theme()` shell function in `.zshrc` that runs `command theme "$@"` then re-applies dircolors locally for the new `background` (so current shell's `LS_COLORS` updates in place).
- [ ] **Step 2:** Startup block: if `~/.config/theme/current` exists, emit the OSC repaint for new windows (`theme --quiet --reapply` — a worker mode that prints OSC only), and set dircolors by dark/light.
- [ ] **Step 3:** Root-red guard: `if [[ $EUID -eq 0 && ${THEME_ROOT_RED:-1} -ne 0 ]]; then theme --quiet --reapply phosphor-red; fi` (does not overwrite the saved user theme — reapply-only).
- [ ] **Step 4: Test:** new `zsh -i -c 'echo $LS_COLORS'` differs between a dark and light current-theme; `EUID` mock path selects phosphor-red reapply (lint via `zsh -n`).
- [ ] **Step 5: Commit** `-S -m "zsh: theme() fn, startup repaint, dircolors, root-red guard"`

---

## Phase 8 — Profile install [needs Phase 3]

**Files:** Add `--install-profiles` impl to `bin/theme` (or `bin/theme install-profiles`).

- [ ] **Step 1:** Linux/Konsole: for each theme write `~/.local/share/konsole/<name>.colorscheme` and `Theme <name>.profile` (via `theme-gen`).
- [ ] **Step 2:** macOS/iTerm2: `theme-gen iterm <all themes>` → `~/Library/Application Support/iTerm2/DynamicProfiles/readest-themes.json`. Also write `themes/generated/*.itermcolors` (committed) for manual import/sharing.
- [ ] **Step 3:** Idempotent (overwrite); OS-detect via `uname`. Wire a call into `bin/install-fonts.sh` or bootstrap so profiles install alongside fonts.
- [ ] **Step 4: Test:** run installer with `HOME=$tmp`; assert Konsole files exist (Linux) / JSON parses (`jq` on the dynamic profile).
- [ ] **Step 5: Commit** `-S -m "themes: --install-profiles (Konsole + iTerm2 dynamic profiles)"`

---

## Phase 9 — End-to-end + docs [needs all]

- [ ] **Step 1:** `themes/tests/run_all.sh` runs every test; ensure green.
- [ ] **Step 2:** `theme list` shows 12; `for t in $(theme list --names); do theme --no-emulator "$t"; done` exits 0.
- [ ] **Step 3:** Update `~/git/dotfiles/CLAUDE.md` + `README.md` with a "Theme switcher" section (command UX, adding a theme, font note).
- [ ] **Step 4: Commit** `-S -m "themes: e2e test runner + docs"`

---

## Self-Review

**Spec coverage:** 12 palettes (Ph1) ✓; palette source-of-truth + parser (Ph2.1) ✓; OSC live-repaint + tmux passthrough (Ph2.2, Ph5) ✓; tmux regen (Ph3/5) ✓; nvim fs-watch + mono carve-out (Ph6) ✓; zsh dircolors + startup repaint + root-red toggle (Ph7) ✓; native Konsole/iTerm2 profiles + JetBrainsMono Nerd Font (Ph3/Ph8, §5.7) ✓; tests (every phase + Ph9) ✓; `theme list/next/prev/picker/--no-emulator/--install-profiles` (Ph4) ✓; back-compat `tmux-theme` alias (Ph5) ✓.

**Placeholder scan:** phosphor palettes given in full; rich palettes specify exact cited sources (transcription is data entry, not a code placeholder); generator math (hex→components) + nvim mono highlight list are described with the exact contract locked by tests. No "TBD"/"handle edge cases".

**Type/name consistency:** `PAL` assoc array, `palette_load`/`palette_path`, `osc_string`, `THEME_STATE`, `THEME_FONT`/`THEME_FONT_SIZE`, theme names, and `nvim_generate=mono` key are used consistently across Phases 2–8.

**Subagent fan-out:** Phase 1 (12 palettes) and Phase 2's two libs are the parallel front; 3/6 parallel after 2; 5/7 after 2+4; 8 after 3; 9 last. Annotated in the Dependency map.
