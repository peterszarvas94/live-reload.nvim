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

local last_event_time = 0
local last_fname = ""
local debounce_ms = 1000

M._setup = function()
	if M.module == nil then
		print("Module is not set up in autocommands")
		return
	end

	local uv = vim.loop

	local watcher = uv.new_fs_event()

	local path_to_watch = uv.cwd() -- Watch the current working directory

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
		if (current_time - last_event_time) < debounce_ms and last_fname == fname then
			return
		end

		last_event_time = current_time
		last_fname = fname

		local runner = utils.get_runner_by_match(fname)

		vim.schedule(function()
			if runner ~= nil then
				utils.run_terminal(runner.pattern, runner.exec)
				print("fname: ", fname)
				print("runner running: ", runner.exec)
			end
		end)
	end)

	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			watcher:stop()
			watcher:close()
		end,
	})
end

return M
