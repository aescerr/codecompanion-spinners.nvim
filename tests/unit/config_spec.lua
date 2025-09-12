local config = require("codecompanion._extensions.spinner.config")

describe("Config Module", function()
  before_each(function()
    -- Reset config to defaults before each test
    config.reset()
  end)

  describe("get()", function()
    it("should return default configuration", function()
      local cfg = config.get()
      assert.is_table(cfg)
      assert.equals("cursor-relative", cfg.style)
      assert.equals("", cfg.default_icon)
      assert.is_table(cfg.content)
    end)

    it("should return content for valid state", function()
      local content = config.get_content_for_state("thinking")
      assert.is_table(content)
      assert.equals("", content.icon)
      assert.equals("Thinking...", content.message)
      assert.equals("  ", content.spacing)
    end)

    it("should return nil for invalid state", function()
      local content = config.get_content_for_state("invalid_state")
      assert.is_nil(content)
    end)

    it("should have all required content states", function()
      local required_states = {
        "thinking", "receiving", "done", "stopped", "cleared",
        "tools_started", "tools_finished",
        "diff_attached", "diff_accepted", "diff_rejected",
        "chat_ready", "chat_opened", "chat_hidden", "chat_closed"
      }

      for _, state in ipairs(required_states) do
        local content = config.get_content_for_state(state)
        assert.is_table(content, "Missing content for state: " .. state)
        assert.is_string(content.icon, "Missing icon for state: " .. state)
        assert.is_string(content.message, "Missing message for state: " .. state)
        assert.is_string(content.spacing, "Missing spacing for state: " .. state)
      end
    end)
  end)

  describe("merge()", function()
    it("should merge user config with defaults", function()
      local user_config = {
        style = "snacks",
        default_icon = "🤖",
        content = {
          thinking = {
            message = "AI is thinking...",
            spacing = " "
          }
        }
      }

      config.merge(user_config)
      local cfg = config.get()

      assert.equals("snacks", cfg.style)
      assert.equals("🤖", cfg.default_icon)
      assert.equals("AI is thinking...", cfg.content.thinking.message)
      assert.equals(" ", cfg.content.thinking.spacing)
       -- Should preserve other defaults
       assert.equals("", cfg.content.thinking.icon)
    end)

    it("should handle nested config merging", function()
      local user_config = {
        ["cursor-relative"] = {
          interval = 200
        }
      }

      config.merge(user_config)
      local cfg = config.get()

      assert.equals(200, cfg["cursor-relative"].interval)
      -- Should preserve other cursor-relative defaults
      assert.equals("", cfg["cursor-relative"].text)
    end)

    it("should handle empty user config", function()
      config.merge({})
      local cfg = config.get()
      assert.equals("cursor-relative", cfg.style) -- Should keep defaults
    end)

    it("should handle nil user config", function()
      config.merge(nil)
      local cfg = config.get()
      assert.equals("cursor-relative", cfg.style) -- Should keep defaults
    end)
  end)

  describe("validate()", function()
    it("should accept valid style", function()
      assert.is_true(config.validate({ style = "cursor-relative" }))
      assert.is_true(config.validate({ style = "snacks" }))
      assert.is_true(config.validate({ style = "fidget" }))
      assert.is_true(config.validate({ style = "native" }))
      assert.is_true(config.validate({ style = "lualine" }))
      assert.is_true(config.validate({ style = "heirline" }))
      assert.is_true(config.validate({ style = "none" }))
    end)

    it("should reject invalid style", function()
      assert.is_false(config.validate({ style = "invalid-style" }))
      assert.is_false(config.validate({ style = "" }))
      assert.is_false(config.validate({ style = nil }))
    end)

    it("should validate content structure", function()
      assert.is_true(config.validate({
        style = "snacks",
        content = {
          thinking = { icon = "🤔", message = "Thinking...", spacing = " " }
        }
      }))
    end)

    it("should reject invalid content structure", function()
      assert.is_false(config.validate({
        style = "snacks",
        content = "not a table"
      }))
    end)
  end)

  describe("reset()", function()
    it("should reset config to defaults", function()
      -- Modify config
      config.merge({ style = "snacks", default_icon = "🤖" })

      -- Reset
      config.reset()

      -- Check defaults are restored
      local cfg = config.get()
      assert.equals("cursor-relative", cfg.style)
      assert.equals("", cfg.default_icon)
    end)

    it("should reset content to defaults", function()
      -- Modify content
      config.merge({
        content = {
          thinking = { message = "Modified message" }
        }
      })

      -- Reset
      config.reset()

      -- Check content is restored
      local cfg = config.get()
      assert.equals("Thinking...", cfg.content.thinking.message)
    end)
  end)

  describe("Edge Cases", function()
    it("should handle deeply nested config", function()
      local deep_config = {
        ["cursor-relative"] = {
          nested = {
            value = "test"
          }
        }
      }

      config.merge(deep_config)
      local cfg = config.get()
      assert.equals("test", cfg["cursor-relative"].nested.value)
    end)

    it("should handle array-style config keys", function()
      local array_config = {
        ["native"] = {
          window = {
            border = "rounded"
          }
        }
      }

      config.merge(array_config)
      local cfg = config.get()
      assert.equals("rounded", cfg["native"].window.border)
    end)
  end)
end)