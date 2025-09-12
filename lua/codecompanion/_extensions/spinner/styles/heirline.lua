-- A heirline component that shows CodeCompanion status with text and icons.
-- Similar to other spinners but integrated into heirline.
local M = {}

M.current_text = ""
M.spinner_index = 1
M.last_update_time = 0

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

-- Update display based on event
local function update_display(event)
  local config = require("codecompanion._extensions.spinner.config")
  local default_icon = config.get().default_icon

  if event == "CodeCompanionRequestStarted" then
    local content = config.get_content_for_state("thinking")
    M.current_text = string.format("%s%s%s", default_icon, content.spacing, content.message)
  elseif event == "CodeCompanionRequestStreaming" then
    local content = config.get_content_for_state("receiving")
    M.current_text = string.format("%s%s%s", default_icon, content.spacing, content.message)
  elseif event == "CodeCompanionRequestFinished" then
    local content = config.get_content_for_state("done")
    M.current_text = string.format("%s%s%s", content.icon, content.spacing, content.message)
    -- Clear after a short delay
    vim.defer_fn(function()
      M.current_text = ""
    end, 2000)
  elseif event == "CodeCompanionToolStarted" then
    local content = config.get_content_for_state("tools_started")
    M.current_text = string.format("%s%s%s", content.icon, content.spacing, content.message)
  elseif event == "CodeCompanionToolFinished" then
    local content = config.get_content_for_state("tools_finished")
    M.current_text = string.format("%s%s%s", content.icon, content.spacing, content.message)
  elseif event == "CodeCompanionToolsFinished" then
    M.current_text = ""
  elseif event == "CodeCompanionChatDone" or event == "CodeCompanionChatStopped" then
    M.current_text = ""
  elseif event == "CodeCompanionChatCleared" then
    local content = config.get_content_for_state("cleared")
    M.current_text = string.format("%s%s%s", content.icon, content.spacing, content.message)
    vim.defer_fn(function()
      M.current_text = ""
    end, 2000)
  end
end

-- Setup autocmds when the module is loaded
function M.setup()
  -- Check for dependency
  local ok, _ = pcall(require, "heirline")
  if not ok then
    vim.notify(
      "Heirline spinner requires `heirline.nvim` plugin.",
      vim.log.levels.WARN,
      { title = "CodeCompanion Spinners" }
    )
    return
  end

  local group = vim.api.nvim_create_augroup("CodeCompanionHeirlineSpinner", { clear = true })

  -- Listen to all CodeCompanion events like other spinners
  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "CodeCompanion*",
    group = group,
    callback = function(request)
      update_display(request.match)
    end,
  })
end

-- Function that returns the current status for heirline
function M.status()
  if M.current_text ~= "" then
    -- Control animation speed (update every 100ms)
    local current_time = vim.loop.hrtime()
    if current_time - M.last_update_time > 100000000 then -- 100ms in nanoseconds
      M.spinner_index = (M.spinner_index % spinner_symbols_len) + 1
      M.last_update_time = current_time
    end
    return spinner_symbols[M.spinner_index] .. " " .. M.current_text
  else
    return ""
  end
end

--- Returns a heirline component configuration that can be directly added to heirline statusline.
--- @return table The heirline component configuration
function M.get_heirline_component()
  return {
    static = {
      current_text = "",
      spinner_index = 1,
      last_update_time = 0,
    },
    init = function(self)
      self.current_text = M.current_text -- Sync with module state
    end,
    update = {
      "User",
      pattern = "CodeCompanion*",
      callback = function(self, args)
        update_display(args.match)
        self.current_text = M.current_text -- Sync component state
        vim.cmd("redrawstatus")
      end,
    },
    condition = function(self)
      return self.current_text ~= ""
    end,
    provider = function(self)
      if self.current_text ~= "" then
        -- Control animation speed (update every 100ms)
        local current_time = vim.loop.hrtime()
        if current_time - self.last_update_time > 100000000 then -- 100ms in nanoseconds
          self.spinner_index = (self.spinner_index % spinner_symbols_len) + 1
          self.last_update_time = current_time
        end
        return spinner_symbols[self.spinner_index] .. " " .. self.current_text
      else
        return ""
      end
    end,
    -- Optional: Add highlighting
    hl = {
      fg = "green",
      bg = "NONE",
      bold = true,
    },
  }
end

return M
