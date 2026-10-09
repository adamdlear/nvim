-- Native startup screen: mimics the style of nvim 0.12's `type ... <Enter>`
-- intro lines, with helpful actions. No plugin involved.
local M = {}

local ACTIONS = {
  { key = "f", desc = "to find files",         action = function() require("fzf-lua").files() end },
  { key = "n", desc = "to start a new file",   action = "enew" },
  { key = "r", desc = "to open recent files",  action = function() require("fzf-lua").oldfiles() end },
  { key = "w", desc = "to search words",       action = function() require("fzf-lua").live_grep() end },
  { key = "e", desc = "to explore with Yazi",  action = function() require("yazi").yazi(nil, vim.fn.getcwd()) end },
  { key = "g", desc = "for git (LazyGit)",     action = "LazyGit" },
  { key = "q", desc = "to quit neovim",        action = "confirm qall" },
}

local SEPARATOR = ("─"):rep(48)
local raw_lines = {} -- un-centered lines, re-rendered on window resize
local ns = vim.api.nvim_create_namespace("scratch_dashboard")

-- Window-local styling only while the dashboard is displayed. Anything else
-- that ever lands in that window gets the user's normal defaults back.
local DASH_WIN = { number = false, relativenumber = false, cursorline = false, cursorcolumn = false, list = false, signcolumn = "no", spell = false, colorcolumn = "" }
local USER_WIN = { number = vim.o.number, relativenumber = vim.o.relativenumber, cursorline = vim.o.cursorline, cursorcolumn = vim.o.cursorcolumn, list = vim.o.list, signcolumn = vim.o.signcolumn, spell = vim.o.spell, colorcolumn = vim.o.colorcolumn }

local function style_window(win_id, opts)
  if win_id < 0 then return end
  for key, value in pairs(opts) do
    vim.wo[win_id][key] = value
  end
end

local function run_action(action)
  -- Note: NO window-style restore here. Float-based actions (Yazi, LazyGit,
  -- fzf pickers) run over the dashboard buffer, which stays in this window.
  -- The BufWinLeave autocmd below restores the editor look only when this
  -- buffer actually leaves the window (file opened over it, ":e", wipe).
  if type(action) == "string" then
    vim.cmd(action)
  else
    action()
  end
end

local function render(buf_id)
  local width = 0
  for _, line in ipairs(raw_lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  local win_id = vim.fn.bufwinid(buf_id)
  local pad_h = math.max(math.floor((vim.api.nvim_win_get_width(win_id) - width) / 2), 0)
  -- vertical: nvim-intro style — top pad of about half the leftover space
  local pad_v = math.max(math.floor((vim.api.nvim_win_get_height(win_id) - #raw_lines) / 2) - 1, 0)
  local out = {}
  for _ = 1, pad_v do
    out[#out + 1] = ""
  end
  for _, line in ipairs(raw_lines) do
    out[#out + 1] = (" "):rep(pad_h) .. line
  end
  local was_modifiable = vim.bo[buf_id].modifiable
  vim.bo[buf_id].modifiable = true
  vim.api.nvim_buf_clear_namespace(buf_id, ns, 0, -1)
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, out)
  vim.bo[buf_id].modifiable = was_modifiable
  for row, line in ipairs(out) do
    if line:find(SEPARATOR, 1, true) then
      vim.api.nvim_buf_add_highlight(buf_id, ns, "Comment", row - 1, 0, #line)
    elseif vim.fn.trim(line) == "neovim" then
      vim.api.nvim_buf_add_highlight(buf_id, ns, "Title", row - 1, 0, #line)
    end
  end
end

function M.open()
  -- only when nvim was started without file args (intro-style conditions)
  if #vim.fn.argv() > 0 then return end

  local buf_id = vim.api.nvim_get_current_buf()
  if vim.bo[buf_id].modified or (vim.fn.getbufline(buf_id, 1)[1] or "") ~= "" then return end

  raw_lines = { "neovim", "", SEPARATOR }
  for _, a in ipairs(ACTIONS) do
    raw_lines[#raw_lines + 1] = ("type  %s<Enter>            %s"):format(a.key, a.desc)
  end
  raw_lines[#raw_lines + 1] = SEPARATOR
  raw_lines[#raw_lines + 1] = ""
  raw_lines[#raw_lines + 1] = ("type  <leader><Enter>       to explore keymaps")

  render(buf_id)
  vim.bo[buf_id].bufhidden = "wipe"
  vim.bo[buf_id].buflisted = false
  vim.bo[buf_id].buftype = "nofile" -- scratch: never written to disk, never prompts on quit
  vim.bo[buf_id].modifiable = false

  style_window(vim.api.nvim_get_current_win(), DASH_WIN)
  -- if anything else replaces this buffer (e.g. ":e somefile"), undo the window styling
  vim.api.nvim_create_autocmd("BufWinLeave", {
    group = vim.api.nvim_create_augroup("scratch_dashboard_style", { clear = true }),
    buffer = buf_id,
    once = true,
    callback = function()
      pcall(style_window, vim.fn.bufwinid(buf_id), USER_WIN)
    end,
  })

  for _, a in ipairs(ACTIONS) do
    vim.keymap.set("n", a.key, function()
      run_action(a.action)
    end, { buffer = buf_id, nowait = true, silent = true, desc = "Dashboard: " .. a.desc })
  end

  -- re-center on resize while the dashboard is displayed
  vim.api.nvim_create_autocmd("VimResized", {
    group = vim.api.nvim_create_augroup("scratch_dashboard_resize", { clear = true }),
    callback = function()
      if vim.api.nvim_buf_is_valid(buf_id) and vim.fn.bufwinid(buf_id) >= 0 then
        render(buf_id)
      end
    end,
  })
end

return M
