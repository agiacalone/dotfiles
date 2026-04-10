-- ~/.config/nvim/lua/plugins/editing.lua
return {
  -- Surround motions (same muscle memory as vim-surround)
  { "kylechui/nvim-surround", config = function() require("nvim-surround").setup() end },

  -- Alignment
  { "godlygeek/tabular" },

  -- Markdown syntax
  {
    "plasticboy/vim-markdown",
    config = function()
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_conceal          = 0
    end,
  },

  -- Markdown rendering in buffer
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    config = function()
      require("render-markdown").setup()
    end,
  },

  -- Markdown live preview in browser
  {
    "iamcco/markdown-preview.nvim",
    cmd   = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init  = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },

  -- Session management
  { "tpope/vim-obsession" },
  {
    "dhruvasagar/vim-prosession",
    dependencies = { "tpope/vim-obsession" },
  },
}
