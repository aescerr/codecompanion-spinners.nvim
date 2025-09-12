#!/usr/bin/env lua

-- Test runner for CodeCompanion Spinners
-- Run with: lua tests/run_tests.lua

-- Setup package path
package.path = package.path .. ";./lua/?.lua;./tests/?.lua"

-- Load test framework
local busted = require("busted")
local runner = require("busted.runner")

-- Setup test environment
require("tests.minimal_init").setup()

-- Configure busted
runner({
  verbose = true,
  colors = true,
  pattern = "_spec.lua$",
  root = "./tests"
})

-- Run the tests
return runner.run()