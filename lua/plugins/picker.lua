-- fzf-lua — lightweight fuzzy pickers (needs `fzf`: brew install fzf)
-- Helix-like: vim.ui.select (LSP code actions etc.) is routed through fzf too.
local fzf = require("fzf-lua")

fzf.setup({}) -- sensible defaults; inside a picker: <f1> help, <esc> quit, <C-q> -> quickfix

fzf.register_ui_select() -- every vim.ui.select now opens an fzf window

local map = vim.keymap.set
-- "Find" — names follow AstroNvim's <leader>f section
map("n", "<leader>ff", fzf.files, { desc = "Find files (cwd)" })
map("n", "<leader>fF", fzf.git_files, { desc = "Find git files" })
map("n", "<leader>fr", fzf.oldfiles, { desc = "Find recent files" })
map("n", "<leader>fb", fzf.buffers, { desc = "Find buffers" })
map("n", "<leader>fw", fzf.live_grep, { desc = "Find words (live grep)" })
map("n", "<leader>fW", function() fzf.grep_cword() end, { desc = "Find word under cursor" })
map("n", "<leader>fd", fzf.diagnostics_document, { desc = "Find diagnostics" })
map("n", "<leader>fR", fzf.resume, { desc = "Resume last picker" })
map("n", "<leader>fc", fzf.colorschemes, { desc = "Find colorschemes" })
