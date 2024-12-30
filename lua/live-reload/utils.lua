local state = require("live-reload.state")

---@param exec string
---@return {buf: number}
local run_job = function(exec)
	local current_buf = vim.api.nvim_get_current_buf()

	local buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_set_current_buf(buf)
	vim.cmd.terminal(exec)

	vim.api.nvim_set_current_buf(current_buf)

	-- reset cursor
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Right><Esc>", true, false, true), "n", true)

	return { buf = buf }
end

---@class Utils
---@field buf_delete fun(buf: number)
---@field get_runner_by_match fun(filepath: string, config: Config): Runner?
---@field run_watch fun(pattern: string, exec: string)
---@field run_once fun(exec: string)

---@type Utils
---@diagnostic disable-next-line: missing-fields
local M = {}

M.buf_delete = function(buf)
	assert(state.running)

	if vim.api.nvim_buf_is_valid(buf) then
		vim.api.nvim_buf_delete(buf, { force = true })
	end
end

M.get_runner_by_match = function(filepath, config)
	assert(state.running)

	---@type Runner?
	local runner = nil
	for _, config_runner in ipairs(config.runners) do
		if config_runner.pattern and filepath:match(config_runner.pattern) ~= nil and runner == nil then
			runner = config_runner
		end
	end
	return runner
end

M.run_watch = function(pattern, exec)
	assert(state.running)

	if state.reload_runners[pattern] then
		M.buf_delete(state.reload_runners[pattern].buf)
	end

	-- not running, start new job
	local job = run_job(exec)

	-- reset state
	state.reload_runners[pattern] = {
		buf = job.buf,
		exec = exec,
	}
end

M.run_once = function(exec)
	assert(state.running)

	--- already running
	for _, runner in ipairs(state.once_runners) do
		if runner.exec == exec then
			return
		end
	end

	local job = run_job(exec)

	table.insert(state.once_runners, {
		buf = job.buf,
		exec = exec,
	})
end

return M
