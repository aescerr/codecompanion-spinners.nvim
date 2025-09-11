-- A rich notifier using vim.notify (enhanced by plugins like `snacks.nvim`).
--
-- This spinner is a "dumb" renderer. It receives state updates from the
-- central tracker and displays the appropriate notification based on the
-- plugin's configuration.
local M = {}

local config = require("codecompanion._extensions.spinner.config")
local tracker = require("codecompanion._extensions.spinner.tracker")

local NOTIFICATION_ID = "codecompanion_spinner"

local function show_notification(content, is_done, is_spinning)
	local config = require("codecompanion._extensions.spinner.config")
	local default_icon = config.get().default_icon

	local ok, _ = pcall(require, "snacks")
	if not ok then
		-- Fallback to default vim.notify if snacks is not available
		if is_spinning then
			vim.notify(string.format("%s %s", default_icon, content.message), "info", { title = "CodeCompanion" })
		else
			vim.notify(default_icon, "info", { title = "CodeCompanion" })
		end
		return
	end

	-- For snacks, include icon in the message for consistent display
	local display_icon = content.message:find("Thinking") and default_icon or content.icon
	local message
	if is_spinning then
		message = string.format("%s%s%s", display_icon, content.spacing, content.message)
	else
		message = string.format("%s%s%s", display_icon, content.spacing, content.message)
	end

	local opts = {
		id = NOTIFICATION_ID,
		title = " CodeCompanion",
		dismiss = false,
	}

	if is_done then
		opts.timeout = 2000
		opts.dismiss = true
		opts.icon = default_icon -- Use default icon for title when done
	elseif is_spinning then
		opts.timeout = 0
		opts.icon = display_icon -- Use appropriate icon for spinner animation
		opts.opts = function(notif)
			local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
			notif.icon = spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1] .. ""
		end
	else
		opts.timeout = 2000
		opts.dismiss = true
		opts.icon = display_icon
	end

	vim.notify(message, "info", opts)
end

--- The main render function called by the plugin's core.
--- @param new_state string The new state from the tracker.
--- @param event string The raw event that triggered the state change.
function M.render(new_state, event)
	if new_state == tracker.State.IDLE then
		local content = config.get_content_for_state("done")
		show_notification(content, true, false)
	else
		local content = config.get_content_for_state(new_state)
		show_notification(content, false, true)
	end

	-- Handle one-off notification events that don't have a persistent state
	local one_off_events = {
		["CodeCompanionDiffAccepted"] = "diff_accepted",
		["CodeCompanionDiffRejected"] = "diff_rejected",
		["CodeCompanionChatOpened"] = "chat_opened",
		["CodeCompanionChatHidden"] = "chat_hidden",
		["CodeCompanionChatClosed"] = "chat_closed",
		["CodeCompanionChatCleared"] = "cleared",
	}
	local state_key = one_off_events[event]
	if state_key then
		local content = config.get_content_for_state(state_key)
		show_notification(content, true, false)
	end
end

--- One-time setup for this spinner style.
function M.setup()
	-- Check for dependency
	local ok, _ = pcall(require, "snacks")
	if not ok then
		vim.notify(
			"Snacks spinner requires `snacks.nvim` plugin.",
			vim.log.levels.WARN,
			{ title = "CodeCompanion Spinners" }
		)
	end
end

return M
