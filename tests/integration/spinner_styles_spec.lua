describe("Spinner Styles Integration", function()
  local config = require("codecompanion._extensions.spinner.config")

  before_each(function()
    config.reset()
  end)

  describe("Spinner Style Loading", function()
    it("should load cursor-relative style without errors", function()
      local spinner = require("codecompanion._extensions.spinner.styles.cursor-relative")
      assert.is_table(spinner)
      assert.is_function(spinner.setup)
      assert.is_function(spinner.render)
    end)

    it("should load snacks style without errors", function()
      local spinner = require("codecompanion._extensions.spinner.styles.snacks")
      assert.is_table(spinner)
      assert.is_function(spinner.setup)
      assert.is_function(spinner.render)
    end)

    it("should load fidget style without errors", function()
      local spinner = require("codecompanion._extensions.spinner.styles.fidget")
      assert.is_table(spinner)
      assert.is_function(spinner.setup)
      assert.is_function(spinner.render)
    end)

    it("should load native style without errors", function()
      local spinner = require("codecompanion._extensions.spinner.styles.native")
      assert.is_table(spinner)
      assert.is_function(spinner.setup)
      assert.is_function(spinner.render)
    end)

    it("should load lualine style without errors", function()
      local spinner = require("codecompanion._extensions.spinner.styles.lualine")
      assert.is_table(spinner)
      assert.is_function(spinner.setup)
      assert.is_function(spinner.get_lualine_component)
    end)

    it("should load heirline style without errors", function()
      local spinner = require("codecompanion._extensions.spinner.styles.heirline")
      assert.is_table(spinner)
      assert.is_function(spinner.setup)
      assert.is_function(spinner.get_heirline_component)
    end)
  end)

  describe("Spinner Style Setup", function()
    it("should setup cursor-relative without errors", function()
      local spinner = require("codecompanion._extensions.spinner.styles.cursor-relative")
      assert.has_no.errors(function() spinner.setup() end)
    end)

    it("should setup snacks without errors", function()
      local spinner = require("codecompanion._extensions.spinner.styles.snacks")
      assert.has_no.errors(function() spinner.setup() end)
    end)

    it("should setup lualine without errors", function()
      local spinner = require("codecompanion._extensions.spinner.styles.lualine")
      assert.has_no.errors(function() spinner.setup() end)
    end)

    it("should setup heirline without errors", function()
      local spinner = require("codecompanion._extensions.spinner.styles.heirline")
      assert.has_no.errors(function() spinner.setup() end)
    end)

    it("should handle setup with missing dependencies", function()
      -- Mock missing dependency
      local original_lualine = package.loaded.lualine
      package.loaded.lualine = nil

      local lualine = require("codecompanion._extensions.spinner.styles.lualine")
      assert.has_no.errors(function() lualine.setup() end)

      -- Restore
      package.loaded.lualine = original_lualine
    end)
  end)

  describe("Spinner Style Interface", function()
    it("should have consistent interface across styles", function()
      local styles = {
        "cursor-relative",
        "snacks",
        "fidget",
        "native"
      }

      for _, style in ipairs(styles) do
        local spinner = require("codecompanion._extensions.spinner.styles." .. style)
        assert.is_function(spinner.setup)
        assert.is_function(spinner.render, "Style " .. style .. " should have render function")
      end
    end)

    it("should handle render calls without errors", function()
      local tracker = require("codecompanion._extensions.spinner.tracker")
      local styles = {
        "cursor-relative",
        "snacks",
        "native"
      }

      for _, style in ipairs(styles) do
        local spinner = require("codecompanion._extensions.spinner.styles." .. style)
        assert.has_no.errors(function()
          spinner.render(tracker.State.THINKING, "CodeCompanionRequestStarted")
        end)
      end
    end)

    it("should handle render with invalid parameters", function()
      local cursor_relative = require("codecompanion._extensions.spinner.styles.cursor-relative")
      assert.has_no.errors(function()
        cursor_relative.render(nil, nil)
        cursor_relative.render("", "")
        cursor_relative.render("invalid_state", "invalid_event")
      end)
    end)
  end)

  describe("Statusline Components", function()
    it("should create lualine component without errors", function()
      local lualine = require("codecompanion._extensions.spinner.styles.lualine")
      assert.has_no.errors(function()
        local component = lualine.get_lualine_component()
        assert.is_table(component)
        assert.is_function(component[1]) -- First element should be a function
      end)
    end)

    it("should create heirline component without errors", function()
      local heirline = require("codecompanion._extensions.spinner.styles.heirline")
      assert.has_no.errors(function()
        local component = heirline.get_heirline_component()
        assert.is_table(component)
        assert.is_function(component.provider)
      end)
    end)

    it("should handle component creation with missing dependencies", function()
      -- Mock missing lualine
      local original_lualine = package.loaded.lualine
      package.loaded.lualine = nil

      local lualine = require("codecompanion._extensions.spinner.styles.lualine")
      assert.has_no.errors(function()
        local component = lualine.get_lualine_component()
        assert.is_table(component)
      end)

      -- Restore
      package.loaded.lualine = original_lualine
    end)
  end)

  describe("Event Handling Integration", function()
    it("should handle CodeCompanion events through render", function()
      local cursor_relative = require("codecompanion._extensions.spinner.styles.cursor-relative")

      assert.has_no.errors(function()
        cursor_relative.render("thinking", "CodeCompanionRequestStarted")
        cursor_relative.render("receiving", "CodeCompanionRequestStreaming")
        cursor_relative.render("done", "CodeCompanionRequestFinished")
      end)
    end)

    it("should handle tool events", function()
      local tracker = require("codecompanion._extensions.spinner.tracker")
      local snacks = require("codecompanion._extensions.spinner.styles.snacks")

      assert.has_no.errors(function()
        snacks.render(tracker.State.TOOLS_RUNNING, "CodeCompanionToolStarted")
        snacks.render(tracker.State.TOOLS_PROCESSING, "CodeCompanionToolFinished")
      end)
    end)

    it("should handle diff events", function()
      local tracker = require("codecompanion._extensions.spinner.tracker")
      local native = require("codecompanion._extensions.spinner.styles.native")

      assert.has_no.errors(function()
        native.render(tracker.State.DIFF_AWAITING, "CodeCompanionDiffAttached")
        native.render(tracker.State.IDLE, "CodeCompanionDiffAccepted")
      end)
    end)
  end)

  describe("Configuration Integration", function()
    it("should use config values in render", function()
      config.merge({
        default_icon = "🤖",
        content = {
          thinking = { message = "Custom thinking message" }
        }
      })

      local snacks = require("codecompanion._extensions.spinner.styles.snacks")
      assert.has_no.errors(function()
        snacks.render(2, "CodeCompanionRequestStarted")
      end)
    end)

    it("should handle style-specific config", function()
      config.merge({
        ["cursor-relative"] = {
          interval = 200
        }
      })

      local cursor_relative = require("codecompanion._extensions.spinner.styles.cursor-relative")
      assert.has_no.errors(function()
        cursor_relative.render("thinking", "CodeCompanionRequestStarted")
      end)
    end)
  end)

  describe("Error Handling", function()
    it("should handle render with nil config", function()
      local original_get = config.get
      config.get = function() return nil end

      local snacks = require("codecompanion._extensions.spinner.styles.snacks")
      assert.has_no.errors(function()
        snacks.render("thinking", "CodeCompanionRequestStarted")
      end)

      -- Restore
      config.get = original_get
    end)

    it("should handle render with invalid state", function()
      local cursor_relative = require("codecompanion._extensions.spinner.styles.cursor-relative")
      assert.has_no.errors(function()
        cursor_relative.render(999, "CodeCompanionRequestStarted")
      end)
    end)
  end)
end)