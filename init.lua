--=============================================================================
-- init.lua — personalized minimal config
--
-- Requires Neovim 0.12+. Run alongside your AstroNvim setup without collision:
--   NVIM_APPNAME=nvim-minimal nvim
--
-- Plugins are managed by the built-in plugin manager, vim.pack.
--   • First run: vim.pack.add() will clone everything (confirm prompts).
--   • Update:    :packupdate        (shows a review buffer, :write to apply)
--   • Docs:      :h vim.pack
--=============================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("options")
require("keymaps")
require("statusline") -- hand-rolled mode/path/branch/diagnostics statusline

-- Plugins --------------------------------------------------------------------
vim.pack.add({
  -- Theme
  "https://github.com/catppuccin/nvim",
  -- Parser installer; 0.12 ships treesitter highlighting natively
  "https://github.com/neovim-treesitter/nvim-treesitter",
  -- LSP / language support
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  -- Git
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/kdheepak/lazygit.nvim",
  -- File explorer
  -- (plenary is yazi.nvim's required runtime dependency — vim.pack doesn't resolve deps)
  "https://github.com/mikavilpas/yazi.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
  -- Pickers
  "https://github.com/ibhagwan/fzf-lua",
  -- Small extras
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/nvim-mini/mini.pairs",
  "https://github.com/NMAC427/guess-indent.nvim",
  "https://github.com/folke/which-key.nvim",
})

-- Plugin configuration ---------------------------------------------------------
require("plugins.theme")       -- catppuccin
require("plugins.treesitter")  -- auto-install parsers + native TS highlight
require("plugins.buffers")     -- Helix-style buffer tabline, "close buffer" helper
require("plugins.explorer")    -- yazi.nvim
require("plugins.picker")      -- fzf-lua + <leader>f maps
require("plugins.git")         -- gitsigns + lazygit + <leader>g maps
require("plugins.lsp")         -- mason + vim.lsp + native completion
require("plugins.extras")      -- mini.pairs, guess-indent, which-key
require("plugins.dashboard").open() -- native intro-style startup screen
