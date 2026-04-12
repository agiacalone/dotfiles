-- ~/.config/nvim/lua/plugins/ui.lua
return {
  -- Colorscheme
  {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	opts = {},
  },

  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        italic = {
          strings   = true,
          emphasis  = true,
          comments  = true,
          operators = false,
          folds     = true,
        },
        bold = true,
      })
      vim.cmd("colorscheme gruvbox")
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = {
          theme                = "gruvbox",
          icons_enabled        = vim.g.have_nerd_font,
          section_separators   = vim.g.have_nerd_font and { left = "", right = "" } or "",
          component_separators = vim.g.have_nerd_font and { left = "", right = "" } or "",
        },
      })
    end,
  },

  -- File tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    init = function()
      vim.g.loaded_netrw       = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    config = function()
      require("nvim-tree").setup({
        renderer = {
          icons = {
            show = {
              file         = vim.g.have_nerd_font,
              folder       = vim.g.have_nerd_font,
              folder_arrow = vim.g.have_nerd_font,
              git          = vim.g.have_nerd_font,
            },
          },
        },
      })
      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>")
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup()
    end,
  },

  {
    "zaldih/themery.nvim",
    lazy = false,
    config = function()
      require("themery").setup({
		themes = {"gruvbox", "tokyonight"}, -- Your list of installed colorschemes.
		livePreview = true, -- Apply theme while picking. Default to true.       -- add the config here
      })
    end
  },

  -- Start screen
  { "mhinz/vim-startify", lazy = false },
}
