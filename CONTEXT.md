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
    - Includes `state_map` table for converting numeric states to string names used by spinners
    - Includes `one_off_events` table for mapping CodeCompanion events to content keys for notifications

4. **Spinner Implementations** (`lua/codecompanion/_extensions/spinner/styles/`)
   - `cursor-relative.lua`: Floating window spinner near cursor
   - `fidget.lua`: Integration with fidget.nvim
   - `snacks.lua`: Rich notifications via snacks.nvim or vim.notify
   - `lualine.lua`: Statusline component for lualine.nvim
   - `heirline.lua`: Statusline component for heirline.nvim

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
- `CodeCompanionDiffAccepted`
- `CodeCompanionDiffRejected`
- `CodeCompanionChatDone`
- `CodeCompanionChatStopped`
- `CodeCompanionChatOpened`
- `CodeCompanionChatClosed`
- `CodeCompanionChatHidden`
- `CodeCompanionChatCleared`

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
     hl_group = "Cursor",
     hl_dim_group = "Comment",
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

### 4. lualine
- **Type:** Statusline component
- **Features:** Shows AI status with animated spinner, icons, and text messages in lualine
- **Dependencies:** `nvim-lualine/lualine.nvim`
- **Configuration:** Uses default icon and state-based messages like other spinners
- **Usage:** Use `get_lualine_component()` for easy integration
- **Behavior:**
  - Shows animated spinner with default icon and status messages
  - Displays different messages for thinking, receiving, tools, done, etc.
  - Automatically clears messages after completion
  - Only displays when there's active AI activity

**API Functions:**
- `get_lualine_component()`: Returns the lualine component configuration
- `setup()`: Initializes autocmds for event handling

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

**Example Display:**
- `⠋ 🤖 Thinking...` (when AI is processing)
- `⠙ 🤖 Receiving...` (when streaming response)
- `✅ Done!` (when completed)

### 5. heirline
- **Type:** Statusline component
- **Features:** Shows AI status with animated spinner, icons, and text messages in heirline
- **Dependencies:** `rebelot/heirline.nvim`
- **Configuration:** Uses default icon and state-based messages like other spinners
- **Usage:** Use `get_heirline_component()` for easy integration
- **Behavior:**
  - Shows animated spinner with default icon and status messages
  - Displays different messages for thinking, receiving, tools, done, etc.
  - Automatically clears messages after completion
  - Includes optional highlighting for better visibility

**API Functions:**
- `get_heirline_component()`: Returns the heirline component for integration
- `status()`: Returns current status string

**Example Usage:**
```lua
local heirline = require('heirline')
local CodeCompanionSpinner = require('codecompanion._extensions.spinner.styles.heirline')

heirline.setup({
  statusline = {
    -- Your other components...
    CodeCompanionSpinner.get_heirline_component(),
    -- More components...
  }
})
```

**Example Display:**
- `⠋ 🤖 Thinking...` (when AI is processing)
- `⠙ 🤖 Receiving...` (when streaming response)
- `✅ Done!` (when completed)

### 6. native
- **Type:** Floating window (native)
- **Features:** Highly configurable floating window with animated title and icon+message content
- **Dependencies:** None (uses only built-in Neovim features)
- **Configuration:** Extensive window configuration options
- **Visual Layout:**
  - **Title:** Shows animated spinner + "CodeCompanion" with padding
  - **Window Content:** Displays state icon + configurable spacing + message text
- **Usage:** Configure window position, size, border, title, and content spacing

### 7. none
- **Type:** Disabled
- **Features:** No spinners or notifications
- **Dependencies:** None

## Configuration States

The plugin supports various states with customizable icons and messages:

```lua
content = {
  -- General states
  thinking = { icon = "", message = "Thinking...", spacing = "  " },
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
                    ├── cursor-relative.lua
                    ├── fidget.lua
                    ├── lualine.lua
                    ├── native.lua
                    └── snacks.lua
```

## Development Notes

### Code Style
- Uses EmmyLua annotations for type hints
- Follows Neovim Lua conventions
- Error handling with pcall for robustness
- Consistent naming and structure across spinner implementations
- **State Derivation Rule**: Prefer deriving state from existing counters/flags rather than adding new boolean variables. Only use explicit boolean state variables when the state cannot be cleanly derived from existing data (e.g., `is_streaming` distinguishes THINKING vs RECEIVING states, `tools_processing` distinguishes IDLE vs TOOLS_PROCESSING when tools_count == 0)

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

#### 🚨 CRITICAL SAFETY RULES (MUST FOLLOW)
- **🚫 NEVER commit and push changes without explicit user approval**
- **❓ ALWAYS ask for permission before running `git commit` or `git push`**
- **🛡️ This prevents accidental commits that could affect the repository**
- **👤 Respect user control over when and what gets published**
- **🚫 NEVER commit changes automatically** - Always wait for user confirmation before committing, even for documentation updates
- **⚡ REMINDER: If you break these rules, immediately apologize and revert the commit**

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
- **Lowercase Titles:** Use lowercase for commit message titles (e.g., "docs: update vibe references")

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

## Code Principles

### DRY (Don't Repeat Yourself)
- Avoid code duplication across files
- Shared constants and mappings are centralized (e.g., `tracker.state_map` and `tracker.one_off_events` for state/content mappings)
- When adding new shared data structures, place them in the appropriate central module rather than duplicating across spinners

### Type Safety & Consistency
- **State Handling:** Tracker sends numeric enum values to spinners, spinners use `tracker.state_map` to convert to strings for config lookup
- **Interface Consistency:** All spinner implementations follow the same `render(state, event)` interface
- **Error Handling:** Graceful degradation when dependencies are missing

## State Management Architecture

### Enum-Based State System
The plugin uses a robust enum-based state system for type safety and consistency:

```lua
-- State enum values (tracker.lua)
M.State = {
  IDLE = 1,
  THINKING = 2,
  RECEIVING = 3,
  TOOLS_RUNNING = 4,
  TOOLS_PROCESSING = 5,
  DIFF_AWAITING = 6,
}

-- State mapping for config lookup (tracker.lua)
M.state_map = {
  [M.State.IDLE] = "idle",
  [M.State.THINKING] = "thinking",
  [M.State.RECEIVING] = "receiving",
  [M.State.TOOLS_RUNNING] = "tools_started",
  [M.State.TOOLS_PROCESSING] = "tools_finished",
  [M.State.DIFF_AWAITING] = "diff_attached",
}
```

### State Flow
```
CodeCompanion Event → Tracker Event Handler → State Calculation → Numeric State → Spinner.render(numeric_state, event)
                                                                 ↓
                                                         state_map[numeric_state] → string_key → config.get_content_for_state(string_key)
```

### Spinner Interface
All spinner implementations follow this consistent interface:

```lua
local M = {}

--- Setup function called once during initialization
function M.setup()
  -- Check dependencies, setup autocmds, etc.
end

--- Render function called for each state change
--- @param new_state number The numeric state from tracker.State enum
--- @param event string The raw CodeCompanion event that triggered the change
function M.render(new_state, event)
  -- Handle state change, update UI
end

return M
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
14. **✅ Demo Videos:** Added comprehensive demo videos for all spinner styles in README.md
15. **✅ Event Handling:** Extended event handling to include chat state events (opened, closed, hidden, cleared)
16. **✅ Context Documentation:** Updated CONTEXT.md to reflect current implementation and fix discrepancies
17. **✅ DRY Refactoring:** Centralized `state_map` in tracker module, eliminated duplication across all spinner implementations
18. **✅ Enum-Based State System:** Implemented consistent numeric state handling with type safety
19. **✅ Test Suite Completeness:** All 94 tests passing, comprehensive coverage of all spinner styles and edge cases
20. **✅ Fidget Spinner Fix:** Fixed state mapping issue causing "attempt to index local 'content'" errors
21. **✅ Complete DRY Refactoring:** Centralized `one_off_events` mapping in tracker module, eliminated duplication across all spinners (fidget, snacks, native)
22. **✅ Improved Highlight Groups:** Updated cursor-relative spinner defaults from `Title`/`NonText` to `Cursor`/`Comment` for better visibility across colorschemes

## Testing

The project includes a comprehensive test suite using the [busted](https://lunarmodules.github.io/busted/) testing framework for Lua. Tests are organized into unit and integration categories with proper mocking and fixtures.

### Test Structure

```
tests/
├── unit/                    # Unit tests for individual modules
│   ├── config_spec.lua     # Configuration module tests
│   └── tracker_spec.lua    # State tracker tests
├── integration/            # Integration tests for full workflows
│   ├── extension_spec.lua  # Extension loading and setup tests
│   └── spinner_styles_spec.lua # Spinner style integration tests
├── fixtures/               # Test data and sample configurations
│   ├── event_sequences.lua # Mock event sequences
│   └── sample_configs.lua  # Sample configuration data
├── helpers/                # Test utilities and environment setup
│   ├── event_simulator.lua # Event simulation helpers
│   └── test_env.lua        # Test environment management
├── mocks/                  # Mock implementations
│   ├── codecompanion.lua   # CodeCompanion API mocks
│   └── neovim_api.lua      # Neovim API mocks
├── performance_spec.lua    # Performance benchmarking tests
├── minimal_init.lua        # Minimal Neovim environment for testing
└── run_tests.lua           # Main test runner script
```

### Running Tests

#### Prerequisites
Install test dependencies using LuaRocks:
```bash
make install-deps
```
This installs: `busted`, `luacov`, and `luafilesystem`.

#### Test Commands

**Run all tests:**
```bash
make test
# or directly:
lua tests/run_tests.lua
```

**Run unit tests only:**
```bash
make test-unit
```

**Run integration tests only:**
```bash
make test-integration
```

**Run tests with coverage:**
```bash
make test-coverage
```

**Run performance tests:**
```bash
make perf-test
```

**Run CI tests (non-verbose, with coverage):**
```bash
make ci-test
```

**Clean test artifacts:**
```bash
make clean
```

#### Additional Commands

**Watch mode (requires inotify-tools):**
```bash
make test-watch
```

**Lint code:**
```bash
make lint
```

**Full development cycle:**
```bash
make dev  # Runs: clean, install-deps, lint, test-coverage, docs
```

### Test Configuration

Tests use Busted configuration defined in `.busted` with different profiles:
- `default`: Standard test run with verbose output
- `unit`: Unit tests only
- `integration`: Integration tests only
- `coverage`: Tests with coverage reporting

### Test Environment

- **Framework:** Busted (Lua testing framework)
- **Coverage:** LuaCov for code coverage analysis
- **Mocking:** Custom mock implementations for Neovim and CodeCompanion APIs
- **Isolation:** Each test runs in a minimal Neovim environment with proper setup/teardown

### Current Test Status
- **Total Tests:** 94 tests
- **Status:** ✅ All passing (94 successes / 0 failures / 0 errors)
- **Coverage:** Comprehensive coverage of all spinner styles, state transitions, and edge cases
- **Performance:** Sub-200ms for 1000 render operations across multiple spinners

### Writing Tests

When adding new tests:
1. Follow the existing naming convention: `*_spec.lua`
2. Place unit tests in `tests/unit/`, integration tests in `tests/integration/`
3. Use the test environment helpers from `tests/helpers/`
4. Mock external dependencies appropriately
5. Include both positive and negative test cases
6. Test configuration merging and validation

## Known Issues & TODOs

1. **Performance:** No performance optimizations for high-frequency updates (current: ~0.1ms per render)
2. **Documentation:** Some advanced configuration examples could be expanded
3. **Enhanced Lualine Features:** Could add more customization options for lualine spinner
4. **CI/CD:** Add GitHub Actions for automated testing
5. **Animation Customization:** Allow users to define custom spinner animation frames

## Future Enhancements

1. Add more spinner styles (e.g., mini.notify, noice.nvim)
2. Implement configuration validation with schema checking
3. Performance monitoring and optimization dashboard
4. More granular state control with custom state definitions
5. Custom animation frames support for all spinner styles
6. Plugin integration testing framework
7. Internationalization support for status messages

## Contributing

When adding new spinner styles:
1. Follow the existing interface pattern (setup() and render() functions)
2. Handle dependencies gracefully with warnings
3. Support all configuration states
4. Add comprehensive documentation
5. Test with various CodeCompanion workflows

## Debugging & Troubleshooting

### Common Issues

1. **"attempt to index local 'content' (a nil value)"**
   - **Cause:** State mapping mismatch between tracker and config
   - **Fix:** Ensure `tracker.state_map` keys match config content keys
   - **Prevention:** Always update both when adding new states

2. **Spinner not showing**
   - **Check:** Is the spinner style properly configured?
   - **Check:** Are required dependencies installed?
   - **Check:** Is CodeCompanion chat panel open (for lualine/heirline)?

3. **Performance issues**
   - **Check:** Are spinners being called excessively?
   - **Fix:** Implement debouncing for high-frequency events

### Debug Mode
Enable debug logging by setting:
```lua
vim.g.codecompanion_spinner_debug = true
```

### State Inspection
Check current state programmatically:
```lua
local tracker = require("codecompanion._extensions.spinner.tracker")
print("Current state:", tracker.get_current_state())
print("State name:", tracker.state_map[tracker.get_current_state()])
```

## Support

For issues and feature requests, please use the GitHub repository's issue tracker.