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
      assert.equals("⚛", content.icon)
      assert.equals("Thinking...", content.message)
      assert.equals("  ", content.spacing)
    end)

    it("should return nil for invalid state", function()
      local content = config.get_content_for_state("invalid_state")
      assert.is_nil(content)
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
      assert.equals("⚛", cfg.content.thinking.icon)
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
  end)

  describe("validate()", function()
    it("should accept valid style", function()
      assert.is_true(config.validate({ style = "cursor-relative" }))
      assert.is_true(config.validate({ style = "snacks" }))
      assert.is_true(config.validate({ style = "fidget" }))
      assert.is_true(config.validate({ style = "native" }))
      assert.is_true(config.validate({ style = "none" }))
    end)

    it("should reject invalid style", function()
      assert.is_false(config.validate({ style = "invalid-style" }))
      assert.is_false(config.validate({ style = "" }))
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
  end)
end)