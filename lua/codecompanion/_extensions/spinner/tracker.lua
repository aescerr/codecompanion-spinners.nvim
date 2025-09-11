-- Central state tracker for codecompanion.nvim events
--
-- This module is the core of the plugin. It listens to all relevant
-- CodeCompanion events and maintains a simple state machine. When the state
-- changes, it notifies the active spinner via a callback.
local M = {}

-- An enum-like table for the possible states.
-- This provides a clear contract between the tracker and the renderers.
M.State = {
    IDLE = "idle",
    THINKING = "thinking",
    RECEIVING = "receiving",
    TOOLS_RUNNING = "tools_started",
    TOOLS_PROCESSING = "tools_finished",
    DIFF_AWAITING = "diff_attached",
}

-- Internal state counters
local state = {
    request_count = 0,
    tools_count = 0,
    diff_count = 0,
    is_streaming = false,
}

-- The callback to be fired on state change.
local on_state_change_callback = nil

--- Determines the current state based on the internal counters.
--- @return string The current state from M.State
local function get_current_state()
    if state.diff_count > 0 then
        return M.State.DIFF_AWAITING
    end
    if state.tools_count > 0 then
        return M.State.TOOLS_RUNNING
    end
    if state.request_count > 0 then
        if state.is_streaming then
            return M.State.RECEIVING
        end
        return M.State.THINKING
    end
    return M.State.IDLE
end

--- The main event handler for all CodeCompanion user events.
--- @param args table The arguments provided by the autocmd.
local function handle_event(args)
    local was_active = (state.request_count > 0) or (state.tools_count > 0) or (state.diff_count > 0)
    local previous_state = get_current_state()

    -- Update state counters based on the event
    local event = args.match
    if event == "CodeCompanionRequestStarted" then
        state.request_count = state.request_count + 1
    elseif event == "CodeCompanionRequestStreaming" then
        state.is_streaming = true
    elseif event == "CodeCompanionRequestFinished" then
        state.request_count = math.max(0, state.request_count - 1)
        state.is_streaming = false
    elseif event == "CodeCompanionToolStarted" then
        state.tools_count = state.tools_count + 1
    elseif event == "CodeCompanionToolFinished" then
        state.tools_count = math.max(0, state.tools_count - 1)
    elseif event == "CodeCompanionToolsFinished" then -- A flush event
        state.tools_count = 0
    elseif event == "CodeCompanionDiffAttached" then
        state.diff_count = state.diff_count + 1
    elseif event == "CodeCompanionDiffDetached" then
        state.diff_count = math.max(0, state.diff_count - 1)
    elseif event == "CodeCompanionChatDone" or event == "CodeCompanionChatStopped" then
        -- Force reset on chat completion
        state.request_count = 0
        state.tools_count = 0
        state.diff_count = 0
        state.is_streaming = false
    end

    local current_state = get_current_state()

    -- If the state has changed, notify the listener.
    if current_state ~= previous_state then
        on_state_change_callback(current_state, event)
    end
end

--- Sets up the tracker and registers the autocommands.
--- @param callback function The function to call when the state changes.
function M.setup(callback)
    if not callback then
        vim.notify("codecompanion-spinners: Tracker setup without a callback!", vim.log.levels.ERROR)
        return
    end
    on_state_change_callback = callback

    local events = {
        "CodeCompanionRequestStarted",
        "CodeCompanionRequestStreaming",
        "CodeCompanionRequestFinished",
        "CodeCompanionToolStarted",
        "CodeCompanionToolFinished",
        "CodeCompanionToolsFinished",
        "CodeCompanionDiffAttached",
        "CodeCompanionDiffDetached",
        "CodeCompanionChatDone",
        "CodeCompanionChatStopped",
    }

    local group = vim.api.nvim_create_augroup("CodeCompanionSpinnersTracker", { clear = true })
    vim.api.nvim_create_autocmd("User", {
        pattern = events,
        group = group,
        callback = function(args)
            pcall(handle_event, args)
        end,
    })
end

return M