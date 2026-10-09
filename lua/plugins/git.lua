-- Git: gitsigns (inline) + lazygit (the real navigator).
-- Requires the lazygit binary → brew install lazygit
--
-- Inside LazyGit:
--   `e` on a file opens it HERE in this running Neovim (GIT_EDITOR is wired up
--   automatically by lazygit.nvim), so LazyGit becomes your codebase browser.
--   `<c-up>/<c-down>` scroll, `?` help.

-- Writes "e" inside LazyGit to open the file in THIS running Neovim instance:
-- nvim listens on a stable pipe; GIT_EDITOR uses it via --remote-tab.
-- (lazygit.nvim does not wire this itself; without it `e` spawns $GIT_EDITOR,
-- whose default may be a missing binary — that's the "exit status 127".)
local server_pipe = "/tmp/nvim-minimal-server.pipe"
pcall(vim.server_start, server_pipe) -- silence "already in use" when multiple instances run
vim.env.GIT_EDITOR = ("%s --server %s --remote-tab"):format(vim.v.progpath, server_pipe)

require("gitsigns").setup({
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "▁" },
    topdelete = { text = "▔" },
    changedelete = { text = "▎" },
  },
})

-- LazyGit window: full screen, borderless so it looks like its own pane.
-- (lazygit.nvim is configured purely through these global vars + :LazyGit*)
vim.g.lazygit_floating_window_scaling_factor = 1 -- default is 0.9
vim.g.lazygit_floating_window_winblend = 0
vim.g.lazygit_floating_window_border_chars = { " ", " ", " ", " ", " ", " ", " ", " " }

local map = vim.keymap.set
local gs = package.loaded["gitsigns"]

-- LazyGit (also available: :LazyGitFilter for commit/PR history browser)
map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
map("n", "<leader>gf", "<cmd>LazyGitFilter<cr>", { desc = "LazyGit commits" })

-- Inline hunks
map({ "n", "o", "x" }, "]h", function() gs.nav_hunk("next") end, { desc = "Next hunk" })
map({ "n", "o", "x" }, "[h", function() gs.nav_hunk("prev") end, { desc = "Previous hunk" })
map("n", "<leader>gp", gs.preview_hunk, { desc = "Git preview hunk" })
map("n", "<leader>gb", gs.blame_line, { desc = "Git blame line" })
map("n", "<leader>gB", function() gs.blame_line({ full = true }) end, { desc = "Git blame line (full)" })
map("n", "<leader>gR", gs.reset_hunk, { desc = "Git reset hunk" })
map("n", "<leader>gt", function() gs.toggle_current_line_blame() end, { desc = "Git toggle line blame" })
