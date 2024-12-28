---@class TerminalInfo
---@field job_id number
---@field buf number
---@field exec string

---@class State
---@field [string] TerminalInfo

---@class Utils
---@field module Module
---@field _init fun(module: Module): Utils
---@field _setup fun()
---@field state State
---@field get_current_runner_by_match fun(): Runner?
---@field run_job fun(exec: string): {buf: number, job_id: number}
---@field kill_job_and_buff fun(job_id: number, buf: number)
---@field run_terminal fun(pattern: string, exec: string): TerminalInfo

---@type Utils
---@diagnostic disable-next-line: missing-fields
local M = {}

M.state = {
	--[[
	some_pattern = {
		job_id = -1,
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

	M.get_current_runner_by_match = function()
		local bufnr = vim.api.nvim_get_current_buf()
		local filepath = vim.api.nvim_buf_get_name(bufnr)

		for _, runner in ipairs(M.module.config.runners) do
			if filepath:match(runner.pattern) ~= nil then
				return runner
			end
		end
		return nil
	end

	M.run_job = function(exec)
		local buf = vim.api.nvim_create_buf(true, false)
		vim.api.nvim_set_current_buf(buf)
		local job_id = vim.fn.termopen(exec)

		return { buf = buf, job_id = job_id }
	end

	M.kill_job_and_buff = function(job_id, buf)
		vim.fn.jobstop(job_id)
		if vim.api.nvim_buf_is_valid(buf) then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end

	M.run_terminal = function(pattern, exec)
		-- already in state, kill job and buff
		-- PERF: reuse buffer, don't recreate
		if M.state[pattern] then
			M.kill_job_and_buff(M.state[pattern].job_id, M.state[pattern].buf)
		end

		-- run new job
		local job = M.run_job(exec)

		-- reset state
		--- @type TerminalInfo
		local info = {
			job_id = job.job_id,
			buf = job.buf,
			exec = exec,
		}

		M.state[pattern] = info

		return info
	end
end

return M
