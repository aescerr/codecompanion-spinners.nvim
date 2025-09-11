-- A complete notifier using `fidget.nvim`.
--
-- This spinner receives state updates from the central tracker and displays
-- both persistent progress and one-off notifications in the fidget window.
local M = {}

local config = require("codecompanion._extensions.spinner.config")
local tracker = require("codecompanion._extensions.spinner.tracker")

-- The handle for the persistent progress notification.
local progress_handle = nil

---Shows a one-off notification that is immediately marked as done.
---@param content table The content to display (icon and message).
local function show_one_off_notification(content)
	local has_fidget, fidget = pcall(require, "fidget")
	if not has_fidget then
		return
	end

	local config = require("codecompanion._extensions.spinner.config")
	local default_icon = config.get().default_icon
	local display_icon = content.message:find("Thinking") and default_icon or content.icon

	local handle = fidget.progress.handle.create({
		title = "",
		message = string.format("%s%s%s", display_icon, content.spacing, content.message),
		lsp_client = { name = "CodeCompanion" },
	})
	if handle then
		handle:finish()
	end
end

--- The main render function called by the plugin's core.
--- @param new_state string The new state from the tracker.
--- @param event string The raw event that triggered the state change.
function M.render(new_state, event)
	local has_fidget, fidget = pcall(require, "fidget")
	if not has_fidget then
		return
	end

	-- Handle persistent states
	if new_state == tracker.State.IDLE then
		if progress_handle then
			local config_module = require("codecompanion._extensions.spinner.config")
			local default_icon = config_module.get().default_icon
			progress_handle.message = default_icon
			progress_handle:finish()
			progress_handle = nil
		end
	else
		-- If a request is active, create or update the progress handle.
		local content = config.get_content_for_state(new_state)
		local config_module = require("codecompanion._extensions.spinner.config")
		local default_icon = config_module.get().default_icon
		local display_icon = content.message:find("Thinking") and default_icon or content.icon
		if not progress_handle then
			progress_handle = fidget.progress.handle.create({
				title = "",
				message = string.format("%s%s%s", display_icon, content.spacing, content.message),
				lsp_client = { name = "CodeCompanion" },
			})
		else
			progress_handle.message = string.format("%s%s%s", display_icon, content.spacing, content.message)
		end
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
		show_one_off_notification(content)
	end
end

--- One-time setup for this spinner style.
function M.setup()
	-- Check for dependency
	local ok, _ = pcall(require, "fidget")
	if not ok then
		vim.notify(
			"Fidget spinner requires `fidget.nvim` plugin.",
			vim.log.levels.WARN,
			{ title = "CodeCompanion Spinners" }
		)
	end
end

return M
