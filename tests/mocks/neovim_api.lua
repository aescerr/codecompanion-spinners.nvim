-- Mock Neovim API for testing
local M = {}

-- Mock storage for autocmds and augroups
M._autocmds = {}
M._augroups = {}
M._next_augroup_id = 1000
M._next_autocmd_id = 2000

-- Mock vim.api
M.api = {
  nvim_create_augroup = function(name, opts)
    local id = M._next_augroup_id
    M._next_augroup_id = M._next_augroup_id + 1
    M._augroups[id] = {
      name = name,
      opts = opts or {},
      autocmds = {}
    }
    return id
  end,

  nvim_create_autocmd = function(events, opts)
    local id = M._next_autocmd_id
    M._next_autocmd_id = M._next_autocmd_id + 1

    -- Support both single event and array of events
    local event_list = type(events) == "table" and events or {events}

    for _, event in ipairs(event_list) do
      if not M._autocmds[event] then
        M._autocmds[event] = {}
      end
      table.insert(M._autocmds[event], {
        id = id,
        opts = opts,
        callback = opts.callback
      })
    end

    return id
  end,

  nvim_del_augroup_by_id = function(id)
    M._augroups[id] = nil
  end,

  nvim_exec_autocmds = function(event, opts)
    opts = opts or {}
    local pattern = opts.pattern

    if M._autocmds[event] then
      for _, autocmd in ipairs(M._autocmds[event]) do
        -- Check if pattern matches
        if not pattern or autocmd.opts.pattern == pattern then
          if autocmd.callback then
            autocmd.callback({
              match = pattern or event,
              event = event
            })
          end
        end
      end
    end
  end,

  nvim_get_current_buf = function()
    return 1 -- Mock buffer ID
  end,

  nvim_buf_get_name = function(bufnr)
    return "/mock/path/file.lua" -- Mock file path
  end,

  nvim_win_get_cursor = function(winid)
    return {5, 10} -- Mock cursor position
  end,

  nvim_win_get_position = function(winid)
    return {100, 200} -- Mock window position
  end,

  nvim_open_win = function(bufnr, enter, opts)
    return 999 -- Mock window ID
  end,

  nvim_win_close = function(winid, force)
    -- Mock window close
  end,

   nvim_create_buf = function(listed, scratch)
     return 1000 + math.random(1000) -- Mock buffer ID
   end,

   nvim_buf_set_lines = function(bufnr, start, end_, strict, lines)
     -- Mock buffer line setting
   end,

  nvim_create_namespace = function(name)
    return 3000 -- Mock namespace ID
  end,

  nvim_buf_add_highlight = function(bufnr, ns_id, hl_group, line, col_start, col_end)
    -- Mock highlighting
  end,

   nvim_buf_clear_namespace = function(bufnr, ns_id, line_start, line_end)
     -- Mock namespace clearing
   end,

   nvim_buf_set_extmark = function(bufnr, ns_id, line, col, opts)
     -- Mock setting extmark
   end,

   nvim_win_is_valid = function(win)
     return true -- Mock window is valid
   end,

   nvim_buf_is_valid = function(buf)
     return true -- Mock buffer is valid
   end,

   nvim_win_set_config = function(win, config)
     -- Mock setting window config
   end,

   nvim_set_option_value = function(name, value, opts)
     -- Mock setting option value
   end
}

-- Mock vim.fn
M.fn = {
  search = function(pattern, flags)
    return 0 -- Mock search result (no match)
  end,

  searchcount = function(opts)
    return { total = 0, current = 0 } -- Mock search count
  end,

  fnamemodify = function(path, mods)
    if mods == ":t" then
      return "mock_file.lua"
    end
    return path
  end,

  line = function(expr)
    return 10 -- Mock line number
  end,

  col = function(expr)
    return 5 -- Mock column number
  end,

  getline = function(lnum)
    return "mock line content" -- Mock line content
  end,

  stdpath = function(what)
    return "/mock/path" -- Mock standard path
  end,

  filereadable = function(file)
    return true -- Mock file exists
  end,

  isdirectory = function(dir)
    return true -- Mock directory exists
  end
}

-- Mock vim.o (options)
M.o = {
  lines = 24,
  columns = 80,
  cmdheight = 1,
  laststatus = 2
}

-- Mock vim.opt
M.opt = {
  fileencoding = { get = function() return "utf-8" end },
  fileformat = { get = function() return "unix" end }
}

-- Mock vim.loop (libuv)
M.loop = {
  hrtime = function()
    return 1000000000 -- Mock nanosecond timestamp
  end,

  new_timer = function()
    return {
      start = function() end,
      stop = function() end,
      close = function() end
    }
  end
}

-- Mock vim.schedule
M.schedule = function(fn)
  fn() -- Execute immediately for testing
end

-- Mock vim.defer_fn
M.defer_fn = function(fn, delay)
  fn() -- Execute immediately for testing (ignore delay)
end

-- Mock vim.cmd
M.cmd = function(cmd)
  -- Mock vim command execution
  print("vim.cmd: " .. cmd)
end

-- Mock vim.notify
M.notify = function(msg, level, opts)
  print(string.format("[NOTIFY %s] %s", level or "INFO", msg))
end

-- Mock vim.log
M.log = {
  levels = {
    INFO = "info",
    WARN = "warn",
    ERROR = "error",
    DEBUG = "debug"
  }
}

-- Mock vim.highlight
M.highlight = {
  priorities = {
    user = 100
  }
}

-- Mock vim.tbl_deep_extend
M.tbl_deep_extend = function(behavior, ...)
  -- Simple mock implementation
  local result = {}
  for i = 1, select('#', ...) do
    local tbl = select(i, ...)
    if type(tbl) == "table" then
      for k, v in pairs(tbl) do
        result[k] = v
      end
    end
  end
  return result
end

-- Mock vim.schedule_wrap
M.schedule_wrap = function(fn)
  return fn -- Execute immediately in test environment
end

-- Helper to reset mock state
M.reset = function()
  M._autocmds = {}
  M._augroups = {}
  M._next_augroup_id = 1000
  M._next_autocmd_id = 2000
end

return M