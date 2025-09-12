# Test Suite

This directory contains the comprehensive test suite for CodeCompanion Spinners.

## Quick Start

```bash
# Run all tests
make test

# Run specific test types
make test-unit
make test-integration

# Run with verbose output
make test-all
```

## Test Structure

### Unit Tests (`tests/unit/`)
- **config_spec.lua**: Tests configuration management, merging, validation
- **tracker_spec.lua**: Tests state management and event handling

### Integration Tests (`tests/integration/`)
- **spinner_styles_spec.lua**: Tests all spinner style implementations
- **extension_spec.lua**: Tests the main extension setup and loading

## Writing Tests

Tests use the [busted](https://lunarmodules.github.io/busted/) framework. Example:

```lua
describe("My Module", function()
  it("should do something", function()
    assert.equals(expected, actual)
  end)
end)
```

## Test Environment

- **minimal_init.lua**: Sets up a minimal Neovim environment for testing
- **run_tests.lua**: Main test runner script
- Uses mocked Neovim APIs for isolated testing

## Coverage

The test suite covers:
- ✅ Configuration management
- ✅ State tracking and transitions
- ✅ Event handling
- ✅ Spinner style loading
- ✅ Extension setup
- ✅ Error handling

## Dependencies

Tests require:
- [busted](https://lunarmodules.github.io/busted/) - Lua testing framework
- [luacov](https://github.com/lunarmodules/luacov) - Code coverage (optional)

Install with:
```bash
make install-deps
```