local utils = require("live-reload.utils")
local state = require("live-reload.state")
local telescope = require("live-reload.telescope")
local watcher = require("live-reload.watcher")

---@class UserCommands
---@field _setup fun(config: Config)

---@type UserCommands
---@diagnostic disable-next-line: missing-fields
local M = {}

M._setup = function(config)
	vim.api.nvim_create_user_command("LiveReloadStart", function()
		if state.running then
			print("Live reload is already running")
			return
		end

		if #config.runners == 0 then
			print("There are no runners set up")
			return
		end

		utils.start_all(config)
		watcher.watch(config)
	end, {})

	vim.api.nvim_create_user_command("LiveReloadStop", function()
		if not state.running then
			print("Live reload is not running")
			return
		end

		assert(#state.terminals > 0)

		for _, terminal in ipairs(state.terminals) do
			utils.buf_delete(terminal.buf)
		end

		state:reset()

		print("All live-reload buffers are deleted")
	end, {})

	vim.api.nvim_create_user_command("LiveReloadState", function()
		print("Config:\n", vim.inspect(config))
		print("State:\n", vim.inspect(state))
	end, {})

	if telescope.is_installed() then
		vim.api.nvim_create_user_command("LiveReloadBuffers", function()
			if not state.running then
				print("Live reload not running")
				return
			end

			telescope.picker()
		end, {})
	end
end

return M
