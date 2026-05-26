-- ~/.config/nvim/lua/plugins/obsidian.lua
-- Active community fork (epwalsh/obsidian.nvim is archived).
return {
  {
    "obsidian-nvim/obsidian.nvim",
    version      = "*", -- latest tagged release
    ft           = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "hrsh7th/nvim-cmp",
    },
    keys = {
      { "<leader>oo", "<cmd>Obsidian quick_switch<cr>", desc = "Obsidian: quick switch" },
      { "<leader>os", "<cmd>Obsidian search<cr>",       desc = "Obsidian: search" },
      { "<leader>on", "<cmd>Obsidian new<cr>",          desc = "Obsidian: new note" },
      { "<leader>od", "<cmd>Obsidian today<cr>",        desc = "Obsidian: today's daily" },
      { "<leader>oy", "<cmd>Obsidian yesterday<cr>",    desc = "Obsidian: yesterday's daily" },
      { "<leader>ob", "<cmd>Obsidian backlinks<cr>",    desc = "Obsidian: backlinks" },
      { "<leader>ol", "<cmd>Obsidian links<cr>",        desc = "Obsidian: links in note" },
      { "<leader>ot", "<cmd>Obsidian tags<cr>",         desc = "Obsidian: tags" },
      { "<leader>og", "<cmd>Obsidian follow_link<cr>",  desc = "Obsidian: follow link" },
    },
    opts = {
      legacy_commands = false, -- use the `:Obsidian <subcmd>` interface

      workspaces = {
        { name = "vault", path = "/mnt/es1/anthony/obsidian/vault" },
      },

      daily_notes = {
        folder      = "daily",
        date_format = "%Y-%m-%d",
      },

      completion = {
        nvim_cmp  = true, -- [[wikilink]] + #tag completion via nvim-cmp
        min_chars = 2,
      },

      picker = {
        name = "telescope.nvim",
      },

      -- render-markdown.nvim already owns in-buffer rendering; don't double up.
      ui = { enable = false },
    },
  },
}
