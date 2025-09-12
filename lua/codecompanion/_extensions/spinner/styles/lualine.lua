-- A lualine component that shows CodeCompanion spinner status.
-- Based on the CodeCompanion documentation example.
local M = require("lualine.component"):extend()

M.processing = false
M.spinner_index = 1

local spinner_symbols = {
  "⠋",
  "⠙",
  "⠹",
  "⠸",
  "⠼",
  "⠴",
  "⠦",
  "⠧",
  "⠇",
  "⠏",
}
local spinner_symbols_len = 10

-- Initializer
function M:init(options)
  M.super.init(self, options)

  local group = vim.api.nvim_create_augroup("CodeCompanionLualineSpinner", { clear = true })

  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "CodeCompanionRequest*",
    group = group,
    callback = function(request)
      if request.match == "CodeCompanionRequestStarted" then
        self.processing = true
      elseif request.match == "CodeCompanionRequestFinished" then
        self.processing = false
      end
    end,
  })
end

-- Function that runs every time statusline is updated
function M:update_status()
  if self.processing then
    self.spinner_index = (self.spinner_index % spinner_symbols_len) + 1
    return spinner_symbols[self.spinner_index]
  else
    return nil
  end
end

--- Returns a lualine component configuration that can be directly added to lualine sections.
--- @return table The lualine component configuration
function M.get_lualine_component()
  return M
end

--- One-time setup for this spinner style.
function M.setup()
    -- Check for dependency
    local ok, _ = pcall(require, "lualine")
    if not ok then
        vim.notify("Lualine spinner requires `lualine.nvim` plugin.", vim.log.levels.WARN, { title = "CodeCompanion Spinners" })
    end
end

return M
