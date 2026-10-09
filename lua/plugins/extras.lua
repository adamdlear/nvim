-- Small "everything you got for free in Helix" extras.

-- File-type icons for fzf-lua, which-key, LazyGit-style UIs
require("mini.icons").setup()

-- Auto-close brackets/quotes pairs
require("mini.pairs").setup()

-- Per-project tab/space detection
require("guess-indent").setup({})

-- which-key: press <leader> and wait to see your maps — helix's keybind hints,
-- for your own config. The "helix" preset renders hints bottom-line style.
require("which-key").setup({
  preset = "helix",
  spec = {
    { "<leader>f", group = "Find" },
    { "<leader>g", group = "Git" },
    { "<leader>l", group = "LSP" },
    { "<leader>u", group = "UI" },
    { "<leader>b", group = "Buffer" },
    { "<leader>t", group = "Theme" },
    { "<leader>x", group = "Diagnostics" },
    { "\\", group = "Splits" },
  },
})

-- <leader>u — quick UI toggles (Helix-ish)
local map = vim.keymap.set
map("n", "<leader>uw", function() vim.wo[0][0].wrap = not vim.wo[0][0].wrap end, { desc = "Toggle wrap" })
map("n", "<leader>un", function() vim.wo[0][0].relativenumber = not vim.wo[0][0].relativenumber end, { desc = "Toggle relative numbers" })
map("n", "<leader>us", function() vim.o.spell = not vim.o.spell end, { desc = "Toggle spellcheck" })
map("n", "<leader>ug", function()
  local cfg = vim.diagnostic.config()
  vim.diagnostic.config({ virtual_text = cfg.virtual_text and false or true })
end, { desc = "Toggle inline diagnostics" })
