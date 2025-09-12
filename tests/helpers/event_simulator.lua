-- Event simulation utilities for testing
local M = {}

local codecompanion_mock = require("tests.mocks.codecompanion")

-- Simulate a single event
M.simulate_event = function(event_name, delay_ms)
  delay_ms = delay_ms or 0
  vim.defer_fn(function()
    vim.api.nvim_exec_autocmds("User", {
      pattern = event_name,
    })
  end, delay_ms)
end

-- Simulate a sequence of events
M.simulate_sequence = function(events, delay_between_ms)
  delay_between_ms = delay_between_ms or 10
  for i, event in ipairs(events) do
    M.simulate_event(event, delay_between_ms * (i - 1))
  end
end

-- Simulate common CodeCompanion workflows
M.simulate_workflow = function(workflow_name, options)
  options = options or {}
  local sequence = codecompanion_mock.sequences[workflow_name]

  if not sequence then
    error("Unknown workflow: " .. workflow_name)
  end

  M.simulate_sequence(sequence, options.delay_between or 10)
end

-- Simulate rapid events for stress testing
M.simulate_rapid_events = function(event_name, count, total_duration_ms)
  total_duration_ms = total_duration_ms or 100
  local delay_between = total_duration_ms / count

  for i = 1, count do
    M.simulate_event(event_name, delay_between * (i - 1))
  end
end

-- Simulate interrupted workflow
M.simulate_interrupted_workflow = function()
  -- Start a request
  M.simulate_event("CodeCompanionRequestStarted", 0)
  M.simulate_event("CodeCompanionRequestStreaming", 10)

  -- Interrupt with chat stop
  M.simulate_event("CodeCompanionChatStopped", 20)

  -- This should leave the system in a clean state
end

-- Simulate error conditions
M.simulate_error_conditions = function()
  -- Simulate events that might cause errors
  M.simulate_event("CodeCompanionRequestFinished", 0) -- Finish without start
  M.simulate_event("CodeCompanionToolFinished", 10) -- Tool finish without start
end

-- Wait for all simulated events to complete
M.wait_for_completion = function(timeout_ms)
  timeout_ms = timeout_ms or 1000
  vim.defer_fn(function() end, timeout_ms)
end

-- Event recording for verification
M.recorded_events = {}

M.start_recording = function()
  M.recorded_events = {}
  -- This would hook into the mock system to record events
end

M.stop_recording = function()
  return M.recorded_events
end

M.clear_recording = function()
  M.recorded_events = {}
end

-- Verify event sequence
M.verify_sequence = function(expected_events, actual_events)
  if #expected_events ~= #actual_events then
    return false, string.format("Event count mismatch: expected %d, got %d", #expected_events, #actual_events)
  end

  for i, expected in ipairs(expected_events) do
    if expected ~= actual_events[i] then
      return false, string.format("Event %d mismatch: expected '%s', got '%s'", i, expected, actual_events[i])
    end
  end

  return true
end

return M
