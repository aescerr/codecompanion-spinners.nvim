# Contributing to CodeCompanion Spinners

Thank you for your interest in contributing to `codecompanion-spinners.nvim`! This document provides guidelines and information for contributors.

## 🚀 Ways to Contribute

### 🐛 Reporting Issues
- Use the [GitHub Issues](https://github.com/lalitmee/codecompanion-spinners.nvim/issues) page
- Provide detailed steps to reproduce the issue
- Include your Neovim version, CodeCompanion version, and relevant configuration
- Add screenshots or videos if the issue is visual

### 💡 Suggesting Features
- Open a [GitHub Discussion](https://github.com/lalitmee/codecompanion-spinners.nvim/discussions) for feature requests
- Describe the problem you're trying to solve
- Explain why this feature would be useful to other users
- Consider if the feature aligns with the project's scope

### 🛠️ Contributing Code
- Fork the repository
- Create a feature branch from `master`
- Make your changes
- Test thoroughly
- Submit a pull request

## 🏗️ Development Setup

### Prerequisites
- Neovim 0.9+
- [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) (main plugin)
- Git

### Local Development
1. Clone your fork:
   ```bash
   git clone https://github.com/yourusername/codecompanion-spinners.nvim.git
   cd codecompanion-spinners.nvim
   ```

2. Set up the plugin in your Neovim configuration:
   ```lua
   -- Add to your plugin manager
   {
     "olimorris/codecompanion.nvim",
     dependencies = {
       "lalitmee/codecompanion-spinners.nvim", -- Your local path
     },
     opts = {
       extensions = {
         spinner = {
           enabled = true,
           opts = {
             style = "cursor-relative", -- Test different styles
           },
         },
       },
     },
   }
   ```

3. Test your changes by triggering CodeCompanion requests and observing spinner behavior

## 📝 Code Style Guidelines

### Lua Style
- Follow [LuaRocks style guidelines](https://github.com/luarocks/lua-style-guide)
- Use consistent indentation (2 spaces)
- Add comments for complex logic
- Use meaningful variable and function names

### Neovim Plugin Conventions
- Follow Neovim Lua API best practices
- Handle errors gracefully with `pcall`
- Use appropriate logging levels
- Respect user configuration and defaults

### Example Code Structure
```lua
-- Good: Clear function with documentation
--- Creates a new spinner instance
--- @param config table Configuration options
--- @return table Spinner instance
function M.create_spinner(config)
  local spinner = {
    config = config,
    state = "idle"
  }

  -- Validate configuration
  if not config.style then
    vim.notify("Spinner style is required", vim.log.levels.ERROR)
    return nil
  end

  return spinner
end
```

## 🧪 Testing

### Manual Testing
1. Test all spinner styles: `cursor-relative`, `fidget`, `snacks`, `native`, `none`
2. Test different CodeCompanion events:
   - Request start/finish
   - Tool execution
   - Diff operations
   - Error states

3. Test edge cases:
   - Rapid successive requests
   - Long-running operations
   - Configuration changes during runtime
   - Error handling

### Automated Testing (Future)
We plan to add automated tests using:
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for unit tests
- Integration tests with CodeCompanion
- CI/CD with GitHub Actions

## 📋 Pull Request Process

### Before Submitting
- [ ] Test your changes thoroughly
- [ ] Update documentation if needed
- [ ] Follow commit message guidelines
- [ ] Ensure no breaking changes without discussion

### PR Template
Please include:
1. **Description**: What does this PR do?
2. **Type**: Bug fix, feature, documentation, etc.
3. **Testing**: How did you test this?
4. **Breaking Changes**: Does this break anything?
5. **Screenshots**: For UI changes

### Review Process
1. Automated checks (if any) must pass
2. At least one maintainer review required
3. All feedback addressed
4. Approved and merged by maintainer

## 📝 Commit Message Guidelines

We follow conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

### Types
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation
- `style:` - Code style changes
- `refactor:` - Code refactoring
- `test:` - Testing
- `chore:` - Maintenance

### Examples
```
feat: Add native spinner style with floating window support

- Implement highly configurable floating window spinner
- Add window position, size, and border customization
- Support animated title with CodeCompanion branding

fix: Resolve lualine spinner display issue

- Remove buffer filetype check that prevented global display
- Update component to show status regardless of current buffer
- Add chat state tracking for conditional visibility

docs: Update README with native spinner configuration examples

- Add advanced configuration examples for window positioning
- Include transparency and border styling options
- Document all available window configuration parameters
```

## 🎯 Development Workflow

### Branch Strategy
- `master` - Main branch, always stable
- `feature/*` - New features
- `fix/*` - Bug fixes
- `docs/*` - Documentation updates

### Code Review
- All PRs require review
- Be constructive and respectful
- Focus on code quality and user experience
- Suggest improvements, don't demand changes

## 📚 Resources

### CodeCompanion
- [Main Repository](https://github.com/olimorris/codecompanion.nvim)
- [Documentation](https://codecompanion.olimorris.dev/)
- [Discussions](https://github.com/olimorris/codecompanion.nvim/discussions)

### Neovim Development
- [Neovim Lua Guide](https://neovim.io/doc/user/lua-guide.html)
- [Neovim API Documentation](https://neovim.io/doc/user/api.html)
- [Plugin Development Guide](https://neovim.io/doc/user/develop.html)

## 🤝 Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help newcomers learn and contribute
- Maintain professional communication
- Respect different viewpoints and experiences

## 📞 Getting Help

- **Issues**: For bugs and feature requests
- **Discussions**: For questions and ideas
- **Discord**: For real-time chat (if available)

Thank you for contributing to `codecompanion-spinners.nvim`! 🎉