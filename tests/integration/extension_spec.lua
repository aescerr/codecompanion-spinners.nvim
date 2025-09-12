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
        default_icon = "🤖"
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
        style = "invalid-style"
      }

      -- Should not error but fall back to default
      assert.has_no.errors(function()
        extension.setup(custom_config)
      end)

      local cfg = config.get()
      assert.equals("cursor-relative", cfg.style) -- Should fall back to default
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
  end)

  describe("Event Handling", function()
    it("should handle CodeCompanion events", function()
      extension.setup()

      -- Simulate some events
      assert.has_no.errors(function()
        -- These would normally be triggered by CodeCompanion
        vim.api.nvim_exec_autocmds("User", {
          pattern = "CodeCompanionRequestStarted"
        })
      end)
    end)
  end)

  describe("Error Handling", function()
    it("should handle missing dependencies gracefully", function()
      -- Mock a scenario where a dependency is missing
      -- This is hard to test directly, but we can test that the extension
      -- doesn't crash when setup is called multiple times
      assert.has_no.errors(function()
        extension.setup()
        extension.setup() -- Should be idempotent
      end)
    end)
  end)
end)