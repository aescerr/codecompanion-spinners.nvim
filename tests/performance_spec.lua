-- Performance tests for CodeCompanion Spinners
local tracker = require("codecompanion._extensions.spinner.tracker")
local config = require("codecompanion._extensions.spinner.config")
local test_env = require("tests.helpers.test_env")

describe("Performance Tests", function()
  before_each(function()
    config.reset()
    tracker.reset()
    tracker.setup(function() end)
  end)

  describe("Event Processing Performance", function()
    it("should handle rapid events efficiently", function()
      local start_time = vim.loop.hrtime()

      -- Simulate 100 rapid events
      for i = 1, 100 do
        tracker.handle_event("CodeCompanionRequestStarted")
        tracker.handle_event("CodeCompanionRequestFinished")
      end

      local end_time = vim.loop.hrtime()
      local total_time = (end_time - start_time) / 1000000 -- Convert to milliseconds

      -- Should complete in reasonable time (less than 100ms for 200 events)
      assert.is_true(total_time < 100, string.format("Took too long: %f ms", total_time))
    end)

    it("should handle complex event sequences", function()
      local events = {
        "CodeCompanionChatOpened",
        "CodeCompanionRequestStarted",
        "CodeCompanionRequestStreaming",
        "CodeCompanionToolStarted",
        "CodeCompanionToolFinished",
        "CodeCompanionToolsFinished",
        "CodeCompanionDiffAttached",
        "CodeCompanionDiffAccepted",
        "CodeCompanionRequestFinished",
        "CodeCompanionChatClosed"
      }

      local start_time = vim.loop.hrtime()

      -- Run complex sequence 50 times
      for i = 1, 50 do
        for _, event in ipairs(events) do
          tracker.handle_event(event)
        end
      end

      local end_time = vim.loop.hrtime()
      local total_time = (end_time - start_time) / 1000000 -- Convert to milliseconds

      -- Should complete in reasonable time
      assert.is_true(total_time < 500, string.format("Complex sequence took too long: %f ms", total_time))
    end)
  end)

  describe("Configuration Performance", function()
    it("should handle config merging efficiently", function()
      local large_config = {
        content = {}
      }

      -- Create a large config with many entries
      for i = 1, 100 do
        large_config.content["state_" .. i] = {
          icon = "icon" .. i,
          message = "Message " .. i,
          spacing = " "
        }
      end

      local start_time = vim.loop.hrtime()

      -- Merge large config 10 times
      for i = 1, 10 do
        config.merge(large_config)
      end

      local end_time = vim.loop.hrtime()
      local total_time = (end_time - start_time) / 1000000 -- Convert to milliseconds

      assert.is_true(total_time < 100, string.format("Config merging took too long: %f ms", total_time))
    end)

    it("should handle config validation efficiently", function()
      local configs = {}

      -- Create 50 different configs
      for i = 1, 50 do
        configs[i] = {
          style = i % 2 == 0 and "snacks" or "cursor-relative",
          default_icon = "icon" .. i,
          content = {
            thinking = { message = "Message " .. i }
          }
        }
      end

      local start_time = vim.loop.hrtime()

      -- Validate all configs
      for _, cfg in ipairs(configs) do
        config.validate(cfg)
      end

      local end_time = vim.loop.hrtime()
      local total_time = (end_time - start_time) / 1000000 -- Convert to milliseconds

      assert.is_true(total_time < 50, string.format("Config validation took too long: %f ms", total_time))
    end)
  end)

  describe("Spinner Rendering Performance", function()
    it("should render spinners efficiently", function()
      package.loaded["codecompanion._extensions.spinner.styles.cursor-relative"] = nil
      package.loaded["codecompanion._extensions.spinner.styles.snacks"] = nil
      local cursor_relative = require("codecompanion._extensions.spinner.styles.cursor-relative")
      local snacks = require("codecompanion._extensions.spinner.styles.snacks")

      local start_time = vim.loop.hrtime()

      -- Render 1000 times with different spinners
      for i = 1, 1000 do
        cursor_relative.render(2, "CodeCompanionRequestStarted")
        snacks.render(3, "CodeCompanionRequestStreaming")
      end

      local end_time = vim.loop.hrtime()
      local total_time = (end_time - start_time) / 1000000 -- Convert to milliseconds

      assert.is_true(total_time < 200, string.format("Spinner rendering took too long: %f ms", total_time))
    end)

    it("should handle statusline component rendering", function()
      package.loaded["codecompanion._extensions.spinner.styles.lualine"] = nil
      package.loaded["codecompanion._extensions.spinner.styles.heirline"] = nil
      local lualine = require("codecompanion._extensions.spinner.styles.lualine")
      local heirline = require("codecompanion._extensions.spinner.styles.heirline")

      -- Setup components
      lualine.setup()
      heirline.setup()

      local start_time = vim.loop.hrtime()

      -- Render components 500 times each
      for i = 1, 500 do
        local lualine_component = lualine.get_lualine_component()
        local heirline_component = heirline.get_heirline_component()
        -- Initialize heirline component
        if heirline_component.init then heirline_component.init(heirline_component) end
        -- Simulate calling the component functions
        if lualine_component[1] then lualine_component[1]() end
        if heirline_component.provider then heirline_component.provider(heirline_component) end
      end

      local end_time = vim.loop.hrtime()
      local total_time = (end_time - start_time) / 1000000 -- Convert to milliseconds

      assert.is_true(total_time < 150, string.format("Component rendering took too long: %f ms", total_time))
    end)
  end)

  describe("Memory Usage", function()
    it("should not leak memory on repeated operations", function()
      local initial_memory = collectgarbage("count")

      -- Perform many operations
      for i = 1, 1000 do
        tracker.handle_event("CodeCompanionRequestStarted")
        tracker.handle_event("CodeCompanionRequestFinished")
        config.get()
        config.get_content_for_state("thinking")
      end

      collectgarbage("collect")
      local final_memory = collectgarbage("count")

      local memory_increase = final_memory - initial_memory
      -- Allow some memory increase but not excessive (less than 1MB)
      assert.is_true(memory_increase < 1000, string.format("Memory leak detected: %f KB increase", memory_increase))
    end)
  end)

  describe("Concurrent Operations", function()
    it("should handle concurrent event processing", function()
      local start_time = vim.loop.hrtime()

      -- Simulate concurrent-like operations
      for i = 1, 100 do
        -- Mix different types of operations
        tracker.handle_event("CodeCompanionRequestStarted")
        config.merge({ style = "snacks" })
        tracker.handle_event("CodeCompanionRequestFinished")
        config.reset()
      end

      local end_time = vim.loop.hrtime()
      local total_time = (end_time - start_time) / 1000000 -- Convert to milliseconds

      assert.is_true(total_time < 200, string.format("Concurrent operations took too long: %f ms", total_time))
    end)
  end)

  describe("Large Scale Operations", function()
    it("should handle large numbers of state changes", function()
      local start_time = vim.loop.hrtime()

      -- Create a very large number of state changes
      for i = 1, 10000 do
        tracker.handle_event("CodeCompanionRequestStarted")
        tracker.handle_event("CodeCompanionRequestFinished")
      end

      local end_time = vim.loop.hrtime()
      local total_time = (end_time - start_time) / 1000000 -- Convert to milliseconds

      -- Should complete within reasonable time (less than 1 second for 20k operations)
      assert.is_true(total_time < 1000, string.format("Large scale operations took too long: %f ms", total_time))
    end)
  end)
end)