#!/usr/bin/env lua

-- Comprehensive test runner for CodeCompanion Spinners
-- Run with: lua tests/run_tests.lua

-- Setup package path
package.path = package.path .. ";./lua/?.lua;./tests/?.lua"

-- Load test environment
local test_env = require("tests.minimal_init")

-- Load test framework
local busted = require("busted")
local runner = require("busted.runner")

-- Run the tests
local success = runner({
  verbose = true,
  colors = true,
  pattern = "_spec.lua$",
  root = "./tests",
  output = "utfTerminal"
})

-- Exit with appropriate code
os.exit(success and 0 or 1)