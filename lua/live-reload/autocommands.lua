local utils = require("live-reload.utils")

---@class AutoCommands
---@field module Module
---@field _init fun(module: Module): AutoCommands
---@field _setup fun()

---@type AutoCommands
---@diagnostic disable-next-line: missing-fields
local M = {}

M.module = nil

M._init = function(module)
	M.module = module
	return M
end

M._setup = function()
	if M.module == nil then
		print("Module is not set up in autocommands")
		return
	end

	local uv = vim.loop

	local watcher = uv.new_fs_event()

	local path_to_watch = uv.cwd() -- Watch the current working directory

	local last_event_time = 0
	local debounce_ms = 100

	---@diagnostic disable-next-line: unused-local
	watcher:start(path_to_watch, { recursive = true }, function(err, fname, status)
		if err then
			print("Error watching files:", err)
			return
		end

		if not M.module.config.enabled then
			return
		end

		-- Filter out Vim's temporary files
		if fname:match("4913$") then
			return
		end

		local current_time = uv.now()
		if (current_time - last_event_time) < debounce_ms then
			return
		end
		last_event_time = current_time

		vim.defer_fn(function()
			vim.schedule(function()
				local runner = utils.get_runner_by_match(fname)
				if runner and fname then
					utils.run_terminal(runner.pattern, runner.exec)
				end
			end)
		end, 100)
	end)

	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			watcher:stop()
			watcher:close()
		end,
	})
end

return M
