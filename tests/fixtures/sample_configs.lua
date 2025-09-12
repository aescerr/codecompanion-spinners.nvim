-- Sample configurations for testing
local M = {}

-- Valid configurations
M.valid_configs = {
  -- Default config
  default = {},

  -- Cursor-relative with custom settings
  cursor_relative_custom = {
    style = "cursor-relative",
    default_icon = "🤖",
    ["cursor-relative"] = {
      text = "●●●",
      interval = 150
    }
  },

  -- Snacks with custom content
  snacks_custom = {
    style = "snacks",
    content = {
      thinking = {
        icon = "🧠",
        message = "AI is thinking...",
        spacing = " "
      },
      done = {
        icon = "✅",
        message = "Task completed!",
        spacing = " "
      }
    }
  },

  -- Lualine config
  lualine_config = {
    style = "lualine",
    default_icon = "⚡"
  },

  -- Heirline config
  heirline_config = {
    style = "heirline",
    default_icon = "🚀"
  },

  -- Complex nested config
  complex_config = {
    style = "snacks",
    default_icon = "🎯",
    content = {
      thinking = { icon = "🤔", message = "Processing...", spacing = "  " },
      receiving = { icon = "📨", message = "Receiving data...", spacing = "  " },
      done = { icon = "✅", message = "Complete!", spacing = "  " },
      tools_started = { icon = "🔧", message = "Running tools...", spacing = "  " },
      tools_finished = { icon = "⏹️", message = "Tools finished...", spacing = "  " },
      diff_attached = { icon = "📎", message = "Diff attached", spacing = "  " },
      diff_accepted = { icon = "👍", message = "Changes accepted", spacing = "  " },
      diff_rejected = { icon = "👎", message = "Changes rejected", spacing = "  " }
    },
    ["cursor-relative"] = {
      text = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏",
      interval = 100
    }
  }
}

-- Invalid configurations for error testing
M.invalid_configs = {
  -- Invalid style
  invalid_style = {
    style = "nonexistent-style"
  },

  -- Invalid icon type
  invalid_icon = {
    default_icon = 12345 -- Should be string
  },

  -- Invalid content structure
  invalid_content = {
    content = "not a table"
  },

  -- Invalid spacing
  invalid_spacing = {
    content = {
      thinking = {
        spacing = 123 -- Should be string
      }
    }
  },

  -- Empty required fields
  empty_required = {
    style = "",
    default_icon = ""
  }
}

-- Edge case configurations
M.edge_cases = {
  -- Very long messages
  long_messages = {
    style = "snacks",
    content = {
      thinking = {
        icon = "🤖",
        message = string.rep("This is a very long message that might cause display issues ", 10),
        spacing = "   "
      }
    }
  },

  -- Unicode heavy
  unicode_heavy = {
    style = "snacks",
    default_icon = "🎉🚀💯",
    content = {
      thinking = { icon = "🤔💭", message = "思考中...", spacing = "🌟" },
      done = { icon = "✅🎊", message = "完了！", spacing = "🎈" }
    }
  },

  -- Minimal config
  minimal = {
    style = "cursor-relative"
  },

  -- Maximum config
  maximum = {
    style = "snacks",
    default_icon = "🎯",
    content = M.valid_configs.complex_config.content,
    ["cursor-relative"] = {
      text = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
      interval = 50,
      hl_group = "CustomHighlight",
      hl_dim_group = "CustomDim"
    },
    ["native"] = {
      done_timer = 10000,
      window = {
        relative = "editor",
        width = 200,
        height = 50,
        row = 100,
        col = 100,
        border = "double",
        title = "Custom Title"
      }
    }
  }
}

-- Configuration transformation test cases
M.transformation_tests = {
  -- Test merging behavior
  merge_test = {
    base = {
      style = "cursor-relative",
      default_icon = "🤖"
    },
    overlay = {
      content = {
        thinking = { message = "Custom message" }
      }
    },
    expected = {
      style = "cursor-relative",
      default_icon = "🤖",
      content = {
        thinking = { message = "Custom message", icon = "⚛", spacing = "  " }
      }
    }
  }
}

return M