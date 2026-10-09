-- Global keymaps that never depend on a specific plugin/module.
-- (Domain-specific maps live next to their plugin: plugins/{git,explorer,picker,lsp}.lua)
local map = vim.keymap.set

-- jk -> Esc (insert mode)
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Save / quit (AstroNvim style)
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
map("n", "<C-q>", "<cmd>confirm qa<cr>", { desc = "Quit all" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>confirm q<cr>", { desc = "Quit window" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Escape and clear search highlight" })

-- Buffers as tabs ------------------------------------------------------------------
-- Helix-style: buffers are the "tabs", H/L cycles through them.
-- (Overrides built-in H = "top of window" / L = "bottom of window".)
map({ "n", "x" }, "H", "<cmd>bprevious<cr>", { desc = "Previous buffer tab" })
map({ "n", "x" }, "L", "<cmd>bnext<cr>", { desc = "Next buffer tab" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to other buffer" })
-- Close buffer but keep the window (last listed buffer is replaced by a scratch)
map("n", "<leader>c", function() require("plugins.buffers").close_current() end, { desc = "Close buffer" })
map("n", "<leader>C", function() require("plugins.buffers").close_current(true) end, { desc = "Force close buffer" })

-- Windows --------------------------------------------------------------------------
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Resize taller" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Resize shorter" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Resize narrower" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Resize wider" })
map("n", "\\v", "<cmd>vsplit<cr>", { desc = "Vertical split" })
map("n", "\\h", "<cmd>split<cr>", { desc = "Horizontal split" })

-- Text objects / motions ------------------------------------------------------------
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Move down" })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Move up" })

-- Visual mode
map("v", "<", "<gv", { desc = "Shift left, keep selection" })
map("v", ">", ">gv", { desc = "Shift right, keep selection" })
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })
map("x", "p", '"_dP', { desc = "Paste without losing register" })

-- Comments: native gc / gcc operators (no plugin needed)

-- Diagnostics
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "<leader>xx", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>xX", vim.diagnostic.setqflist, { desc = "Diagnostics quickfix" })
