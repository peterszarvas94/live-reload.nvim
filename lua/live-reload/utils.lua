---@param exec string
---@return {buf: number}
local run_job = function(exec)
	local current_buf = vim.api.nvim_get_current_buf()

	local buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_set_current_buf(buf)
	vim.cmd.terminal(exec)

	vim.api.nvim_set_current_buf(current_buf)

	-- reset cursor
	-- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Right><Esc>", true, false, true), "n", true)

	return { buf = buf }
end

---@class TerminalInfo
---@field buf number
---@field exec string

---@class State
---@field [string] TerminalInfo

---@class Utils
---@field module Module
---@field _init fun(module: Module): Utils
---@field _setup fun()
---@field state State
---@field buf_delete fun(buf: number)
---@field get_runner_by_match fun(filepath: string): Runner?
---@field run_terminal fun(pattern: string, exec: string)
---@field start fun()

---@type Utils
---@diagnostic disable-next-line: missing-fields
local M = {}

M.state = {
	--[[
	some_pattern = {
		buf = -1,
		exec = ""
	},
	]]
}

M._init = function(module)
	M.module = module
	return M
end

M._setup = function()
	if M.module == nil then
		print("Module is not setup for utils")
	end

	M.buf_delete = function(buf)
		if vim.api.nvim_buf_is_valid(buf) then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end

	M.get_runner_by_match = function(filepath)
		for _, runner in ipairs(M.module.config.runners) do
			if filepath:match(runner.pattern) ~= nil then
				return runner
			end
		end
		return nil
	end

	M.run_terminal = function(pattern, exec)
		-- already in state, kill buff
		-- PERF: reuse buffer, don't recreate
		if M.state[pattern] then
			M.buf_delete(M.state[pattern].buf)
		end

		-- run new job
		local job = run_job(exec)

		-- reset state
		M.state[pattern] = {
			buf = job.buf,
			exec = exec,
		}
	end

	M.start = function()
		for _, runner in ipairs(M.module.config.runners) do
			M.run_terminal(runner.pattern, runner.exec)
		end
	end
end

return M
