-- Go: gofmt/goimports emit TABS for indentation. Keep literal tabs; the main
-- fix is tabstop=4 (display width) instead of the huge default 8.
-- nvim's builtin ftplugin/go.vim sets shiftwidth=0 ("follow tabstop") after
-- this file runs — that's intentional, indentation step stays = tabstop here.
vim.opt_local.expandtab = false
vim.opt_local.tabstop = 4
