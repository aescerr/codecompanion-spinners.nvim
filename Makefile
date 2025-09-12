# Makefile for CodeCompanion Spinners

.PHONY: test test-unit test-integration test-all clean help

# Default target
help:
	@echo "Available targets:"
	@echo "  test           - Run all tests"
	@echo "  test-unit      - Run unit tests only"
	@echo "  test-integration - Run integration tests only"
	@echo "  test-all       - Run all tests with verbose output"
	@echo "  clean          - Clean test artifacts"
	@echo "  help           - Show this help"

# Test targets
test:
	@echo "Running all tests..."
	@lua tests/run_tests.lua

test-unit:
	@echo "Running unit tests..."
	@lua -e "package.path = package.path .. ';./lua/?.lua;./tests/?.lua'" \
		-l tests.minimal_init \
		-e "require('busted.runner')({ pattern = 'tests/unit/*_spec.lua' })"

test-integration:
	@echo "Running integration tests..."
	@lua -e "package.path = package.path .. ';./lua/?.lua;./tests/?.lua'" \
		-l tests.minimal_init \
		-e "require('busted.runner')({ pattern = 'tests/integration/*_spec.lua' })"

test-all:
	@echo "Running all tests with verbose output..."
	@lua -e "package.path = package.path .. ';./lua/?.lua;./tests/?.lua'" \
		-l tests.minimal_init \
		-e "require('busted.runner')({ verbose = true, colors = true, pattern = 'tests/**/*_spec.lua' })"

# Clean target
clean:
	@echo "Cleaning test artifacts..."
	@rm -rf .busted
	@rm -rf luacov.report.out
	@rm -rf luacov.stats.out

# Development helpers
install-deps:
	@echo "Installing test dependencies..."
	@luarocks install busted
	@luarocks install luacov

# CI/CD target
ci-test:
	@echo "Running CI tests..."
	@lua -e "package.path = package.path .. ';./lua/?.lua;./tests/?.lua'" \
		-l tests.minimal_init \
		-e "require('busted.runner')({ pattern = 'tests/**/*_spec.lua', verbose = true })"