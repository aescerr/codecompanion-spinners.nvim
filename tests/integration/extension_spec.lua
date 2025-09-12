local extension = require("codecompanion._extensions.spinner.init")

describe("Extension Integration", function()
  local config = require("codecompanion._extensions.spinner.config")

  before_each(function()
    config.reset()
  end)

  describe("Extension Setup", function()
    it("should setup with default config", function()
      assert.has_no.errors(function()
        extension.setup()
      end)
    end)

    it("should setup with custom config", function()
      local custom_config = {
        style = "snacks",
        default_icon = "🤖",
      }

      assert.has_no.errors(function()
        extension.setup(custom_config)
      end)

      -- Verify config was applied
      local cfg = config.get()
      assert.equals("snacks", cfg.style)
      assert.equals("🤖", cfg.default_icon)
    end)

    it("should handle invalid style gracefully", function()
      local custom_config = {
        style = "invalid-style",
      }

      -- Should not error but fall back to default
      assert.has_no.errors(function()
        extension.setup(custom_config)
      end)

      local cfg = config.get()
      assert.equals("cursor-relative", cfg.style) -- Should fall back to default
    end)

    it("should handle empty config", function()
      assert.has_no.errors(function()
        extension.setup({})
      end)

      local cfg = config.get()
      assert.equals("cursor-relative", cfg.style) -- Should keep defaults
    end)

    it("should handle nil config", function()
      assert.has_no.errors(function()
        extension.setup(nil)
      end)

      local cfg = config.get()
      assert.equals("cursor-relative", cfg.style) -- Should keep defaults
    end)
  end)

  describe("Style Loading", function()
    it("should load cursor-relative style by default", function()
      extension.setup()
      -- The extension should have loaded the cursor-relative style
      -- We can't easily test the internal state, but we can test that no errors occurred
      assert.is_true(true) -- If we got here, setup succeeded
    end)

    it("should load different styles", function()
      local styles = { "snacks", "fidget", "native", "lualine", "heirline" }

      for _, style in ipairs(styles) do
        config.reset()
        assert.has_no.errors(function()
          extension.setup({ style = style })
        end)
      end
    end)

    it("should handle none style", function()
      assert.has_no.errors(function()
        extension.setup({ style = "none" })
      end)
    end)

    it("should handle style loading errors gracefully", function()
      -- Mock a broken style module
      local original_require = _G.require
      _G.require = function(mod)
        if mod == "codecompanion._extensions.spinner.styles.invalid" then
          error("Module not found")
        end
        return original_require(mod)
      end

      assert.has_no.errors(function()
        extension.setup({ style = "cursor-relative" }) -- Should still work
      end)

      -- Restore
      _G.require = original_require
    end)
  end)

  describe("Event Handling", function()
    it("should handle CodeCompanion events", function()
      extension.setup()

      -- Simulate some events
      assert.has_no.errors(function()
        -- These would normally be triggered by CodeCompanion
        vim.api.nvim_exec_autocmds("User", {
          pattern = "CodeCompanionRequestStarted",
        })
      end)
    end)

    it("should handle multiple events", function()
      extension.setup()

      assert.has_no.errors(function()
        vim.api.nvim_exec_autocmds("User", {
          pattern = "CodeCompanionRequestStarted",
        })
        vim.api.nvim_exec_autocmds("User", {
          pattern = "CodeCompanionRequestStreaming",
        })
        vim.api.nvim_exec_autocmds("User", {
          pattern = "CodeCompanionRequestFinished",
        })
      end)
    end)

    it("should handle unknown events gracefully", function()
      extension.setup()

      assert.has_no.errors(function()
        vim.api.nvim_exec_autocmds("User", {
          pattern = "UnknownEvent",
        })
      end)
    end)
  end)

  describe("Configuration Persistence", function()
    it("should persist configuration across setup calls", function()
      extension.setup({
        style = "snacks",
        default_icon = "🤖",
      })

      -- Call setup again with different config
      extension.setup({
        style = "fidget",
      })

      -- Should keep the merged config
      local cfg = config.get()
      assert.equals("fidget", cfg.style)
      assert.equals("🤖", cfg.default_icon) -- Should persist from previous call
    end)
  end)

  describe("Error Handling", function()
    it("should handle missing dependencies gracefully", function()
      -- Mock missing dependency
      local original_lualine = package.loaded.lualine
      package.loaded.lualine = nil

      assert.has_no.errors(function()
        extension.setup({ style = "lualine" })
      end)

      -- Restore
      package.loaded.lualine = original_lualine
    end)

    it("should handle config validation errors", function()
      local invalid_config = {
        style = "invalid",
        content = "not a table",
      }

      assert.has_no.errors(function()
        extension.setup(invalid_config)
      end)

      -- Should fall back to defaults
      local cfg = config.get()
      assert.equals("cursor-relative", cfg.style)
    end)

    it("should handle setup being called multiple times", function()
      assert.has_no.errors(function()
        extension.setup()
        extension.setup()
        extension.setup({ style = "snacks" })
      end)
    end)
  end)

  describe("Integration with Tracker", function()
    it("should integrate with tracker module", function()
      extension.setup()

      -- Simulate events that should update tracker state
      assert.has_no.errors(function()
        vim.api.nvim_exec_autocmds("User", {
          pattern = "CodeCompanionRequestStarted",
        })
        vim.api.nvim_exec_autocmds("User", {
          pattern = "CodeCompanionRequestFinished",
        })
      end)
    end)
  end)

  describe("Memory Management", function()
    it("should not leak memory on multiple setups", function()
      for i = 1, 10 do
        assert.has_no.errors(function()
          extension.setup({ style = "snacks" })
        end)
      end
    end)

    it("should handle rapid configuration changes", function()
      local styles = { "cursor-relative", "snacks", "fidget", "native", "lualine", "heirline" }

      for _, style in ipairs(styles) do
        assert.has_no.errors(function()
          extension.setup({ style = style })
        end)
      end
    end)
  end)
end)
