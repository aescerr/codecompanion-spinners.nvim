# CodeCompanion Spinner

A companion extension for [`codecompanion.nvim`](https://github.com/olimorris/codecompanion.nvim) that provides beautiful, configurable status spinners and notifications to give you real-time feedback on the AI's activity.

## 📹 Demo

<video src="https://github.com/user-attachments/assets/f1db9995-c575-4db3-ac01-cad0da6abb7f" controls></video>

## ✨ Features

- 🎨 **Multiple Spinner Styles:** Choose from several built-in spinner styles to suit your workflow.
- ⚙️ **Highly Configurable:** Customize icons, messages, highlight groups, and spinner behavior.
- 🧠 **State Aware:** Spinners dynamically change to reflect the AI's state (e.g., Thinking, Running Tools, Awaiting Review).
- 🔌 **Extensible:** Built as a proper `codecompanion.nvim` extension.

## 📦 Installation

Install with your favorite plugin manager. This plugin is a [`codecompanion.nvim`](https://github.com/olimorris/codecompanion.nvim) extension and should be configured within its `extensions` table.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

> ⚠️ **Note:** This is an extension for [`codecompanion.nvim`](https://github.com/olimorris/codecompanion.nvim). Make sure you have the main plugin installed first.

```lua
{
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
     "lalitmee/codecompanion-spinners.nvim", -- Install the spinners extension
     -- 📦 Optional dependencies for certain spinner styles:
     -- "j-hui/fidget.nvim",
     -- "folke/snacks.nvim",
  },
  opts = {
    -- ... your main codecompanion config ...
     extensions = {
       spinner = {
         -- enabled = true, -- This is the default
         opts = {
           -- Your spinner configuration goes here
            style = "cursor-relative",
         },
       },
     },
  },
}
```

## ⚙️ Configuration

You can configure the extension by passing a table to the `opts` key under `extensions.spinner`.

### ⚙️ Default Configuration

Here is the complete default configuration. You only need to specify the values you wish to override.

```lua
{
	-- The spinner style to use.
	-- Available options: "cursor-relative", "snacks", "fidget", "native", "none"
	style = "cursor-relative",

	-- Default icon to show when spinners are idle (default: "")
	default_icon = "",

 	-- A table mapping internal states to their display content (icons and messages).
  content = {
    -- 🧠 General states
    thinking = { icon = "⚛", message = "Thinking...", spacing = "  " },
    receiving = { icon = "", message = "Receiving...", spacing = "  " },
    done = { icon = "", message = "Done!", spacing = "  " },
    stopped = { icon = "", message = "Stopped", spacing = "  " },
    cleared = { icon = "", message = "Chat cleared", spacing = "  " },

    -- 🔧 Tool-related states
    tools_started = { icon = "", message = "Running tools...", spacing = "  " },
    tools_finished = { icon = "⤷", message = "Processing tool output...", spacing = "  " },

    -- 📝 Diff-related states
    diff_attached = { icon = "", message = "Review changes", spacing = "  " },
    diff_accepted = { icon = "", message = "Change accepted", spacing = "  " },
    diff_rejected = { icon = "", message = "Change rejected", spacing = "  " },

    -- 💬 Chat-related states (primarily for notifiers like snacks)
    chat_ready = { icon = "", message = "Chat ready", spacing = "  " },
    chat_opened = { icon = "", message = "Chat opened", spacing = "  " },
    chat_hidden = { icon = "", message = "Chat hidden", spacing = "  " },
    chat_closed = { icon = "", message = "Chat closed", spacing = "  " },
  },

 	-- 🎨 Spinner-specific settings
  ["cursor-relative"] = {
    text = "",
    -- text = "",
    hl_positions = {
      { 0, 3 }, -- First circle
      { 3, 6 }, -- Second circle
      { 6, 9 }, -- Third circle
    },
    interval = 100,
    hl_group = "Title",
    hl_dim_group = "NonText",
  },
  fidget = {
    -- No specific options for now
  },
  snacks = {
    -- No specific options for now
  },
  native = {
    done_timer = 500,
    window = {
      relative = "editor",
      width = 30,
      height = 1,
      row = vim.o.lines - 5,
      col = vim.o.columns - 35,
      style = "minimal",
      border = "rounded",
      title = "CodeCompanion",
      title_pos = "center",
      focusable = false,
      noautocmd = true,
    },
    win_options = {
      -- winblend = 10,
    },
  },
}
```

---

## 🎨 Available Spinners

You can choose one of the following styles by setting the `style` option:

### Quick Overview
- 🖱️ **`cursor-relative`** (Default) - Floating window spinner near cursor
- 📊 **`fidget`** - Progress notifications via fidget.nvim
- 🍿 **`snacks`** - Rich notifications via snacks.nvim or vim.notify
- 🪟 **`native`** - Highly configurable floating window
- 🚫 **`none`** - Disable all spinners

### Detailed Descriptions

### 🖱️ `cursor-relative` (Default)

A minimal, animated spinner that floats in a small window next to your cursor. It provides unobtrusive feedback without getting in your way.

**Demo:**

<video src="https://github.com/user-attachments/assets/b023c5d9-daae-4da1-a4f6-2020e984369a" controls></video>

**Visuals:**
- ⚡ **Active:** A smooth highlight animation across the spinner characters (e.g., `` with moving highlights).
- ✅ **Finished:** The spinner is replaced by a checkmark and a "Done!" message, which persists for a short duration before fading away.

**🔧 Specific Options:**

```lua
opts = {
  style = "cursor-relative",
  ["cursor-relative"] = {
    -- The spinner text characters
    text = "",
    -- Alternative: text = "",

    -- Highlight positions for animation (start_col, end_col pairs)
    hl_positions = {
      { 0, 3 }, -- First circle
      { 3, 6 }, -- Second circle
      { 6, 9 }, -- Third circle
    },

    -- Animation interval in milliseconds
    interval = 100,

    -- Highlight groups
    hl_group = "Title",        -- Active highlight
    hl_dim_group = "NonText",  -- Dimmed background
  },
}
```

---

### 📊 `fidget`

This style leverages the excellent [fidget.nvim](https://github.com/j-hui/fidget.nvim) plugin to display progress in the corner of your screen. It's a great choice if you already use `fidget.nvim` for LSP progress.

**📋 Prerequisites:** You must have `j-hui/fidget.nvim` installed.

**Demo:**

<video src="https://github.com/user-attachments/assets/0f0ee5e5-d74b-4c5d-bea9-22d537decb52" controls></video>

**Visuals:**
- 📋 A "CodeCompanion" task will appear in your fidget window, showing the current status (e.g., "Thinking...").
- ✅ When complete, the task is marked as finished.
- 🎯 This spinner is intentionally simple and only notifies for the `thinking` and `done` states to avoid excessive notifications.

**Specific Options:**
This spinner currently has no specific options.

```lua
opts = {
  style = "fidget",
}
```

---

### 🍿 `snacks`

This style uses [snacks.nvim](https://github.com/folke/snacks.nvim) (or the built-in `vim.notify` as a fallback) to show rich, animated notifications. It provides the most detailed feedback of all the spinners.

**📋 Prerequisites:** For the best experience, you should have `folke/snacks.nvim` installed.

**Demo:**

<video src="https://github.com/user-attachments/assets/f1db9995-c575-4db3-ac01-cad0da6abb7f" controls></video>

**Visuals:**
- 🔔 A notification popup appears with an icon and status message in the format `<icon> <message>` (e.g., "⚛ Thinking...").
- 🔄 The notification updates in-place as the AI moves through different states with animated spinner icons.
- 📢 It also shows one-off notifications for events like accepting/rejecting diffs or opening/closing the chat window.

**Specific Options:**
This spinner currently has no specific options.

```lua
opts = {
  style = "snacks",
}
```

---



### 🪟 `native`

This style creates a highly configurable floating window using Neovim's native `nvim_open_win` function. It provides maximum control over the window's appearance and behavior without requiring any external dependencies.

**📋 Prerequisites:** None - uses only built-in Neovim features.

**Demo:**

<video src="https://github.com/user-attachments/assets/659f9f88-e385-487f-b0fe-49f97fb1b997" controls></video>

**Visuals:**
- 🏗️ A floating window appears with your configured title, size, position, and border style.
- ⚙️ The window displays the current status with an animated spinner.
- ✅ When complete, shows a "Done!" message before disappearing.

**🔧 Specific Options:**

```lua
opts = {
  style = "native",
  native = {
    -- How long (in ms) the "Done!" message should remain visible after completion.
    done_timer = 500,

    -- Window configuration - all nvim_open_win options are supported
    window = {
      -- Position and size
      relative = "editor",        -- "editor", "win", "cursor"
      width = 30,                 -- Window width in characters
      height = 1,                 -- Window height in lines
      row = vim.o.lines - 5,      -- Row position (from top)
      col = vim.o.columns - 35,   -- Column position (from left)

      -- Appearance
      style = "minimal",          -- Window style
      border = "rounded",         -- Border style: "none", "single", "double", "rounded", "solid", "shadow"
      title = "CodeCompanion",    -- Window title text
      title_pos = "center",       -- Title position: "left", "center", "right"

      -- Behavior
      focusable = false,          -- Whether window can receive focus
      noautocmd = true,           -- Disable autocmds for performance
    },

    -- Additional window options using nvim_set_option_value
    win_options = {
      -- winblend = 10,           -- Window transparency (0-100)
      -- winhighlight = "Normal:Normal,FloatBorder:Normal", -- Custom highlighting
    },
  },
}
```

**🚀 Advanced Configuration Examples:**

```lua
-- Top-right corner with transparency
native = {
  window = {
    relative = "editor",
    width = 25,
    height = 1,
    row = 1,
    col = vim.o.columns - 30,
    border = "single",
    title = "🤖 AI",
    title_pos = "left",
  },
  win_options = {
    winblend = 15,
  },
}

-- Centered with double border
native = {
  window = {
    relative = "editor",
    width = 35,
    height = 1,
    row = math.floor(vim.o.lines / 2) - 10,
    col = math.floor(vim.o.columns / 2) - 17,
    border = "double",
    title = "CodeCompanion Status",
    title_pos = "center",
  },
}
```

---

### 🚫 `none`

Disables all spinners and notifications from this extension.

```lua
opts = {
  style = "none",
}
```

---

## 🤝 Contributing

We welcome contributions! Please see our [CONTRIBUTING.md](./CONTRIBUTING.md) file for detailed guidelines on how to contribute to this project. Feel free to open issues or discussions for this extension.

### 📋 When adding new spinner styles:
1. 🔧 Follow the existing interface pattern (setup() and render() functions)
2. 📦 Handle dependencies gracefully with warnings
3. 🎯 Support all configuration states
4. 📚 Add comprehensive documentation
5. 🧪 Test with various CodeCompanion workflows

## 🌟 Project Sharing

This project was vibe coded using AI and made publicly available to help other Neovim users enhance their CodeCompanion experience with beautiful, customizable spinners. The code is freely available for anyone to use, modify, and contribute to.

## 🙏 Acknowledgements

This extension is built for and inspired by the excellent [`codecompanion.nvim`](https://github.com/olimorris/codecompanion.nvim) plugin by Oliver Morris. While we drew inspirations from the spinners discussed in the CodeCompanion community and documented in their UI section, this implementation is our own original work with custom features and enhancements.

### 📚 Resources
- 🎨 [CodeCompanion UI Documentation](https://codecompanion.olimorris.dev/usage/ui.html) - Learn more about CodeCompanion's UI features and spinner concepts
- 💬 [CodeCompanion Discussions](https://github.com/olimorris/codecompanion.nvim/discussions) - Community discussions about UI enhancements and spinner ideas
- 🤖 Vibe Coded - AI-powered coding assistant used in development

<div align="center">

---

💝 **Vibe coded with love**

---

</div>
