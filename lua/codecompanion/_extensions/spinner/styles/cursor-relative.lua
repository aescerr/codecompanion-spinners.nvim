--- @module codecompanion._extensions.spinner.styles.cursor-relative
local M = {}

local config = require("codecompanion._extensions.spinner.config")
local tracker = require("codecompanion._extensions.spinner.tracker")

local ns_id

local spinner_state = {
  timer = nil,
  win = nil,
  buf = nil,
  frame = 1,
}

local function create_spinner_window()
  if not ns_id then
    ns_id = vim.api.nvim_create_namespace("spinner")
  end
  local cursor_config = config.get()["cursor-relative"]
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })

  local win = vim.api.nvim_open_win(buf, false, {
    relative = "cursor",
    row = -1,
    col = 0,
    width = math.ceil(#cursor_config.text / 3), -- Approximate width based on text length
    height = 1,
    style = "minimal",
    focusable = false,
  })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { cursor_config.text })

  -- Set the dim highlight for the entire text
  vim.api.nvim_buf_set_extmark(buf, ns_id, 0, 0, {
    end_col = #cursor_config.text,
    hl_group = cursor_config.hl_dim_group,
    priority = vim.highlight.priorities.user - 1,
  })

  return buf, win, ns_id
end

function M.start_spinner()
  if spinner_state.timer then
    return
  end

  local buf, win = create_spinner_window()
  spinner_state.buf = buf
  spinner_state.win = win

  local cursor_config = config.get()["cursor-relative"]
  spinner_state.timer = vim.loop.new_timer()
  spinner_state.timer:start(
    0,
    cursor_config.interval,
    vim.schedule_wrap(function()
      if
        spinner_state.win == nil
        or spinner_state.buf == nil
        or not (vim.api.nvim_win_is_valid(spinner_state.win) and vim.api.nvim_buf_is_valid(spinner_state.buf))
      then
        M.stop_spinner()
        return
      end

      -- Update window position relative to cursor
      local ok = pcall(vim.api.nvim_win_set_config, spinner_state.win, {
        relative = "cursor",
        row = -1,
        col = 0,
      })

      -- If window update failed, stop the spinner
      if not ok then
        M.stop_spinner()
        return
      end
      vim.api.nvim_buf_clear_namespace(spinner_state.buf, ns_id, 0, -1)

      vim.api.nvim_buf_set_extmark(spinner_state.buf, ns_id, 0, 0, {
        end_col = #cursor_config.text,
        hl_group = cursor_config.hl_dim_group,
        priority = vim.highlight.priorities.user - 1,
      })

      -- Set animation highlight
      local hl_pos = cursor_config.hl_positions[spinner_state.frame]
      vim.api.nvim_buf_set_extmark(spinner_state.buf, ns_id, 0, hl_pos[1], {
        end_col = hl_pos[2],
        hl_group = cursor_config.hl_group,
        priority = vim.highlight.priorities.user + 1,
      })

      spinner_state.frame = (spinner_state.frame % #cursor_config.hl_positions) + 1
    end)
  )
end

function M.stop_spinner()
  if spinner_state.timer then
    spinner_state.timer:stop()
    spinner_state.timer:close()
    spinner_state.timer = nil
  end

  if spinner_state.buf then
    pcall(vim.api.nvim_buf_delete, spinner_state.buf, { force = true })
    spinner_state.buf = nil
  end
  -- Window will be closed automatically when buffer is deleted
  spinner_state.win = nil
  spinner_state.frame = 1

  -- Force redraw to ensure the window is closed visually
  vim.cmd("redraw")
end

--- The main render function called by the plugin's core.
--- @param new_state number The new state from the tracker.
--- @param _event string The raw event that triggered the state change.
function M.render(new_state, _event)
  if new_state ~= tracker.State.IDLE and not spinner_state.timer then
    M.start_spinner()
  elseif new_state == tracker.State.IDLE and spinner_state.timer then
    M.stop_spinner()
  end
end

--- One-time setup for this spinner style.
function M.setup()
  -- No specific setup needed for this renderer
end

return M
