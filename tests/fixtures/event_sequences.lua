-- Predefined event sequences for testing
local M = {}

-- Basic request lifecycle
M.basic_request = {
  "CodeCompanionRequestStarted",
  "CodeCompanionRequestStreaming",
  "CodeCompanionRequestFinished",
}

-- Tool execution lifecycle
M.tool_execution = {
  "CodeCompanionToolStarted",
  "CodeCompanionToolFinished",
  "CodeCompanionToolsFinished",
}

-- Complete chat session
M.full_chat_session = {
  "CodeCompanionChatOpened",
  "CodeCompanionRequestStarted",
  "CodeCompanionRequestStreaming",
  "CodeCompanionRequestFinished",
  "CodeCompanionToolStarted",
  "CodeCompanionToolFinished",
  "CodeCompanionToolsFinished",
  "CodeCompanionChatClosed",
}

-- Diff workflow
M.diff_workflow = {
  "CodeCompanionDiffAttached",
  "CodeCompanionDiffAccepted",
}

-- Diff rejection
M.diff_rejection = {
  "CodeCompanionDiffAttached",
  "CodeCompanionDiffRejected",
}

-- Multiple requests
M.multiple_requests = {
  "CodeCompanionRequestStarted",
  "CodeCompanionRequestStreaming",
  "CodeCompanionRequestFinished",
  "CodeCompanionRequestStarted",
  "CodeCompanionRequestStreaming",
  "CodeCompanionRequestFinished",
  "CodeCompanionRequestStarted",
  "CodeCompanionRequestStreaming",
  "CodeCompanionRequestFinished",
}

-- Interrupted workflow
M.interrupted_workflow = {
  "CodeCompanionRequestStarted",
  "CodeCompanionRequestStreaming",
  "CodeCompanionChatStopped",
}

-- Error conditions
M.error_conditions = {
  "CodeCompanionRequestFinished", -- Finish without start
  "CodeCompanionToolFinished", -- Tool finish without start
  "CodeCompanionToolsFinished", -- Tools finish without start
}

-- Rapid events (stress test)
M.rapid_events = {}
for i = 1, 50 do
  table.insert(M.rapid_events, "CodeCompanionRequestStarted")
  table.insert(M.rapid_events, "CodeCompanionRequestStreaming")
  table.insert(M.rapid_events, "CodeCompanionRequestFinished")
end

-- Complex workflow with all features
M.complex_workflow = {
  "CodeCompanionChatOpened",
  "CodeCompanionRequestStarted",
  "CodeCompanionRequestStreaming",
  "CodeCompanionToolStarted",
  "CodeCompanionToolFinished",
  "CodeCompanionToolsFinished",
  "CodeCompanionDiffAttached",
  "CodeCompanionDiffAccepted",
  "CodeCompanionRequestFinished",
  "CodeCompanionChatCleared",
  "CodeCompanionChatClosed",
}

-- Chat lifecycle variations
M.chat_lifecycle = {
  opened = "CodeCompanionChatOpened",
  closed = "CodeCompanionChatClosed",
  cleared = "CodeCompanionChatCleared",
  done = "CodeCompanionChatDone",
  stopped = "CodeCompanionChatStopped",
}

-- State transition tests
M.state_transitions = {
  -- IDLE → THINKING → RECEIVING → IDLE
  request_flow = {
    "CodeCompanionRequestStarted",
    "CodeCompanionRequestStreaming",
    "CodeCompanionRequestFinished",
  },

  -- IDLE → TOOLS_RUNNING → TOOLS_PROCESSING → IDLE
  tool_flow = {
    "CodeCompanionToolStarted",
    "CodeCompanionToolFinished",
    "CodeCompanionToolsFinished",
  },

  -- IDLE → DIFF_AWAITING → IDLE
  diff_flow = {
    "CodeCompanionDiffAttached",
    "CodeCompanionDiffAccepted",
  },
}

-- Timing-based sequences
M.timing_tests = {
  -- Events with specific timing requirements
  slow_request = {
    events = {
      "CodeCompanionRequestStarted",
      "CodeCompanionRequestStreaming",
      "CodeCompanionRequestFinished",
    },
    delays = { 0, 500, 1000 }, -- milliseconds
  },

  fast_tools = {
    events = {
      "CodeCompanionToolStarted",
      "CodeCompanionToolFinished",
      "CodeCompanionToolsFinished",
    },
    delays = { 0, 50, 100 },
  },
}

-- Edge cases
M.edge_cases = {
  -- Empty sequence
  empty = {},

  -- Single event
  single = { "CodeCompanionRequestStarted" },

  -- Duplicate events
  duplicates = {
    "CodeCompanionRequestStarted",
    "CodeCompanionRequestStarted",
    "CodeCompanionRequestFinished",
  },

  -- Out of order events
  out_of_order = {
    "CodeCompanionRequestFinished",
    "CodeCompanionRequestStarted",
    "CodeCompanionRequestStreaming",
  },

  -- Unknown events
  unknown_events = {
    "CodeCompanionRequestStarted",
    "UnknownEvent",
    "CodeCompanionRequestFinished",
  },
}

-- Performance test sequences
M.performance = {
  -- Large number of events
  high_volume = {},
  -- Complex state changes
  complex_state_changes = {},
  -- Memory intensive sequences
  memory_intensive = {},
}

-- Fill performance sequences
for i = 1, 1000 do
  table.insert(M.performance.high_volume, "CodeCompanionRequestStarted")
  table.insert(M.performance.high_volume, "CodeCompanionRequestStreaming")
  table.insert(M.performance.high_volume, "CodeCompanionRequestFinished")
end

-- Complex state changes
local complex_events = {
  "CodeCompanionChatOpened",
  "CodeCompanionRequestStarted",
  "CodeCompanionToolStarted",
  "CodeCompanionDiffAttached",
  "CodeCompanionRequestStreaming",
  "CodeCompanionToolFinished",
  "CodeCompanionDiffAccepted",
  "CodeCompanionToolsFinished",
  "CodeCompanionRequestFinished",
  "CodeCompanionChatClosed",
}

for i = 1, 100 do
  for _, event in ipairs(complex_events) do
    table.insert(M.performance.complex_state_changes, event)
  end
end

return M
