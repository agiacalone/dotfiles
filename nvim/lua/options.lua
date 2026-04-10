-- ~/.config/nvim/lua/options.lua
local opt = vim.opt

opt.showmode     = false          -- lualine shows mode
opt.tabstop      = 4
opt.softtabstop  = 4
opt.shiftwidth   = 4
opt.scrolloff    = 3              -- keep 3 lines when scrolling
opt.showcmd      = true
opt.hlsearch     = true
opt.incsearch    = true
opt.ruler        = true
opt.backup       = false
opt.ignorecase   = true
opt.title        = true
opt.modeline     = true
opt.modelines    = 3
opt.startofline  = false
opt.wrap         = true
opt.linebreak    = true
opt.textwidth    = 0
opt.colorcolumn  = "80"
opt.whichwrap    = "b,s,h,l,<,>,[,]"
opt.autoindent   = true
opt.smartindent  = true
opt.number       = true
opt.background   = "dark"
opt.wildmenu     = true
opt.showmatch    = true
opt.foldenable   = true
opt.foldlevelstart = 10
opt.foldnestmax  = 10
opt.foldmethod   = "indent"
opt.cursorline   = true
opt.swapfile     = false
opt.signcolumn   = "yes"          -- always show sign column (prevents layout shift)
opt.updatetime   = 250            -- faster CursorHold (gitsigns, LSP hover)
opt.splitright   = true           -- vertical splits open right
opt.splitbelow   = true           -- horizontal splits open below
opt.termguicolors = true
opt.autoread     = true           -- reload files changed outside vim (used by vim-tmux-focus-events)
opt.backspace    = "indent,eol,start"
opt.shortmess:append("atI")

-- Nerd Font availability (set NVIM_NERD_FONT=1 in shell on machines with a Nerd Font)
vim.g.have_nerd_font = vim.env.NVIM_NERD_FONT == "1"
