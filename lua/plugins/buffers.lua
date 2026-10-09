-- Buffers-as-tabs: a tiny native tabline (Helix top-bar feel) plus helpers.
-- No plugin — just 'tabline' + a bit of Lua. Icons can be added later (mini.icons).
-- NOTE: evaluated on every redraw, so it must never throw (pcall + pure-Lua APIs).

local status_hi_cur, status_hi = "%#TabLineSel#", "%#TabLine#"
local hi_changed = "%#TabLineModified#"

local function render()
  local cur_buf = vim.api.nvim_get_current_buf()
  local listed = vim.fn.getbufinfo({ buflisted = 1 })
  -- most recently used first, so the "tab" order roughly matches history
  table.sort(listed, function(a, b) return (a.lastused or 0) > (b.lastused or 0) end)

  local s = ""
  for _, b in ipairs(listed) do
    local name = vim.fs.basename(b.name or "")
    if name == "" then name = "[No Name]" end
    local hi = (b.bufnr == cur_buf) and status_hi_cur or status_hi
    local flag = (b.changed or 0) ~= 0 and hi_changed .. "●" or ""
    s = s .. ("%s %s%s "):format(hi, name, flag)
  end
  return s .. "%#TabLineFill#"
end

vim.o.tabline = "%{%v:lua._buf_tabline()%}"
function _G._buf_tabline()
  local ok, line = pcall(render)
  return ok and line or "Buffers"
end

local M = {}

--- Close the current buffer but keep the window alive.
--- If it's the last listed buffer you're left with an empty scratch buffer.
---@param force? boolean also close buffers with unsaved changes
function M.close_current(force)
  local current = vim.api.nvim_get_current_buf()
  if not force and vim.bo[current].modified then
    return vim.notify("Buffer has unsaved changes — use <leader>C to force", vim.log.levels.WARN)
  end
  vim.cmd("bprevious")            -- shift the window to another buffer first
  pcall(vim.cmd, ("bdelete%s %d"):format(force and "!" or "", current))
end

return M
