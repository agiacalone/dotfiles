-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  -- Mason: LSP server manager
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- Bridge mason <-> lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig", "hrsh7th/cmp-nvim-lsp" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "marksman",       -- Markdown
          "clangd",         -- C/C++
          "bashls",         -- Shell
          "texlab",         -- LaTeX
        },
        automatic_installation = true,
      })

      local lspconfig    = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local on_attach = function(_, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
        end
        map("gd",          vim.lsp.buf.definition,   "Go to Definition")
        map("K",           vim.lsp.buf.hover,         "Hover Documentation")
        map("gr",          vim.lsp.buf.references,    "Go to References")
        map("<leader>rn",  vim.lsp.buf.rename,        "Rename")
        map("<leader>ca",  vim.lsp.buf.code_action,   "Code Action")
      end

      local servers = { "marksman", "clangd", "bashls", "texlab" }
      for _, server in ipairs(servers) do
        lspconfig[server].setup({ capabilities = capabilities, on_attach = on_attach })
      end
    end,
  },

  -- LSP config
  { "neovim/nvim-lspconfig" },

  -- Snippets engine
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Linters / formatters bridge
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          -- Markdown
          null_ls.builtins.diagnostics.markdownlint,  -- comment out if markdownlint not installed
          null_ls.builtins.diagnostics.vale,           -- comment out if vale not installed
          -- Shell
          null_ls.builtins.diagnostics.shellcheck,
          -- C/C++: clangd (LSP) already provides C/C++ diagnostics; cppcheck has no none-ls builtin
          -- LaTeX
          null_ls.builtins.diagnostics.chktex,
        },
      })
    end,
  },
}
