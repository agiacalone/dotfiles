# Coordinated Terminal Theme Switcher — Design Spec

**Date:** 2026-06-20
**Status:** Draft for review
**Repo:** `~/git/dotfiles` (synced macOS + Linux)

## 1. Goal

One command switches the terminal color scheme and makes everything match **live** — the
emulator itself (Konsole on Linux, iTerm2 on macOS), tmux, neovim, and zsh's `ls`/dircolors —
without restarting anything. Truecolor (24-bit) throughout. Themes and logic live in the
dotfiles repo so both machines stay in sync.

### Success criteria
- `theme <name>` repaints the **current** terminal window, all **running** tmux panes, and all
  **running** neovim instances within ~1s, no restart.
- New terminal windows open already wearing the current theme.
- Adding a theme = drop in one palette file; no code changes.
- Works identically on Konsole and iTerm2 over SSH.

## 2. Theme set (12)

| Group | Themes |
|---|---|
| **Preferred** | `nord` · `gruvbox-dark` · `tokyonight` · `solarized-dark` · `solarized-light` |
| **Extras** | `gruvbox-light` · `catppuccin-mocha` · `everforest` |
| **Phosphor (monochrome)** | `phosphor-green` (IBM) · `phosphor-green-apple` · `phosphor-amber` · `phosphor-red` |

- 10 dark, 2 light (`solarized-light`, `gruvbox-light`).
- `solarized-dark`/`solarized-light` share the Solarized palette family, differing by
  `background=` plus the base tone swaps.
- **Phosphor themes** are true monochrome: all 16 ANSI slots are shades of a single hue
  (dim → bright), so tmux, `ls`, and nvim syntax all render in-hue.
- **All phosphor ramps are warm/softened, not neon** — period-accurate to real CRT phosphors,
  which glowed warmer and less saturated than pure RGB primaries. Easier on the eyes for long
  sessions.
  - `phosphor-green`: near-black bg, **warm yellow-green** ramp modeled on the **IBM 5151
    Monochrome Display (MDA, P39 phosphor)** — the classic PC/XT monochrome green; soft, not
    `#00FF00`. (P39 was long-persistence — the afterglow is temporal, so only the hue carries
    into the palette.)
  - `phosphor-green-apple`: the **Apple ][** green — a cooler, crisper **P31** (short-
    persistence) green, distinct from the IBM's warmer/yellower P39. sRGB tuned from int10h's
    phosphor reference.
  - `phosphor-amber`: deep-brown/black bg, **warm gold-amber** ramp modeled on the period
    amber monitors (P3/P134 phosphor) common on XT/AT-era clones.
  - `phosphor-red`: **soft desaturated rose** ramp (warm dim phosphor, NOT `#FF0000`) — the
    softest of the three; comfortable for sustained root work while still reading "red = root".
    No exact CRT antecedent (red phosphor monitors were rare), so tuned by feel to sit in the
    same warm, low-saturation family as the green/amber.

## 3. Architecture — a "theme bus"

One palette file per theme is the **single source of truth**. The `theme` command reads it and
fans the change out to five consumers, all keyed off one tiny state file.

```
~/git/dotfiles/themes/<name>.theme        ← source of truth (synced via dotfiles)
        │
        ▼
   theme <name>     (bin/theme worker + zsh function wrapper)
        │
        ├─▶ emulator   OSC 4/10/11/12 escape codes → live repaint (Konsole + iTerm2)
        ├─▶ tmux       regenerate status conf from palette → tmux source-file (all panes)
        ├─▶ neovim     update state file → running nvim fs-watches → colorscheme + background
        ├─▶ zsh        re-eval dircolors/LS_COLORS (dark/light aware) in the current shell
        └─▶ state      ~/.config/theme/current   ← theme name persisted (per-machine)
```

**Hybrid model** (chosen): the palette file drives the emulator (via OSC) and tmux (generated);
neovim maps to a faithful **named plugin colorscheme** for the rich themes, and to a
**generated highlight set** for the three monochrome phosphor themes (see §6).

## 4. Theme file format

Plain `KEY=value`, parsed by pure shell. Example `themes/tokyonight.theme`:

```
name=tokyonight
background=dark
# 16 ANSI palette (truecolor hex)
color0=#15161e
color1=#f7768e
# … color2..color14 …
color15=#c0caf5
# special colors
fg=#c0caf5
bg=#1a1b26
cursor=#c0caf5
selection=#283457
# per-program mapping
nvim_colorscheme=tokyonight-night     # or: nvim_generate=mono (phosphor themes)
nvim_background=dark
tmux_accent=color4
```

- Rich themes set `nvim_colorscheme` (+ `nvim_background`).
- Phosphor themes set `nvim_generate=mono` instead, and the nvim module builds highlights from
  the 16-color ramp (§6).
- tmux status colors are generated from `bg`, `fg`, and `tmux_accent`.

## 5. Components

### 5.1 `bin/theme` (worker, POSIX-ish bash)
- `theme` (no arg) → fzf picker; numbered-menu fallback if no fzf.
- `theme <name>` → validate, write state, fan out.
- `theme list` → available themes + current (marked).
- `theme next` / `theme prev` → cycle (preserves old `tmux-theme` toggle muscle memory).
- Flags: `--no-emulator` (skip OSC for terminals that mangle it), `--quiet`.
- Graceful no-ops when tmux/nvim aren't running.

A thin **zsh function** `theme()` wraps the worker so it can also update the *current* shell's
`LS_COLORS`/dircolors in place (a subprocess can't mutate the parent shell). The function calls
`bin/theme` for emulator/tmux/nvim/state, then re-evals dircolors locally.

### 5.2 OSC emitter (`lib`, unit-testable)
- Emits `OSC 4;N;#rrggbb` for palette indices 0–15, `OSC 10` (fg), `OSC 11` (bg),
  `OSC 12` (cursor).
- **tmux passthrough:** when `$TMUX` is set, wrap each sequence in
  `\ePtmux;\e <seq> \e\\` so it reaches the real terminal. Requires
  `set -g allow-passthrough on` in `.tmux.conf`.
- Pure function: takes a parsed palette, returns the byte string. Tested against fixtures.

### 5.3 tmux integration
- `.tmux/themes/<name>.conf` regenerated from the palette (status bar bg/fg/accent).
- `theme` runs `tmux source-file <conf>` → updates every existing session/pane at once.
- `.tmux.conf`: add `set -g allow-passthrough on`; on tmux start, load current theme.
- `bin/tmux-theme` kept as a thin alias → `theme` (back-compat).

### 5.4 neovim module — `~/.config/nvim/lua/theme-sync.lua` (in dotfiles)
- On startup: read `~/.config/theme/current`, apply the mapped colorscheme + `background`.
- `vim.uv.fs_event`-watch the state file → re-apply on change, so **already-open** nvim
  instances switch instantly when `theme` runs.
- For `nvim_generate=mono` themes: build a minimal highlight set (Normal, Comment, statusline,
  syntax groups) from the palette ramp instead of loading a plugin.
- Add the rich colorscheme plugins to the lazy.nvim spec: gruvbox, tokyonight, nord,
  catppuccin, everforest, a faithful Solarized (e.g. `maxmx03/solarized.nvim` or equivalent —
  finalized in the plan).

### 5.5 zsh integration (`.zshrc` + OS files)
- On shell startup: read state, **re-emit OSC repaint** from the palette (so new Konsole/iTerm2
  windows match — this is how persistence works portably, no emulator profile files needed),
  then set dircolors/`LS_COLORS` per `background` (dark vs light ramps).
- p10k left as-is (reads terminal ANSI; shifts naturally with the palette).
- **Root-auto-red shell guard (toggle, on by default):** when enabled, a root shell
  (`$EUID == 0`) forces `phosphor-red` on startup regardless of the saved theme; normal user
  shells restore the chosen theme. Controlled by `THEME_ROOT_RED` (set `THEME_ROOT_RED=0` to
  disable). Red-for-root is the motivating use case.

### 5.6 State
- `~/.config/theme/current` — single line, the theme name. **Per-machine** (not synced).
- Missing/invalid → fall back to a default (`gruvbox-dark`).

### 5.7 Native emulator profiles (generated, importable)

In addition to the live OSC repaint, the switcher **generates native profile files** for each
theme from the same palette — so the emulator's own profile picker has matching entries, cold
starts look right, and the font is set consistently. A single `bin/theme-gen` generator reads a
`.theme` and emits every downstream artifact (OSC string, tmux conf, Konsole files, iTerm2
profile, nvim mapping) — keeping the palette the one source of truth.

- **Konsole (Linux):** per theme, emit a `<name>.colorscheme` (INI: `Background`, `Foreground`,
  `Color0..7` + `Color0..7Intense`, cursor) **and** a `Theme <name>.profile` referencing that
  colorscheme + the font. Installed to `~/.local/share/konsole/` (they then appear in
  Konsole's profile/scheme menus; no manual import dialog needed).
- **iTerm2 (macOS):** per theme, emit an **iTerm2 Dynamic Profile** (JSON) with `Ansi 0..15`,
  background/foreground/cursor, and font, written to
  `~/Library/Application Support/iTerm2/DynamicProfiles/readest-themes.json` *(one bundle file,
  all themes)*. Dynamic Profiles auto-load — no Preferences import step. (A classic
  `.itermcolors` per theme is also emitted into the repo for ad-hoc manual import / sharing.)
- **Font:** profiles set the terminal font to **`JetBrainsMono Nerd Font Mono`** (your primary;
  includes Nerd Font glyphs), size via a config var. Falls back to `Hack Nerd Font` /
  `BlexMono Nerd Font` (IBM Plex) — all three are installed by `bin/install-fonts.sh`, the
  canonical font list. Font face + size live in `~/.claude`-style config:
  `themes/theme.conf` (`THEME_FONT`, `THEME_FONT_SIZE`) so they're set once, not per theme.
- **Install/refresh:** `theme --install-profiles` (also run by bootstrap) regenerates and drops
  all native profiles into the per-OS locations above. Re-runnable and idempotent. The
  generated files are machine-local; the **generator + palettes** are what live in dotfiles.
- Live switching still goes through OSC (§5.2); profiles cover the cold-start / native-picker
  case. Switching the *active* profile programmatically (Konsole D-Bus / iTerm2 escape) is
  optional and not required since OSC already repaints the running session.

## 6. Monochrome (phosphor) carve-out

The hybrid's one special branch. For `phosphor-{green,green-apple,amber,red}`:
- The palette file defines a 16-step ramp of the single hue (dark→bright), `bg` near-black,
  `cursor`/`selection` in-hue.
- Emulator + tmux + dircolors consume the palette exactly like any other theme.
- nvim takes the `nvim_generate=mono` branch: highlights built from the ramp (no plugin needed).
- All four ramps are **warm and softened** (period-accurate phosphor tone): IBM green on the
  5151 P39, Apple ][ green on the cooler/crisper P31, amber on period P3/P134 amber monitors,
  red a soft desaturated rose (the softest). None use saturated RGB primaries. sRGB ramps
  tuned from int10h's monochrome-CRT phosphor reference.

## 7. Command UX

```
theme                 # fzf picker (numbered-menu fallback)
theme nord            # switch everything, live
theme list            # available + current
theme next / prev     # cycle
theme --no-emulator solarized-light
```

## 8. Fit with existing setup

- Supersedes `bin/tmux-theme` (kept as alias). Reuses `.tmux/themes/` (now generated).
- `bin/24-bit-color.sh` retained as a truecolor sanity check.
- All new code/palettes in `~/git/dotfiles` → syncs to both machines.
- Native emulator profiles (Konsole + iTerm2) are **generated** from the palettes (§5.7) and
  installed per-OS; the generator + palettes are the synced artifacts.
- Font set to `JetBrainsMono Nerd Font Mono` per `bin/install-fonts.sh` (the canonical font
  list: JetBrains Mono, IBM Plex Mono, Hack — all with Nerd Font variants).

## 9. Testing

- **Palette parser** — parse a `.theme` file → key/value map; reject malformed.
- **OSC encoder** — palette → exact escape-byte string (fixture comparison).
- **tmux passthrough wrapper** — wraps correctly only when `$TMUX` set.
- **Theme validation** — every shipped `.theme` has all 16 colors + required keys.
- **nvim module** — read-state → correct colorscheme/background resolution (incl. mono branch).
- **Profile generator** — `theme-gen` emits valid Konsole `.colorscheme` INI (all Color0..7 +
  Intense, Background/Foreground) and valid iTerm2 Dynamic-Profile JSON (parses; has Ansi 0–15,
  bg/fg/cursor, font) for every theme; font face = `THEME_FONT`.
- **Smoke** — `theme list`, `theme <each>` exits 0 with tmux/nvim absent;
  `theme --install-profiles` exits 0 and writes the expected per-OS files.

## 10. Out of scope (v1)

- Programmatic switching of the emulator's *active* profile (OSC repaint covers the live case;
  generated profiles cover cold start / the native picker).
- Per-theme p10k accent palettes (p10k left as-is).
- GUI/preview tool. Light/dark auto-switch by time of day (possible future).

## 11. File inventory (new/changed)

```
~/git/dotfiles/
  themes/*.theme                      # 12 palette files (source of truth)
  themes/theme.conf                   # THEME_FONT / THEME_FONT_SIZE (+ defaults)
  bin/theme                           # worker (switch live + state)
  bin/theme-gen                       # generator: palette → all artifacts (tmux/Konsole/iTerm2/OSC)
  bin/tmux-theme                      # → alias to theme (back-compat)
  .tmux/themes/*.conf                 # generated from palettes
  .tmux.conf                          # + allow-passthrough on; load current theme
  .config/nvim/lua/theme-sync.lua     # startup apply + fs-watch + mono generator
  .config/nvim/init.lua               # require theme-sync; add colorscheme plugins
  .zshrc (+ .zshrc.macos/.linux)      # startup OSC repaint + dircolors + optional root-red

# Generated, machine-local (written by `theme --install-profiles`, not committed):
  ~/.local/share/konsole/<name>.colorscheme + Theme <name>.profile        # Linux
  ~/Library/Application Support/iTerm2/DynamicProfiles/readest-themes.json # macOS
  themes/generated/*.itermcolors      # committed for ad-hoc manual import / sharing

  docs/superpowers/specs/2026-06-20-terminal-theme-switcher-design.md  # this file
```
