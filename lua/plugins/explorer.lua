-- yazi.nvim — Yazi as a floating explorer, wired to this Neovim instance.
-- Requires the `yazi` binary → brew install yazi
-- Flow: <leader>e opens Yazi next to your file; `<enter>` (or `<c-x>`/`<c-v>`)
-- on a file opens it here as a normal buffer in your current session.
-- Run `:h yazi.nvim-` for the full keymap list inside the floating window.

require("yazi").setup({
  open_for_directories = true, -- `nvim .` (or a directory arg) launches Yazi
  -- 1 = fill the whole terminal area (default 0.9)
  floating_window_scaling_factor = 1,
})

vim.keymap.set("n", "<leader>e", function()
  local path = vim.api.nvim_buf_get_name(0)
  require("yazi").yazi(nil, path ~= "" and path or vim.fn.getcwd())
end, { desc = "Yazi at current file" })
vim.keymap.set("n", "<leader>E", "<cmd>Yazi toggle<cr>", { desc = "Yazi toggle" })
