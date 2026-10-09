-- Core editor options. Helix/AstroNvim-flavored defaults.
local o = vim.opt

-- UI
o.number = true
o.relativenumber = true
o.cursorline = true
o.termguicolors = true
o.winborder = "rounded" -- 0.12: default border for every floating window/dialog
o.pumheight = 12
o.signcolumn = "yes" -- no gutter jumping when git signs/diagnostics appear
o.laststatus = 3
o.showmode = false -- we show it in keybindings hints instead; statusline is plain
o.scrolloff = 5 -- keep some context around the cursor (Helix default)
o.sidescrolloff = 5
o.wrap = false
o.breakindent = true
o.fillchars = { eob = " ", foldopen = "▾", foldclose = "▸", diff = "╱" }
o.list = true
o.listchars = { tab = "  ", trail = "·", nbsp = "␣", leadmultispace = "│" } -- native indent guides
o.virtualedit = "block"

-- Behavior
o.mouse = "a"
o.clipboard = "unnamedplus" -- Helix parity: yank/paste goes through system clipboard
o.confirm = true -- ":q" asks nicely instead of erroring with unsaved changes
o.undofile = true
o.swapfile = false
o.updatetime = 300
o.timeoutlen = 400 -- how long to wait after "Space" and such (jk also uses it)
o.ignorecase = true
o.smartcase = true
o.splitbelow = true
o.splitright = true
o.jumpoptions = "view" -- keep window cursor position when jumping around

-- Indentation (guess-indent.nvim overrides per-project)
o.expandtab = true
o.shiftwidth = 2
o.softtabstop = -1
o.smartindent = true

-- Completion
o.completeopt = "menu,menuone,popup" -- 0.12 native completion
