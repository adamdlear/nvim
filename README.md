# Neovim Configuration

My personalized Neovim config

Requires **Neovim 0.12+** and git (`nvim --version`).

## Binaries

```sh
brew install fzf ripgrep lazygit yazi tree-sitter-cli
```

| binary | why |
|---|---|
| `fzf` | pickers (`<leader>f*`) + all `vim.ui.select` dialogs |
| `ripgrep` | live grep |
| `lazygit` | `<leader>gg`; `e` on a file opens it in the running nvim (via a `--server` pipe) |
| `yazi` | `<leader>e` floating explorer; `nvim .` opens it directly |
| `tree-sitter-cli` | compiles treesitter parsers (on-demand per language) |

LSP servers install lazily per filetype via Mason on first open.

## Install

### Option 1 — manual

```sh
git clone https://github.com/adamdlear/nvim.git ~/.config/nvim-minimal
NVIM_APPNAME=nvim-minimal nvim
```

(`NVIM_APPNAME` keeps state/cache separate from any other Neovim setup.)
First launch: confirm the plugin clones (`y`/`a`), open files to trigger Mason.

### Option 2 — nvmgr

With [nvmgr](https://github.com/adamdlear/nvmgr) (one-time):

```sh
curl -sSfL https://raw.githubusercontent.com/adamdlear/nvmgr/main/install.sh | sh
nvmgr setup
```

Then install and switch:

```sh
nvmgr install https://github.com/adamdlear/nvim.git minimal
nvmgr use minimal
```

Handy: keep another distro around and hop with `nvmgr launch`.
See `nvmgr list` for the active config; `nvmgr restore` un-hooks the wrapper.

## Updating plugins

```vim
:packupdate        " review buffer -> :write to apply, :quit to discard
:h vim.pack
```

Commit `nvim-pack-lock.json` afterwards — a new machine reproduces these exact
plugin revisions on first launch.

## Keymap cheat sheet

Leader is `<Space>`; press it and wait — which-key (helix preset) lists everything.

- **Basics**: `jk` Esc · `<C-s>` save · `<C-q>` quit · `<Esc>` clear search ·
  `H`/`L` prev/next buffer · `<leader>c` close buffer · `<C-h/j/k/l>` window focus ·
  `<C-arrows>` resize · `\v`/`\h` splits
- **Roadmap (startup screen)**: `f` files · `e` new file · `r` recent · `w` live grep ·
  `g` LazyGit · `y` Yazi · `q` quit
- **Find** (`<leader>f*`): ff files · fF git files · fr recent · fb buffers ·
  fw live grep · fW word-under-cursor · fd diagnostics · fR resume
- **Git** (`<leader>g*`): gg LazyGit · gf commits · ]h/[h hunk nav · gp hunk preview ·
  gb line blame · gt toggle blame column
- **LSP**: gd def · K hover · gra action · grn rename · grr refs ·
  `<leader>la/lf/lr/ls` action/format/rename/symbols · `<leader>uh` inlay hints
- **Toggles** (`<leader>u*`): ug inline diagnostics · uw wrap · un numbers · us spell
- Comments are native (`gc`/`gcc`), `<leader>tt` cycles catppuccin flavors

On save, Go/TS/JS buffers auto-organize imports and format (gopls/ts_ls);
Yazi and LazyGit round-trip edits into your session.

## Layout

```
init.lua            entry: leader, vim.pack list, plugin setup order
lua/options.lua     options (02: completeopt popup etc.)
lua/keymaps.lua     global maps (jk, H/L, saves, splits, diagnostics)
lua/autocmds.lua    yank highlight, cursor restore, equal splits, TermOpen
lua/statusline.lua  mode block + full path + branch + diagnostics + pos
lua/plugins/*       one per domain: theme/treesitter/buffers/explorer/picker/git/lsp
                    plus extras + dashboard + statusline (lua/ root)
ftplugin/*.lua      language indent conventions (go/dockerfile/yaml/make)
```

Language recipe: add servers to `SERVERS` in `lua/plugins/lsp.lua`, parsers to
`PARSERS` in `lua/plugins/treesitter.lua`, per-language indent quirk rules to
the collection of `ftplugin/<ft>.lua` files, and server options via
`vim.lsp.config("<server>", ...)`.
