-- Default globals for all files
globals = { "vim" }

-- Overrides for test files
files["tests/"] = {
  globals = {
    "vim",
    "describe",
    "it",
    "before_each",
    "after_each",
    "setup",
    "teardown",
    "context",
    "assert",
    "spy",
    "stub"
  },
  ignore = { "211", "212", "213", "214" } -- Ignore unused loop variables
}
