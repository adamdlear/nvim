-- Hand-rolled statusline: mode block, full file path, git branch,
-- diagnostics, line:col. Native Lua, no plugins. Catppuccin-mocha accents.
--
-- Layout:  [ MODE ]  dir/File ●  ──────────────────  branch | E2 W1 | 12:8

local LABELS = {
  n = " NORMAL ", i = " INSERT ", v = " VISUAL ", V = " V·LINE ",
  c = " CMD ", t = " TERM ", r = " REPLACE ", R = " REPLACE ", s = " SELECT ",
}
local HL_BY_MODE = { n = "N", i = "I", v = "V", V = "V", c = "C", t = "T", r = "R", R = "R", s = "S" }
local PALETTE = {
  N = "#89b4fa", I = "#a6e3a1", V = "#cba6f7", C = "#f9e2af", T = "#94e2d5", R = "#f38ba8", S = "#cba6f7",
}
for key, color in pairs(PALETTE) do
  vim.api.nvim_set_hl(0, "StatusMode" .. key, { fg = "#1e1e2e", bg = color, bold = true })
end
vim.api.nvim_set_hl(0, "StatusLineDir", { fg = "#7f849c" })   -- mocha overlay0
vim.api.nvim_set_hl(0, "StatusLineFile", { fg = "#cdd6f4" })  -- mocha text
vim.api.nvim_set_hl(0, "StatusLinePos", { fg = "#cdd6f4" })

local function mode_info()
  local m = vim.api.nvim_get_mode().mode
  local label = LABELS[m] or (LABELS[m:sub(1, 1)] or " NVIM ")
  return label, HL_BY_MODE[m] or HL_BY_MODE[m:sub(1, 1)] or "N"
end

local function diagnostics()
  local counts = vim.diagnostic.count(vim.api.nvim_get_current_buf())
  local err, warn = counts[1] or 0, counts[2] or 0
  if err + warn == 0 then return "" end
  local parts = {}
  if err > 0 then parts[#parts + 1] = ("%%#DiagnosticError#E%d"):format(err) end
  if warn > 0 then parts[#parts + 1] = ("%%#DiagnosticWarn#W%d"):format(warn) end
  return " " .. table.concat(parts, "") .. " "
end

local function git_branch()
  local dict = vim.g.gitsigns_status_dict
  local head = (dict and dict.head) or vim.g.gitsigns_head
  return (head and head ~= "") and ("%%#StatusLineDir# %s "):format(head) or ""
end

function _G.Statusline()
  local label, key = mode_info()
  local path = vim.api.nvim_buf_get_name(0)
  local file_seg
  if path == "" then
    file_seg = "%#StatusLineFile# [No Name]"
  else
    -- shorten $HOME to ~ (mimics fnamemodifier ":~", which is a removed builtin in 0.12)
    local home = vim.env.HOME
    if home and path:sub(1, #home + 1) == home .. "/" then
      path = "~" .. path:sub(#home + 1)
    end
    local dir, name = path:match("^(.*)/(.+)$")
    if not dir then dir, name = "", path end
    -- NOTE: the separating space lives INSIDE the first token of this segment;
    -- a space appended to the mode block would just be painted in mode colors.
    file_seg = ("%%#StatusLineDir# %s/%%#StatusLineFile#%s"):format(dir, name)
  end

  local modified = vim.bo.modified and "%%#DiagnosticWarn#●" or "%#StatusLineDir#"

  return table.concat({
    ("%%#StatusMode%s#%s"):format(key, label),
    file_seg,
    modified,
    "%=",
    git_branch(),
    diagnostics(),
    ("%%#StatusLinePos#%d:%d "):format(vim.fn.line("."), vim.fn.col(".")),
  })
end

vim.o.statusline = "%{%v:lua.Statusline()%}"
