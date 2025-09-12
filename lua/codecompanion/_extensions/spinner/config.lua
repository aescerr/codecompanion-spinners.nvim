-- Configuration management for codecompanion-spinners.nvim
--
-- This module handles merging user-provided configuration with the
-- plugin's default settings.
local M = {}

-- The default configuration table.
-- Users can override any of these settings in their setup() call.
M.defaults = {
  -- The spinner style to use.
  -- Available options: "cursor-relative", "snacks", "fidget", "lualine", "native", "none"
  style = "cursor-relative",

  -- Default icon to show when spinners are idle (default: "")
  default_icon = "",

  -- A table mapping internal states to their display content (icons and messages).
  -- This allows users to customize the look and feel of the notifications.
  content = {
    -- General states
    thinking = { icon = "", message = "Thinking...", spacing = "  " },
    receiving = { icon = "", message = "Receiving...", spacing = "  " },
    done = { icon = "", message = "Done!", spacing = "  " },
    stopped = { icon = "", message = "Stopped", spacing = "  " },
    cleared = { icon = "", message = "Chat cleared", spacing = "  " },

    -- Tool-related states
    tools_started = { icon = "", message = "Running tools...", spacing = "  " },
    tools_finished = { icon = "⤷", message = "Processing tool output...", spacing = "  " },

    -- Diff-related states
    diff_attached = { icon = "", message = "Review changes", spacing = "  " },
    diff_accepted = { icon = "", message = "Change accepted", spacing = "  " },
    diff_rejected = { icon = "", message = "Change rejected", spacing = "  " },

    -- Chat-related states (primarily for notifiers like snacks)
    chat_ready = { icon = "", message = "Chat ready", spacing = "  " },
    chat_opened = { icon = "", message = "Chat opened", spacing = "  " },
    chat_hidden = { icon = "", message = "Chat hidden", spacing = "  " },
    chat_closed = { icon = "", message = "Chat closed", spacing = "  " },
  },

  -- Spinner-specific settings
  ["cursor-relative"] = {
    text = "",
    -- text = "",
    hl_positions = {
      { 0, 3 }, -- First circle
      { 3, 6 }, -- Second circle
      { 6, 9 }, -- Third circle
    },
    interval = 100,
    hl_group = "Cursor",
    hl_dim_group = "Comment",
  },
  fidget = {
    -- No specific options for now
  },
  snacks = {
    -- No specific options for now
  },

  native = {
    -- Configuration for the native window spinner
    done_timer = 500, -- ms to show the "done" message
    window = {
      -- All options supported by nvim_open_win can be configured here
      relative = "editor", -- "editor", "win", "cursor"
      width = 30, -- Window width
      height = 1, -- Window height
      row = nil, -- Row position (calculated if nil)
      col = nil, -- Column position (calculated if nil)
      style = "minimal", -- Window style
      border = "rounded", -- Border style: "none", "single", "double", "rounded", "solid", "shadow"
      title = "CodeCompanion", -- Window title
      title_pos = "center", -- Title position: "left", "center", "right"
      focusable = false, -- Whether window can be focused
      noautocmd = true, -- Disable autocmds for this window
    },
    win_options = {
      -- Additional window options using nvim_set_option_value
      -- Examples:
      -- winblend = 10,        -- Window transparency (0-100)
      -- winhighlight = "Normal:Normal,FloatBorder:Normal", -- Window highlighting
    },
  },
}

-- Holds the active configuration after merging defaults with user options.
M.options = {}

--- Simple deep merge implementation for testing compatibility
local function deep_merge(target, source)
  if type(target) ~= "table" or type(source) ~= "table" then
    return source or target
  end

  local result = {}
  -- Copy target
  for k, v in pairs(target) do
    result[k] = deep_merge({}, v)
  end
  -- Merge source
  for k, v in pairs(source) do
    if type(result[k]) == "table" and type(v) == "table" then
      result[k] = deep_merge(result[k], v)
    else
      result[k] = v
    end
  end
  return result
end

--- Merges the user's options with the default configuration.
--- @param user_opts table The configuration table provided by the user.
function M.load(user_opts)
  user_opts = user_opts or {}
  -- Start with defaults or current options
  local base = next(M.options) and M.options or M.defaults
  -- Deep merge the content table, otherwise user would have to redefine all content
  local merged_content = deep_merge(base.content, user_opts.content or {})
  local merged_opts = deep_merge(base, user_opts)
  merged_opts.content = merged_content

  -- Validate style, fall back to default if invalid
  if not M.validate({ style = merged_opts.style }) then
    merged_opts.style = M.defaults.style
  end

  M.options = merged_opts
end

--- Alias for load() for backward compatibility with tests
--- @param user_opts table The configuration table provided by the user.
function M.merge(user_opts)
  M.load(user_opts)
end

--- Returns the currently active configuration table.
--- @return table
function M.get()
  return M.options
end

--- A helper function to get the content for a specific state.
--- @param state string The name of the state (e.g., "thinking").
--- @return table|nil The content table for that state (e.g., { icon = "...", message = "..." }), or nil if state doesn't exist.
function M.get_content_for_state(state)
  return M.options.content[state]
end

--- Validates a configuration table.
--- @param cfg table The configuration to validate.
--- @return boolean True if valid, false otherwise.
function M.validate(cfg)
  if not cfg or type(cfg) ~= "table" then
    return false
  end

  -- Validate style
  local valid_styles = {
    "cursor-relative",
    "snacks",
    "fidget",
    "lualine",
    "heirline",
    "native",
    "none",
  }
  if cfg.style == nil then
    return false
  end
  local style_valid = false
  for _, valid_style in ipairs(valid_styles) do
    if cfg.style == valid_style then
      style_valid = true
      break
    end
  end
  if not style_valid then
    return false
  end

  -- Validate content structure
  if cfg.content and type(cfg.content) ~= "table" then
    return false
  end

  return true
end

--- Resets the configuration to defaults.
--- Useful for testing to ensure a clean state.
function M.reset()
  -- Simple deep copy implementation for testing
  local function deep_copy(obj)
    if type(obj) ~= "table" then
      return obj
    end
    local res = {}
    for k, v in pairs(obj) do
      res[k] = deep_copy(v)
    end
    return res
  end
  M.options = deep_copy(M.defaults)
end

return M
