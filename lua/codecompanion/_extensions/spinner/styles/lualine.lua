-- A spinner that provides a component for lualine.
--
-- NOTE: This spinner is currently not working and is disabled.
-- This module doesn't render anything on its own. Instead, it maintains a
-- state string that can be pulled by a lualine component function.
local M = {}

local config = require("codecompanion._extensions.spinner.config")
local tracker = require("codecompanion._extensions.spinner.tracker")

-- The text to be displayed in the lualine component.
M.status_text = ""

-- Track whether the CodeCompanion chat panel is currently open
M.is_chat_open = false

--- Returns the current status text for the lualine component.
--- @return string
function M.get_status()
    return M.status_text
end

--- Returns a lualine component configuration that can be directly added to lualine sections.
--- This provides a convenient way to integrate the spinner into lualine without manual configuration.
--- Only shows content when CodeCompanion chat is open and there's an active request.
--- @return table The lualine component configuration
function M.get_lualine_component()
    return function()
        local status = M.get_status()
        -- Only return status if chat is open and there's content to show
        if M.is_chat_open and status ~= "" then
            return status
        end
        -- Return empty string when chat is closed or idle
        return ""
    end
end

--- The main render function called by the plugin's core.
--- @param new_state string The new state from the tracker.
--- @param event string The raw event that triggered the state change.
function M.render(new_state, event)
    -- Track chat state based on events
    if event == "CodeCompanionChatOpened" then
        M.is_chat_open = true
    elseif event == "CodeCompanionChatClosed" or event == "CodeCompanionChatHidden" then
        M.is_chat_open = false
        -- Clear status when chat is closed/hidden
        M.status_text = ""
        vim.cmd("redrawstatus")
        return
    end

    local text = ""

    -- Only show content if chat is open
    if M.is_chat_open then
        if new_state ~= tracker.State.IDLE then
            -- For persistent states, show the message.
            local content = config.get_content_for_state(new_state)
            local default_icon = config.get().default_icon
            local display_icon = content.message:find("Thinking") and default_icon or content.icon
            text = string.format("%s%s%s", display_icon, content.spacing, content.message)
        else
            -- When idle, check if the event was a final one-off event.
            local final_event_content = {
                ["CodeCompanionChatDone"] = "done",
                ["CodeCompanionChatStopped"] = "stopped",
            }
            local state_key = final_event_content[event]
            if state_key then
                local content = config.get_content_for_state(state_key)
                local default_icon = config.get().default_icon
                local display_icon = content.message:find("Thinking") and default_icon or content.icon
                text = string.format("%s%s%s", display_icon, content.spacing, content.message)
            end
        end
    end

    M.status_text = text

    -- One-off events can also be shown temporarily (only if chat is open).
    if M.is_chat_open then
        local one_off_events = {
            ["CodeCompanionDiffAccepted"] = "diff_accepted",
            ["CodeCompanionDiffRejected"] = "diff_rejected",
            ["CodeCompanionChatCleared"] = "cleared",
        }
        local one_off_key = one_off_events[event]
        if one_off_key then
            local content = config.get_content_for_state(one_off_key)
            local default_icon = config.get().default_icon
            local display_icon = content.message:find("Thinking") and default_icon or content.icon
            M.status_text = string.format("%s%s%s", display_icon, content.spacing, content.message)
        end
    end

    -- Lualine needs to be refreshed manually.
    -- We only do this if the status text has changed.
    vim.cmd("redrawstatus")
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
