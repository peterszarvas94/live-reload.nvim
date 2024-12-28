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

	vim.api.nvim_create_autocmd("BufWritePost", {
		pattern = "*",
		callback = function()
			if M.module.config.enabled == false then
				-- live reload is disabled
				return
			else
				-- live reload is enabled
				local runner = utils.get_current_runner_by_match()
				if runner ~= nil then
					utils.run_terminal(runner.pattern, runner.exec)
				end
			end
		end,
	})
end

return M
