local utils = require("live-reload.utils")

---@class UserCommands
---@field module Module
---@field _init fun(module: Module): UserCommands
---@field _setup fun()

---@type UserCommands
---@diagnostic disable-next-line: missing-fields
local M = {}

M.module = nil

M._init = function(module)
	M.module = module
	return M
end

M._setup = function()
	if M.module == nil then
		print("Module is not set up in usercommands")
		return
	end

	-- vim.api.nvim_create_user_command("LiveReloadTermShow", function()
	-- 	if utils.state.buf ~= -1 and vim.api.nvim_buf_is_valid(utils.state.buf) then
	-- 		vim.api.nvim_set_current_buf(utils.state.buf)
	-- 	else
	-- 	  print("No buf")
	-- 	end
	-- end, {})

	vim.api.nvim_create_user_command("LiveReloadTermKill", function()
		if #pairs(utils.state) == 0 then
			print("No buf")
		else
			for _, value in pairs(utils.state) do
				utils.kill_job_and_buff(value.job_id, value.buf)
				print("Killed", value.buf)
			end
		end
	end, {})

	vim.api.nvim_create_user_command("LiveReloadEnable", function()
		M.module.enable()
		print("Live reload is enabled")
	end, {})

	vim.api.nvim_create_user_command("LiveReloadDisable", function()
		M.module.disable()
		print("Live reload is disabled")
	end, {})

	vim.api.nvim_create_user_command("LiveReloadState", function()
		if M.module.config.enabled then
			print("Live reload is enabled")
		else
			print("Live reload is disabled")
		end

		-- TODO: print more state
	end, {})
end

return M
