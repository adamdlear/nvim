-- Language support: Mason installs servers, native vim.lsp runs them.
-- Navigating (built-in, no config): gd definition, K hover, gra code action,
-- grn rename, grr references, gO document symbols.

-- Server names are Mason/lspconfig names — add/remove what you actually write.
local SERVERS = {
  "lua_ls",
  "ts_ls",
  "gopls",
  "dockerls",                         -- Dockerfiles
  "docker_compose_language_service",  -- compose YAMLs
  "bashls",
  "jsonls",
  "yamlls",
  "rust_analyzer",
  "pyright",
}

-- Diagnostics: inline on the current line only (Helix-ish, less noise)
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { current_line = true },
  signs = true,
  underline = true,
})

require("mason").setup({})
require("mason-lspconfig").setup({
  ensure_installed = SERVERS,
  automatic_enable = { exclude = { "stylua" } }, -- stylua is a formatter, not an LSP we want
})

-- Per-server config example (0.12 uses vim.lsp.config, not on_attach tables)
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
    },
  },
})
vim.lsp.config("gopls", {
  settings = {
    gopls = { gofumpt = true }, -- stricter formatting via <leader>lf
  },
})

-- LSP-attach behavior (buffer-local keymaps + native completion)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local bufnr = ev.buf
    if not client then return end

    -- Native completion with auto-trigger (no completion plugin)
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end

    -- Inlay hints on by default when the server provides them (Helix parity)
    if client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = "LSP: " .. desc })
    end
    map("n", "gd", vim.lsp.buf.definition, "Goto definition")
    map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
    map("n", "gI", vim.lsp.buf.implementation, "Goto implementation")
    map("n", "gr", vim.lsp.buf.references, "References")   -- built-in grr also works
    map("n", "K", vim.lsp.buf.hover, "Hover docs")
    map("n", "<leader>la", vim.lsp.buf.code_action, "Code action")
    map("n", "<leader>lr", vim.lsp.buf.rename, "Rename symbol")
    map("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format")
    local fzf = require("fzf-lua")
    map("n", "<leader>ls", fzf.lsp_document_symbols, "Document symbols")
    map("n", "<leader>lS", fzf.lsp_live_workspace_symbols, "Workspace symbols")
  end,
})

-- Misc LSP toggles
vim.keymap.set("n", "<leader>uh", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({})) end, { desc = "Toggle inlay hints" })

-- Save-time: organize imports + format, fully synchronous so both land BEFORE
-- the write. Go = gopls "source.organizeImports" (gofmt+goimports semantics);
-- TS/JS = same concept via ts_ls ("source.organizeImports.ts").
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("user-lsp-write", { clear = true }),
  -- NOTE: BufWritePre pattern = filename glob, not filetype
  pattern = { "*.go", "*.ts", "*.tsx", "*.mts", "*.js", "*.jsx", "*.mjs" },
  callback = function(args)
    local bufnr = args.buf
    local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/codeAction" })
    if #clients == 0 then return end

    local params = vim.lsp.util.make_range_params(0, clients[1].offset_encoding)
    params.context = {
      only = {
        "source.organizeImports",       -- gopls
        "source.organizeImports.ts",    -- ts_ls: sort + drop unused
        "source.addMissingImports.ts",  -- ts_ls
        "source.removeUnused.ts",       -- ts_ls
      },
      diagnostics = {},
    }
    local responses = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 10000)
    for client_id, response in pairs(responses or {}) do
      local client = vim.lsp.get_client_by_id(client_id)
      -- the server already filtered against `params.context.only`, apply all
      for _, action in ipairs(response.result or {}) do
        if action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding or "utf-16")
        end
        if action.command then
          vim.lsp.buf.execute_command(action.command)
        end
      end
    end
    vim.lsp.buf.format({ bufnr = bufnr, async = false, timeout_ms = 5000 })
  end,
})
