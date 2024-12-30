local utils = require("live-reload.utils")
local state = require("live-reload.state")

---@class WatcherState
---@field last_event_time number
---@field last_fname string
---@field debounce_ms number

---@class Watcher
---@field state WatcherState
---@field start fun(config: Config)

---@type Watcher
---@diagnostic disable-next-line: missing-fields
local M = {}

M.state = {
	last_event_time = 0,
	last_fname = "",
	debounce_ms = 1000,
}

M.start = function(config)
	assert(not state.running)

	state.running = true

	--- start all runners
	for _, runner in ipairs(config.runners) do
		if (runner.pattern and runner.once) or (not runner.pattern and not runner.once) then
			print('Invalid configuration: set either "pattern" or "once", but not both or neither')
			goto continue
		end

		if runner.pattern then
			utils.run_watch(runner.pattern, runner.exec)
		elseif runner.once then
			utils.run_once(runner.exec)
		end

		::continue::
	end

	--- start file watcher
	local uv = vim.loop
	local watcher = uv.new_fs_event()
	local path_to_watch = uv.cwd()

	---@diagnostic disable-next-line: unused-local
	watcher:start(path_to_watch, { recursive = true }, function(err, fname, status)
		if err then
			print("Error watching files:", err)
			return
		end

		-- Filter out Vim's temporary files
		if fname:match("4913$") then
			return
		end

		local current_time = uv.now()
		if
			(current_time - M.state.last_event_time) < M.state.debounce_ms
			and M.state.last_fname == fname
		then
			return
		end

		M.state.last_event_time = current_time
		M.state.last_fname = fname

		local runner = utils.get_runner_by_match(fname, config)

		vim.schedule(function()
			if runner ~= nil then
				utils.run_watch(runner.pattern, runner.exec)
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
