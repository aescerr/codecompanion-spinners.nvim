-- Test environment setup and teardown
local M = {}

local codecompanion_mock = require("tests.mocks.codecompanion")
local neovim_mock = require("tests.mocks.neovim_api")

-- Setup test environment
M.setup = function()
  -- Mock global vim functions
  _G.vim = vim or {}
  for k, v in pairs(neovim_mock) do
    if k ~= "reset" then
      _G.vim[k] = v
    end
  end

  -- Setup CodeCompanion mocks
  codecompanion_mock.setup_global_mocks()

  -- Mock common Neovim modules
  M.mock_module("lualine")
  M.mock_module("heirline")
  M.mock_module("fidget")
  M.mock_module("snacks")

  -- Setup package path for local modules
  package.path = package.path .. ";./lua/?.lua;./tests/?.lua"

  print("🧪 Test environment setup complete")
end

-- Teardown test environment
M.teardown = function()
  -- Reset all mocks
  neovim_mock.reset()
  codecompanion_mock.reset()

  -- Clear any global state
  _G.codecompanion_current_context = nil
  _G.codecompanion_chat_metadata = nil

  print("🧹 Test environment teardown complete")
end

-- Mock a Lua module
M.mock_module = function(module_name)
  if not package.loaded[module_name] then
    local mock = {
      setup = function() end,
      -- Add other common methods as needed
    }
    if module_name == "fidget" then
      mock.progress = {
        handle_create = function()
          return { id = 1 }
        end,
        handle_update = function() end,
        handle_close = function() end,
      }
    elseif module_name == "snacks" then
      mock.notify = function() end
    end
    package.loaded[module_name] = mock
  end
end

-- Unmock a Lua module
M.unmock_module = function(module_name)
  package.loaded[module_name] = nil
end

-- Create a temporary buffer for testing
M.create_test_buffer = function(content)
  content = content or { "line 1", "line 2", "line 3" }
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
  return bufnr
end

-- Clean up test buffer
M.cleanup_test_buffer = function(bufnr)
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

-- Wait for async operations (mock implementation)
M.wait_for_async = function(timeout_ms)
  -- In test environment, async operations are synchronous
  -- This is just a placeholder for real async waiting
  timeout_ms = timeout_ms or 100
  vim.defer_fn(function() end, timeout_ms)
end

-- Assert helper for event sequences
M.assert_event_sequence = function(expected_events, actual_events)
  assert(
    #expected_events == #actual_events,
    string.format("Event count mismatch: expected %d, got %d", #expected_events, #actual_events)
  )

  for i, expected in ipairs(expected_events) do
    assert(
      expected == actual_events[i],
      string.format("Event %d mismatch: expected '%s', got '%s'", i, expected, actual_events[i])
    )
  end
end

-- Performance measurement helper
M.measure_performance = function(fn, iterations)
  iterations = iterations or 100
  local start_time = vim.loop.hrtime()

  for _i = 1, iterations do
    fn()
  end

  local end_time = vim.loop.hrtime()
  local total_time = (end_time - start_time) / 1000000 -- Convert to milliseconds

  return {
    total_time = total_time,
    average_time = total_time / iterations,
    iterations = iterations,
  }
end

return M
