# Makefile for CodeCompanion Spinners Testing

.PHONY: test test-unit test-integration test-coverage clean help install-deps ci-test

# Default target
help:
	@echo "Available targets:"
	@echo "  test           - Run all tests"
	@echo "  test-unit      - Run unit tests only"
	@echo "  test-integration - Run integration tests only"
	@echo "  test-coverage  - Run tests with coverage report"
	@echo "  clean          - Clean test artifacts and coverage reports"
	@echo "  install-deps   - Install test dependencies"
	@echo "  ci-test        - Run tests for CI environment"
	@echo "  help           - Show this help"

# Test targets
test:
	@echo "🧪 Running all tests..."
	@eval $$(luarocks path) && busted ./tests --pattern=_spec.lua$$ --helper=./tests/minimal_init.lua --verbose

test-unit:
	@echo "🧪 Running unit tests..."
	@eval $$(luarocks path) && LUA_PATH="$$LUA_PATH;./lua/?.lua;./tests/?.lua" lua -e "package.path = package.path .. ';./lua/?.lua;./tests/?.lua'" \
		-l tests.minimal_init \
		-e "require('busted.runner')({ pattern = 'tests/unit/*_spec.lua', verbose = true, colors = true })"

test-integration:
	@echo "🧪 Running integration tests..."
	@eval $$(luarocks path) && LUA_PATH="$$LUA_PATH;./lua/?.lua;./tests/?.lua" lua -e "package.path = package.path .. ';./lua/?.lua;./tests/?.lua'" \
		-l tests.minimal_init \
		-e "require('busted.runner')({ pattern = 'tests/integration/*_spec.lua', verbose = true, colors = true })"

test-coverage:
	@echo "🧪 Running tests with coverage..."
	@eval $$(luarocks path) && LUA_PATH="$$LUA_PATH;./lua/?.lua;./tests/?.lua" lua -e "package.path = package.path .. ';./lua/?.lua;./tests/?.lua'" \
		-l tests.minimal_init \
		-e "require('busted.runner')({ pattern = 'tests/**/*_spec.lua', verbose = true, colors = true, coverage = true })"
	@echo "📊 Coverage report generated in luacov.report.out"

# Clean target
clean:
	@echo "🧹 Cleaning test artifacts..."
	@rm -rf .busted
	@rm -rf luacov.report.out
	@rm -rf luacov.stats.out
	@rm -f *.out

# Install dependencies
install-deps:
	@echo "📦 Installing test dependencies..."
	@command -v luarocks >/dev/null 2>&1 || { echo "❌ LuaRocks not found. Please install LuaRocks first."; exit 1; }
	@luarocks install busted --local
	@luarocks install luacov --local
	@luarocks install luafilesystem --local
	@echo "✅ Dependencies installed"

# CI test target
ci-test:
	@echo "🚀 Running CI tests..."
	@eval $$(luarocks path) && LUA_PATH="$$LUA_PATH;./lua/?.lua;./tests/?.lua" lua -e "package.path = package.path .. ';./lua/?.lua;./tests/?.lua'" \
		-l tests.minimal_init \
		-e "require('busted.runner')({ pattern = 'tests/**/*_spec.lua', verbose = false, coverage = true })"

# Development helpers
test-watch:
	@echo "👀 Watching for file changes..."
	@while true; do \
		inotifywait -qre modify ./lua ./tests; \
		echo "🔄 Files changed, running tests..."; \
		make test; \
	done

# Performance testing
perf-test:
	@echo "⚡ Running performance tests..."
	@eval $$(luarocks path) && LUA_PATH="$$LUA_PATH;./lua/?.lua;./tests/?.lua" lua -e "package.path = package.path .. ';./lua/?.lua;./tests/?.lua'" \
		-l tests.minimal_init \
		-e "require('tests.performance_spec')"

# Formatting
format:
	@echo "🎨 Formatting code..."
	@./stylua --config-path .stylua.toml lua/ tests/

# Linting
lint:
	@echo "🔍 Running linter..."
	@luacheck lua/ tests/ --globals vim --ignore 611 612 613 614

# Documentation
docs:
	@echo "📚 Generating documentation..."
	@ldoc -d docs/api lua/

# Full development cycle
dev: clean install-deps format lint test-coverage docs
	@echo "🎉 Full development cycle complete!"