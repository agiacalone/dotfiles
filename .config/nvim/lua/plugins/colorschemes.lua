-- Colorscheme plugins for the theme switcher (gruvbox + tokyonight live in ui.lua).
-- All loaded eagerly so `theme-sync` can switch to any of them at runtime.
return {
  { "shaunsingh/nord.nvim",      lazy = false, priority = 1000 },
  { "sainnhe/everforest",        lazy = false, priority = 1000 },
  { "catppuccin/nvim",           name = "catppuccin", lazy = false, priority = 1000 },
  { "maxmx03/solarized.nvim",    lazy = false, priority = 1000, opts = {} },
}
