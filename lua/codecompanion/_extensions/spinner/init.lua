--- @module codecompanion._extensions.spinner.init
local Extension = {}

---Setup the extension
---@param opts table Configuration options
function Extension.setup(opts)
  -- 1. Load and merge the user's configuration.
  require("codecompanion._extensions.spinner.config").load(opts)
  local merged_opts = require("codecompanion._extensions.spinner.config").get()

  -- 2. If the style is 'none', do nothing.
  if merged_opts.style == "none" then
    return
  end

  -- 3. Dynamically require the selected spinner implementation.
  local spinner_path = "codecompanion._extensions.spinner.styles." .. merged_opts.style
  local ok, spinner = pcall(require, spinner_path)
  if not ok then
    vim.notify(
      string.format("Failed to load spinner style: '%s'. Please check your configuration.", merged_opts.style),
      vim.log.levels.ERROR,
      { title = "CodeCompanion Spinners" }
    )
    return
  end

  -- 4. Perform one-time setup for the selected spinner.
  if spinner.setup then
    spinner.setup()
  end

  -- 5. Initialize the tracker and connect it to the spinner's render function.
  require("codecompanion._extensions.spinner.tracker").setup(function(new_state, event)
    if spinner.render then
      local render_ok, err = pcall(spinner.render, new_state, event)
      if not render_ok then
        vim.notify(
          string.format("Error rendering spinner '%s': %s", merged_opts.style, tostring(err)),
          vim.log.levels.ERROR,
          { title = "CodeCompanion Spinners" }
        )
      end
    end
  end)
end

--- The main extension entry point.
-- @treturn CodeCompanion.Extension The extension table.
-- @field setup fun(opts: table) Function called when extension is loaded.
-- @field exports? table Functions exposed via codecompanion.extensions.your_extension.
return Extension