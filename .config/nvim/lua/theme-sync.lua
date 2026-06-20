-- theme-sync: keep neovim's colorscheme in lockstep with the terminal theme
-- switcher (state at ~/.config/theme/current, written by `theme`). Rich themes map
-- to plugin colorschemes; the phosphor themes get a generated monochrome highlight
-- set built from their palette ramp.
local M = {}
local uv = vim.uv or vim.loop

local function state_file()
  return vim.env.THEME_STATE or vim.fn.expand("~/.config/theme/current")
end

local function themes_dir()
  if vim.env.THEME_ROOT and uv.fs_stat(vim.env.THEME_ROOT) then return vim.env.THEME_ROOT end
  for _, d in ipairs({ vim.fn.expand("~/themes"), vim.fn.expand("~/git/dotfiles/themes") }) do
    if uv.fs_stat(d) then return d end
  end
  return vim.fn.expand("~/themes")
end

-- name -> { scheme = <nvim colorscheme>, bg = dark|light }
local MAP = {
  ["nord"]             = { scheme = "nord",             bg = "dark"  },
  ["gruvbox-dark"]     = { scheme = "gruvbox",          bg = "dark"  },
  ["gruvbox-light"]    = { scheme = "gruvbox",          bg = "light" },
  ["tokyonight"]       = { scheme = "tokyonight-night", bg = "dark"  },
  ["solarized-dark"]   = { scheme = "solarized",        bg = "dark"  },
  ["solarized-light"]  = { scheme = "solarized",        bg = "light" },
  ["catppuccin-mocha"] = { scheme = "catppuccin-mocha", bg = "dark"  },
  ["everforest"]       = { scheme = "everforest",       bg = "dark"  },
  ["tomorrow-night-eighties"] = { scheme = "base16-tomorrow-night-eighties", bg = "dark" },
}

local function read_state()
  local f = io.open(state_file(), "r"); if not f then return nil end
  local n = f:read("l"); f:close()
  if n then n = n:gsub("%s+", "") end
  if n == "" then n = nil end
  return n
end

local function parse_palette(name)
  local f = io.open(themes_dir() .. "/" .. name .. ".theme", "r"); if not f then return nil end
  local p = {}
  for line in f:lines() do
    local k, v = line:match("^([%w_]+)=(.+)$")
    if k then p[k] = v end
  end
  f:close()
  return p
end

local function apply_mono(p)
  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.cmd("highlight clear")
  local set, bg, fg = vim.api.nvim_set_hl, p.bg, p.fg
  local c = function(i) return p["color" .. i] end
  set(0, "Normal",       { fg = fg,   bg = bg })
  set(0, "NormalNC",     { fg = fg,   bg = bg })
  set(0, "NormalFloat",  { fg = fg,   bg = c(8) })
  set(0, "Comment",      { fg = c(8), italic = true })
  set(0, "LineNr",       { fg = c(8) })
  set(0, "CursorLineNr", { fg = c(11), bold = true })
  set(0, "CursorLine",   { bg = c(0) })
  set(0, "Visual",       { bg = p.selection })
  set(0, "StatusLine",   { fg = bg,   bg = c(10) })
  set(0, "StatusLineNC", { fg = c(7), bg = c(0) })
  set(0, "Pmenu",        { fg = fg,   bg = c(8) })
  set(0, "PmenuSel",     { fg = bg,   bg = c(11) })
  set(0, "String",       { fg = c(10) })
  set(0, "Function",     { fg = c(11) })
  set(0, "Keyword",      { fg = c(12), bold = true })
  set(0, "Statement",    { fg = c(12), bold = true })
  set(0, "Type",         { fg = c(14) })
  set(0, "Identifier",   { fg = fg })
  set(0, "Constant",     { fg = c(13) })
  set(0, "Special",      { fg = c(11) })
  set(0, "PreProc",      { fg = c(13) })
  set(0, "Title",        { fg = c(15), bold = true })
  set(0, "ColorColumn",  { bg = c(0) })
  set(0, "Search",       { fg = bg,   bg = c(11) })
  set(0, "Error",        { fg = c(9) })
  set(0, "WinSeparator", { fg = c(8) })
end

function M.apply(name)
  name = name or read_state() or "gruvbox-dark"
  local m = MAP[name]
  if m then
    vim.o.background = m.bg
    pcall(vim.cmd, "colorscheme " .. m.scheme)
  else
    local p = parse_palette(name)
    if p then apply_mono(p) end
  end
  -- keep lualine in step if present
  pcall(function() require("lualine").setup({ options = { theme = "auto" } }) end)
end

function M.setup()
  M.apply()
  local dir = vim.fn.fnamemodify(state_file(), ":h")
  vim.fn.mkdir(dir, "p")
  local fse = uv.new_fs_event()
  if not fse then return end
  local function arm()
    fse:start(dir, {}, vim.schedule_wrap(function()
      M.apply()
      pcall(function() fse:stop() end)  -- re-arm (some backends are one-shot)
      arm()
    end))
  end
  arm()
end

return M
