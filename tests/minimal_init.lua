-- Minimal Neovim initialization for testing
local test_env = require("tests.helpers.test_env")

-- Setup test environment
test_env.setup()

return {
  setup = test_env.setup,
  teardown = test_env.teardown,
}
