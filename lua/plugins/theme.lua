-- catppuccin — flavours: latte | frappe | macchiato | mocha
require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = false,
})
vim.cmd.colorscheme("catppuccin-mocha")

-- :Catppuccin {flavour} switches instantly (built into the theme).
vim.keymap.set("n", "<leader>tt", function()
  local flavors = { "latte", "frappe", "macchiato", "mocha" }
  vim.g.catppuccin_flavour = flavors[(vim.tbl_contains(flavors, vim.g.catppuccin_flavour) and vim.g.catppuccin_flavour or 4) % #flavors + 1]
  require("catppuccin").compile()
  vim.cmd.colorscheme("catppuccin-" .. vim.g.catppuccin_flavour)
end, { desc = "Cycle catppuccin flavour" })
