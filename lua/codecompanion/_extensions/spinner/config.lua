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
		hl_group = "Title",
		hl_dim_group = "NonText",
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

--- Merges the user's options with the default configuration.
--- @param user_opts table The configuration table provided by the user.
function M.load(user_opts)
	user_opts = user_opts or {}
	-- Deep merge the content table, otherwise user would have to redefine all content
	local merged_content = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults.content), user_opts.content or {})
	local merged_opts = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), user_opts)
	merged_opts.content = merged_content
	M.options = merged_opts
end

--- Returns the currently active configuration table.
--- @return table
function M.get()
	return M.options
end

--- A helper function to get the content for a specific state.
--- @param state string The name of the state (e.g., "thinking").
--- @return table The content table for that state (e.g., { icon = "...", message = "..." }).
function M.get_content_for_state(state)
	return M.options.content[state] or {}
end

return M
