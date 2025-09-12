-- Mock CodeCompanion for testing
local M = {}

-- Mock CodeCompanion global state
M._current_context = "/mock/path/test_file.lua"
M._chat_metadata = {
  [1] = { -- Mock buffer 1
    tokens = 150,
    cycles = 3,
    model = "gpt-4",
  },
}

-- Mock CodeCompanion events
M.events = {
  -- Request events
  "CodeCompanionRequestStarted",
  "CodeCompanionRequestStreaming",
  "CodeCompanionRequestFinished",

  -- Tool events
  "CodeCompanionToolStarted",
  "CodeCompanionToolFinished",
  "CodeCompanionToolsFinished",

  -- Chat events
  "CodeCompanionChatOpened",
  "CodeCompanionChatClosed",
  "CodeCompanionChatCleared",
  "CodeCompanionChatDone",
  "CodeCompanionChatStopped",

  -- Diff events
  "CodeCompanionDiffAttached",
  "CodeCompanionDiffAccepted",
  "CodeCompanionDiffRejected",
}

-- Event simulation utilities
M.simulate_event = function(event_name, delay)
  delay = delay or 0
  vim.defer_fn(function()
    vim.api.nvim_exec_autocmds("User", {
      pattern = event_name,
    })
  end, delay)
end

M.simulate_event_sequence = function(events, base_delay)
  base_delay = base_delay or 10
  for i, event in ipairs(events) do
    M.simulate_event(event, base_delay * i)
  end
end

-- Predefined event sequences for common scenarios
M.sequences = {
  -- Basic request flow
  basic_request = {
    "CodeCompanionRequestStarted",
    "CodeCompanionRequestStreaming",
    "CodeCompanionRequestFinished",
  },

  -- Tool execution flow
  tool_execution = {
    "CodeCompanionToolStarted",
    "CodeCompanionToolFinished",
    "CodeCompanionToolsFinished",
  },

  -- Complete workflow
  full_workflow = {
    "CodeCompanionChatOpened",
    "CodeCompanionRequestStarted",
    "CodeCompanionRequestStreaming",
    "CodeCompanionToolStarted",
    "CodeCompanionToolFinished",
    "CodeCompanionToolsFinished",
    "CodeCompanionRequestFinished",
    "CodeCompanionChatClosed",
  },

  -- Diff workflow
  diff_workflow = {
    "CodeCompanionDiffAttached",
    "CodeCompanionDiffAccepted",
  },

  -- Error scenarios
  interrupted_request = {
    "CodeCompanionRequestStarted",
    "CodeCompanionRequestStreaming",
    "CodeCompanionChatStopped",
  },

  -- Rapid events
  rapid_events = {
    "CodeCompanionRequestStarted",
    "CodeCompanionRequestStreaming",
    "CodeCompanionRequestFinished",
    "CodeCompanionRequestStarted",
    "CodeCompanionRequestStreaming",
    "CodeCompanionRequestFinished",
  },
}

-- Mock CodeCompanion global variables
M.setup_global_mocks = function()
  _G.codecompanion_current_context = M._current_context
  _G.codecompanion_chat_metadata = M._chat_metadata
end

-- Mock plugin loading
M.mock_plugin_loaded = function(plugin_name)
  if not package.loaded[plugin_name] then
    package.loaded[plugin_name] = true
  end
end

-- Mock plugin unloading
M.mock_plugin_not_loaded = function(plugin_name)
  package.loaded[plugin_name] = nil
end

-- Reset mock state
M.reset = function()
  M._current_context = "/mock/path/test_file.lua"
  M._chat_metadata = {
    [1] = {
      tokens = 150,
      cycles = 3,
      model = "gpt-4",
    },
  }
end

return M
