# CodeCompanion Spinner - Comprehensive Context

## Project Overview

This is a Neovim plugin extension for `codecompanion.nvim` that provides beautiful, configurable status spinners and notifications to give you real-time feedback on AI activity.

**Repository:** https://github.com/lalitmee/codecompanion-spinners.nvim
**Maintained by:** Lalit Kumar Mehta
**License:** MIT (inferred from typical Neovim plugin practices)

## Architecture

### Core Components

1. **Extension Entry Point** (`lua/codecompanion/_extensions/spinner/init.lua`)
   - Main setup function that loads configuration and initializes the selected spinner
   - Handles dynamic loading of spinner implementations
   - Provides error handling for missing spinner styles

2. **Configuration Management** (`lua/codecompanion/_extensions/spinner/config.lua`)
   - Manages user configuration with sensible defaults
   - Provides deep merging of user options
   - Exposes helper functions for accessing configuration

3. **State Tracker** (`lua/codecompanion/_extensions/spinner/tracker.lua`)
   - Central event handler for all CodeCompanion events
   - Maintains internal state counters for requests, tools, diffs
   - Provides state machine logic with defined states:
     - `IDLE`: No active operations
     - `THINKING`: AI is processing a request
     - `RECEIVING`: AI is streaming response
     - `TOOLS_RUNNING`: Tools are being executed
     - `TOOLS_PROCESSING`: Tool output is being processed
     - `DIFF_AWAITING`: Diff is attached and awaiting review

4. **Spinner Implementations** (`lua/codecompanion/_extensions/spinner/styles/`)
   - `cursor-relative.lua`: Floating window spinner near cursor
   - `fidget.lua`: Integration with fidget.nvim
   - `snacks.lua`: Rich notifications via snacks.nvim or vim.notify
   - `lualine.lua`: Statusline component for lualine.nvim

### Event Handling

The plugin listens to the following CodeCompanion events:
- `CodeCompanionRequestStarted`
- `CodeCompanionRequestStreaming`
- `CodeCompanionRequestFinished`
- `CodeCompanionToolStarted`
- `CodeCompanionToolFinished`
- `CodeCompanionToolsFinished`
- `CodeCompanionDiffAttached`
- `CodeCompanionDiffDetached`
- `CodeCompanionChatDone`
- `CodeCompanionChatStopped`

## Spinner Styles

### 1. cursor-relative (Default)
- **Type:** Floating window near cursor
- **Features:** Animated spinner, temporary messages
- **Dependencies:** None
- **Configuration:**
  ```lua
  ["cursor-relative"] = {
    text = "",
    hl_positions = {
      { 0, 3 }, -- First circle
      { 3, 6 }, -- Second circle
      { 6, 9 }, -- Third circle
    },
    interval = 100,
    hl_group = "Title",
    hl_dim_group = "NonText",
  }
  ```

### 2. fidget
- **Type:** Progress notification in fidget window
- **Features:** Persistent progress, one-off notifications
- **Dependencies:** `j-hui/fidget.nvim`
- **Configuration:** None

### 3. snacks
- **Type:** Rich notifications
- **Features:** Animated notifications with icons, detailed feedback
- **Dependencies:** `folke/snacks.nvim` (optional, falls back to vim.notify)
- **Configuration:** None
- **Visual Format:** `<icon> <message>` (e.g., "⚛ Thinking...")

### 4. lualine
- **Type:** Statusline component
- **Features:** Integrated status display that only shows when CodeCompanion chat panel is open, automatic updates
- **Dependencies:** `nvim-lualine/lualine.nvim`
- **Configuration:** Uses global `default_icon` for active states, shows nothing when chat is closed
- **Usage:** Use `get_lualine_component()` for easy integration

**API Functions:**
- `get_status()`: Returns the current status text string
- `get_lualine_component()`: Returns a complete lualine component configuration

**Example Usage:**
```lua
require('lualine').setup({
  sections = {
    lualine_c = {
      require('codecompanion._extensions.spinner.styles.lualine').get_lualine_component(),
    },
  }
})
```

**Behavior:**
- Only displays content when the CodeCompanion chat panel is open and there's active AI activity
- Shows nothing (empty string) when chat is closed, hidden, or idle
- Tracks chat state using `CodeCompanionChatOpened`, `CodeCompanionChatClosed`, and `CodeCompanionChatHidden` events
- Displays in the statusline regardless of which buffer you're currently viewing

### 5. native
```lua
require('codecompanion').setup({
  extensions = {
    spinner = {
      opts = {
        style = "native",
        native = {
          window = {
            title = "My Custom AI",
            border = "double",
            width = 40,
          },
        },
      },
    },
  },
})
```

### 5. native
- **Type:** Floating window (native)
- **Features:** Highly configurable floating window with animated title and icon+message content
- **Dependencies:** None (uses only built-in Neovim features)
- **Configuration:** Extensive window configuration options
- **Visual Layout:**
  - **Title:** Shows animated spinner + "CodeCompanion" with padding
  - **Window Content:** Displays state icon + configurable spacing + message text
- **Usage:** Configure window position, size, border, title, and content spacing

### 6. none
- **Type:** Disabled
- **Features:** No spinners or notifications
- **Dependencies:** None

## Configuration States

The plugin supports various states with customizable icons and messages:

```lua
content = {
  -- General states
  thinking = { icon = "⚛", message = "Thinking...", spacing = "  " },
  receiving = { icon = "", message = "Receiving...", spacing = "  " },
  done = { icon = "", message = "Done!", spacing = "  " },
  stopped = { icon = "", message = "Stopped", spacing = "  " },
  cleared = { icon = "", message = "Chat cleared", spacing = "  " },

  -- Tool-related states
  tools_started = { icon = "", message = "Running tools...", spacing = "  " },
  tools_finished = { icon = "⤷", message = "Processing tool output...", spacing = "  " },

  -- Diff-related states
  diff_attached = { icon = "", message = "Review changes", spacing = "  " },
  diff_accepted = { icon = "", message = "Change accepted", spacing = "  " },
  diff_rejected = { icon = "", message = "Change rejected", spacing = "  " },

  -- Chat-related states
  chat_ready = { icon = "", message = "Chat ready", spacing = "  " },
  chat_opened = { icon = "", message = "Chat opened", spacing = "  " },
  chat_hidden = { icon = "", message = "Chat hidden", spacing = "  " },
  chat_closed = { icon = "", message = "Chat closed", spacing = "  " },
}
```

## Installation & Setup

### Dependencies
- `olimorris/codecompanion.nvim` (main plugin)
- Optional: `j-hui/fidget.nvim`, `folke/snacks.nvim`, `nvim-lualine/lualine.nvim`

### Configuration Example
```lua
require('codecompanion').setup({
  -- ... other config ...
  extensions = {
    spinner = {
      enabled = true,
      opts = {
        style = "cursor-relative",
        content = {
          thinking = { icon = "🤔", message = "AI is thinking...", spacing = "  " },
          receiving = { icon = "📨", message = "Receiving response...", spacing = " " },
        },
        ["cursor-relative"] = {
          done_timer = 1000,
        },
      },
    },
  },
})
```

## File Structure

```
codecompanion-spinners.nvim/
├── README.md                    # Main documentation
├── CONTEXT.md                   # This comprehensive context file
├── doc/
│   └── codecompanion-spinners.txt # Vim help documentation
└── lua/
    └── codecompanion/
        └── _extensions/
            └── spinner/
                ├── init.lua           # Extension entry point
                ├── config.lua         # Configuration management
                ├── tracker.lua        # State tracking
                └── styles/
                    ├── native.lua
                    ├── cursor-relative.lua
                    ├── fidget.lua
                    ├── lualine.lua
                    └── snacks.lua
```

## Development Notes

### Code Style
- Uses EmmyLua annotations for type hints
- Follows Neovim Lua conventions
- Error handling with pcall for robustness
- Consistent naming and structure across spinner implementations

### State Management
- Centralized state tracking prevents inconsistencies
- Event-driven architecture for real-time updates
- Proper cleanup on completion/reset events

### Extensibility
- Easy to add new spinner styles by implementing the spinner interface
- Configuration system supports custom states and content
- Modular design allows for independent spinner development
- **Spacing Configuration:** Spacing between icon and message is configured per content state, allowing granular control over visual appearance

### Development Workflow

#### ⚠️ Critical Safety Rule
- **NEVER commit and push changes without explicit user approval**
- Always ask for permission before running `git commit` or `git push`
- This prevents accidental commits that could affect the repository
- Respect user control over when and what gets published

- **CONTEXT.md Updates:** Always update CONTEXT.md with significant changes, new features, bug fixes, and design decisions for future reference
- **Documentation Priority:** Update both README.md and CONTEXT.md when making user-facing changes
- **Change Tracking:** Document what was changed, why it was changed, and how it affects users

### Git Commit Best Practices
Follow these guidelines for all git commits to maintain a clean, readable commit history:

#### Commit Message Format
- **Subject Line:** Keep under 72 characters, use imperative mood, no period at end
- **Body:** Optional, explain what and why (not how), wrap at 72 characters
- **Format:** `Type: Brief description` or `Type(scope): Brief description`

#### Commit Types
- `feat:` - New feature or enhancement
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style/formatting changes (no functional changes)
- `refactor:` - Code refactoring (no functional changes)
- `test:` - Adding/updating tests
- `chore:` - Maintenance tasks, build changes, etc.

#### Best Practices
- **Atomic Commits:** Each commit should contain one logical change
- **Clear Messages:** Write commit messages that explain the "why" and "what", not just "how"
- **Present Tense:** Use present tense ("Add feature" not "Added feature")
- **Imperative Mood:** Start with imperative verbs ("Fix bug" not "Fixed bug" or "Fixes bug")
- **Reference Issues:** Include issue numbers when applicable (`Fix #123: Handle edge case`)
- **Test Before Commit:** Ensure changes work and don't break existing functionality
- **Update Documentation:** Update README.md and CONTEXT.md for user-facing changes

#### Examples
```
feat: Add native spinner style with floating window support

- Implement highly configurable floating window spinner
- Add window position, size, and border customization
- Support animated title with CodeCompanion branding
- Include comprehensive configuration options

fix: Resolve lualine spinner display issue

- Remove buffer filetype check that prevented global display
- Update component to show status regardless of current buffer
- Add chat state tracking for conditional visibility

docs: Update README with native spinner configuration examples

- Add advanced configuration examples for window positioning
- Include transparency and border styling options
- Document all available window configuration parameters
```

## Recent Improvements

1. **✅ Native Spinner Enhancement:** Moved loading animation to window title with "CodeCompanion" branding, window content now shows icon + configurable spacing + message
2. **✅ Granular Spacing Control:** Moved spacing configuration from global native config to individual content entries for per-state customization
3. **✅ Configuration Flexibility:** Users can now customize spacing, icons, and messages for each spinner state independently
4. **✅ Snacks Spinner Icon Display:** Fixed icon display in snacks notifications to show format `<icon> <message>` consistently
5. **✅ Fidget & Lualine Spacing:** Fixed spacing configuration usage in fidget and lualine spinners to respect per-state spacing settings
6. **✅ Code Cleanup:** Removed redundant spacing fallbacks from all spinner implementations (native, fidget, lualine, snacks) since defaults are handled at config level
7. **✅ Documentation Fix:** Corrected require paths in README.md from `spinners` to `spinner` to match actual module structure
8. **✅ Lualine Component Fix:** Simplified lualine component structure to return a function instead of complex table to fix "attempt to call a table value" error
9. **✅ Global Default Icon:** Added configurable default icon () for all spinners when idle, with animated spinner when active
10. **✅ Code Cleanup:** Removed redundant fallback statements from all spinner implementations since defaults are handled at config level
11. **✅ State-Based Icons:** Implemented state-specific icon display - thinking state now uses default icon () instead of thinking icon (⚛)
12. **✅ Snacks Icon Fix:** Fixed snacks spinner to show default icon instead of info icon when request ends
13. **✅ Lualine Conditional Display:** Lualine spinner now only shows content when CodeCompanion chat panel is open, eliminating "nil" display when idle

## Known Issues & TODOs

1. **Documentation Completeness:** Lualine integration was implemented but not documented (now fixed)
2. **Require Path Consistency:** Snacks.lua had incorrect require paths (now fixed)
3. **Testing:** No automated tests currently exist
4. **Performance:** No performance optimizations for high-frequency updates

## Future Enhancements

1. Add more spinner styles (e.g., mini.notify, noice.nvim)
2. Implement configuration validation
3. Add unit tests
4. Performance monitoring and optimization
5. More granular state control
6. Custom animation frames support

## Contributing

When adding new spinner styles:
1. Follow the existing interface pattern (setup() and render() functions)
2. Handle dependencies gracefully with warnings
3. Support all configuration states
4. Add comprehensive documentation
5. Test with various CodeCompanion workflows

## Support

For issues and feature requests, please use the GitHub repository's issue tracker.