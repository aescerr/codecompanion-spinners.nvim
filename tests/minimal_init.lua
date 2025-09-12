-- Minimal Neovim configuration for testing
vim.cmd [[
  set runtimepath+=.
  set runtimepath+=./tests
]]

-- Mock vim.api for testing
vim.api = vim.api or {}
vim.api.nvim_create_augroup = vim.api.nvim_create_augroup or function() return 1 end
vim.api.nvim_create_autocmd = vim.api.nvim_create_autocmd or function() end
vim.api.nvim_del_augroup_by_id = vim.api.nvim_del_augroup_by_id or function() end

-- Mock vim.notify
vim.notify = vim.notify or function(msg, level, opts)
  print(string.format("[NOTIFY %s] %s", level or "INFO", msg))
end

-- Mock vim.loop for timing
vim.loop = vim.loop or {
  hrtime = function() return 1000000000 end -- Mock nanosecond time
}

-- Mock vim.cmd
vim.cmd = vim.cmd or function(cmd)
  print("vim.cmd: " .. cmd)
end

return {
  setup = function()
    -- Setup test environment
    package.path = package.path .. ";./lua/?.lua"
  end
}