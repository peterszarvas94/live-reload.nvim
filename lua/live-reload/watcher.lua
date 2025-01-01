local utils = require("live-reload.utils")
local state = require("live-reload.state")

---@class WatcherState
---@field last_event_time number
---@field last_fname string
---@field debounce_ms number

---@class Watcher
---@field state WatcherState
---@field watch fun(config: Config)

---@type Watcher
---@diagnostic disable-next-line: missing-fields
local M = {}

M.state = {
	last_event_time = 0,
	last_fname = "",
	debounce_ms = 1000,
}

M.watch = function(config)
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

		if not state.running then
			return
		end

		-- filter out vim's temporary files
		if fname:match("4913$") then
			return
		end

		local current_time = uv.now()
		if (current_time - M.state.last_event_time) < M.state.debounce_ms and M.state.last_fname == fname then
			return
		end

		M.state.last_event_time = current_time
		M.state.last_fname = fname

		local runner = utils.get_runner_by_match(fname, config)

		if runner ~= nil then
			vim.schedule(function()
				utils.keep_win_and_buf(function()
					utils.run_watch(runner)
				end)
			end)
		end

		local runner2 = utils.get_runner_by_callback(fname, config)
		if runner2 ~= nil then
			vim.schedule(function()
				utils.keep_win_and_buf(function()
					utils.run_callback(runner2, fname)
				end)
			end)
		end
	end)

	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			watcher:stop()
			watcher:close()
		end,
	})
end

return M
