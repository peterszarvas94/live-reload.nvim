local state = require("live-reload.state")

--- FUNCTIONS ---

---@param exec string
---@return {buf: number}
local run_job = function(exec)
	local buf = vim.api.nvim_create_buf(true, false)

	vim.api.nvim_set_current_buf(buf)
	vim.cmd.terminal(exec)

	return { buf = buf }
end

---@param pattern string
---@param exec string
---@return { index: number, terminal: Terminal }?
local find_watch_terminal = function(pattern, exec)
	for index, terminal in ipairs(state.terminals) do
		if terminal.runner.pattern and terminal.runner.pattern == pattern and terminal.runner.exec == exec then
			return { index = index, terminal = terminal }
		end
	end
	return nil
end

---@param exec string
---@return Terminal?
local find_once_terminal = function(exec)
	for _, terminal in ipairs(state.terminals) do
		if terminal.runner.once and terminal.runner.exec == exec then
			return terminal
		end
	end
	return nil
end

---@param exec string
---@return { index: number, terminal: Terminal }?
local find_callback_terminal = function(exec)
	for index, terminal in ipairs(state.terminals) do
		if terminal.runner.callback ~= nil and terminal.runner.exec == exec then
			return { index = index, terminal = terminal }
		end
	end
	return nil
end

--- MODULE ---

---@class Utils
---@field buf_delete fun(buf: number)
---@field get_runner_by_match fun(filepath: string, config: Config): Runner?
---@field get_runner_by_callback fun(filepath: string, config: Config): Runner?
---@field keep_win_and_buf fun(callback: fun())
---@field run_watch fun(runner: Runner)
---@field run_once fun(exec: Runner)
---@field run_callback fun(runner: Runner, filename: string?)
---@field start_all fun(config: Config)

---@type Utils
---@diagnostic disable-next-line: missing-fields
local M = {}

M.buf_delete = function(buf)
	if vim.api.nvim_buf_is_valid(buf) then
		vim.api.nvim_buf_delete(buf, { force = true })
	end
end

M.get_runner_by_match = function(filepath, config)
	for _, config_runner in ipairs(config.runners) do
		if config_runner.pattern and filepath:match(config_runner.pattern) ~= nil then
			return config_runner
		end
	end

	return nil
end

M.get_runner_by_callback = function(filepath, config)
	for _, config_runner in ipairs(config.runners) do
		if config_runner.callback and config_runner.callback(filepath) then
			return config_runner
		end
	end
end

M.keep_win_and_buf = function(callback)
	local current_win = vim.api.nvim_get_current_win()
	local current_buf = vim.api.nvim_get_current_buf()

	callback()

	vim.api.nvim_set_current_win(current_win)
	vim.api.nvim_set_current_buf(current_buf)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc><Right>", true, false, true), "n", true)
end

M.run_watch = function(runner)
	local found = find_watch_terminal(runner.pattern, runner.exec)

	-- already running
	if found then
		assert(found.index > 0)

		M.buf_delete(found.terminal.buf)
		table.remove(state.terminals, found.index)
	end

	local job = run_job(runner.exec)

	table.insert(state.terminals, {
		runner = runner,
		buf = job.buf,
	})
end

M.run_once = function(runner)
	local found = find_once_terminal(runner.exec)

	--- already running
	if found then
		return
	end

	local job = run_job(runner.exec)

	table.insert(state.terminals, {
		runner = runner,
		buf = job.buf,
	})
end

M.run_callback = function(runner, filename)
	local found = find_callback_terminal(runner.exec)

	if filename ~= nil and not runner.callback(filename) then
		return
	end

	--- already running
	if found then
		assert(found.index > 0)

		M.buf_delete(found.terminal.buf)
		table.remove(state.terminals, found.index)
	end

	local job = run_job(runner.exec)

	table.insert(state.terminals, {
		runner = runner,
		buf = job.buf,
	})
end

M.start_all = function(config)
	M.keep_win_and_buf(function()
		for _, runner in ipairs(config.runners) do
			if runner.pattern and not (runner.once or runner.callback) then
				M.run_watch(runner)
			elseif runner.once and not (runner.pattern or runner.callback) then
				M.run_once(runner)
			elseif runner.callback and not (runner.pattern or runner.once) then
				M.run_callback(runner)
			else
				print("Wrong config for runner: ", vim.inpsect(runner))
			end
		end
	end)

	state.running = true
end

return M
