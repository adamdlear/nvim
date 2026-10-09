-- Treesitter: Neovim 0.12 handles highlighting natively; this only installs
-- parsers + queries from the community registry and enables folds/indent.
-- NOTE: compiling parsers needs the `tree-sitter` CLI → brew install tree-sitter
local ts = require("nvim-treesitter")

-- Parsers to have ready at startup (edit freely). For anything else:
--   :TSInstall <language>        (one-off)
-- or add it to this list.
local PARSERS = {
  -- core
  "bash", "json", "yaml", "lua", "vim", "vimdoc", "markdown", "markdown_inline",
  -- go + web/js stack
  "go", "typescript", "tsx", "javascript",
  -- infra files
  "dockerfile", "toml", "css", "html",
}

-- Install only the missing ones (no-op when all present). First run may block
-- up to a minute while compiling; afterwards it's instant.
do
  local installed = require("nvim-treesitter.config").get_installed()
  local missing = vim.iter(PARSERS)
    :filter(function(p) return not vim.tbl_contains(installed, p) end)
    :totable()
  if #missing > 0 then
    local ok, task = pcall(ts.install, missing, { summary = true })
    if ok and task then task:wait(60000) end
  end
end

-- Enable highlighting + treesitter indentation for every filetype that has a
-- parser/queries available (0.12 core does the highlighting; the plugin provides indentexpr).
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user-treesitter", { clear = true }),
  pattern = "*",
  callback = function(ev)
    local lang = vim.bo[ev.buf].filetype
    if lang == "" or not vim.treesitter.language.add(lang) then
      return
    end
    vim.treesitter.start(ev.buf)
    -- Indentation: only when this language ships indents queries
    local ok, has_indents = pcall(function()
      return vim.treesitter.query.get(lang, "indents") ~= nil
    end)
    if ok and has_indents then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
