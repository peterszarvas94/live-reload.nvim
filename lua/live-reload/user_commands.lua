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

	vim.api.nvim_create_user_command("LiveReloadKill", function()
		if vim.tbl_count(utils.state) == 0 then
			print("No buf")
		else
			for key, value in pairs(utils.state) do
				utils.buf_delete(value.buf)
				utils.state[key] = nil
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

	vim.api.nvim_create_user_command("LiveReloadStart", function()
		if M.module.config.enabled then
			utils.start()
		end

		-- TODO: print more state
	end, {})
end

return M
