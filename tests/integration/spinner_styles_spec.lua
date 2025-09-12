describe("Spinner Styles Integration", function()
  local config = require("codecompanion._extensions.spinner.config")

  before_each(function()
    config.reset()
  end)

  describe("Spinner Style Loading", function()
    it("should load cursor-relative style", function()
      local spinner = require("codecompanion._extensions.spinner.styles.cursor-relative")
      assert.is_table(spinner)
      assert.is_function(spinner.setup)
      assert.is_function(spinner.render)
    end)

    it("should load snacks style", function()
      local spinner = require("codecompanion._extensions.spinner.styles.snacks")
      assert.is_table(spinner)
      assert.is_function(spinner.setup)
      assert.is_function(spinner.render)
    end)

    it("should load fidget style", function()
      local spinner = require("codecompanion._extensions.spinner.styles.fidget")
      assert.is_table(spinner)
      assert.is_function(spinner.setup)
      assert.is_function(spinner.render)
    end)

    it("should load native style", function()
      local spinner = require("codecompanion._extensions.spinner.styles.native")
      assert.is_table(spinner)
      assert.is_function(spinner.setup)
      assert.is_function(spinner.render)
    end)

    it("should load lualine style", function()
      local spinner = require("codecompanion._extensions.spinner.styles.lualine")
      assert.is_table(spinner)
      assert.is_function(spinner.setup)
      assert.is_function(spinner.get_lualine_component)
    end)

    it("should load heirline style", function()
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
  end)

  describe("Spinner Style Interface", function()
    it("should have consistent interface across styles", function()
      local styles = {
        "cursor-relative",
        "snacks",
        "fidget",
        "native",
        "lualine",
        "heirline"
      }

      for _, style in ipairs(styles) do
        local spinner = require("codecompanion._extensions.spinner.styles." .. style)
        assert.is_function(spinner.setup)
        assert.is_function(spinner.render, "Style " .. style .. " should have render function")
      end
    end)

    it("should handle render calls without errors", function()
      local styles = {
        "cursor-relative",
        "snacks",
        "fidget",
        "native"
      }

      for _, style in ipairs(styles) do
        local spinner = require("codecompanion._extensions.spinner.styles." .. style)
        assert.has_no.errors(function()
          spinner.render("thinking", "CodeCompanionRequestStarted")
        end)
      end
    end)
  end)

  describe("Statusline Components", function()
    it("should create lualine component without errors", function()
      local lualine = require("codecompanion._extensions.spinner.styles.lualine")
      assert.has_no.errors(function()
        local component = lualine.get_lualine_component()
        assert.is_table(component)
      end)
    end)

    it("should create heirline component without errors", function()
      local heirline = require("codecompanion._extensions.spinner.styles.heirline")
      assert.has_no.errors(function()
        local component = heirline.get_heirline_component()
        assert.is_table(component)
      end)
    end)
  end)
end)