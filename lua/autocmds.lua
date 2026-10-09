-- Autocommands for core behavior (plugin-specific hooks live with each plugin).
local augroup = vim.api.nvim_create_augroup("user-general", { clear = true })

-- Briefly highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function() (vim.hl or vim.highlight).on_yank() end,
})

-- Re-open files with the cursor at its last position
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local line = mark[1]
    if line > 1 and line < vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, { line, mark[2] })
    end
  end,
})

-- Make split windows equal-sized on terminal resize
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  command = "tabdo wincmd =",
})

-- Terminal buffers: no line numbers, easier Esc
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup,
  callback = function(ev)
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.spell = false
  end,
})
