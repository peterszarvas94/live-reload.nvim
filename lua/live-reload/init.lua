---@class Runner
---@field pattern string
---@field exec string

---@class Config
---@field enabled boolean
---@field runners Runner[]

---@type Config
local default_config = {
	enabled = false,
	runners = {
		--[[
		{
		  pattern = '%.go$',
		  exec = 'go run main.go',
		},
		]]
	},
}

---@class Module
---@field config Config
---@field setup fun(opts?: Config)
---@field load_config_file fun()
---@field enable fun()
---@field disable fun()

---@type Module
---@diagnostic disable-next-line: missing-fields
local M = {}

M.config = default_config

M.setup = function(opts)
	M.config = vim.tbl_deep_extend("force", default_config, opts or {})

	M.load_config_file()

	require("live-reload.utils")._init(M)._setup()
	require("live-reload.watcher")._init(M)._setup()
	require("live-reload.user_commands")._init(M)._setup()
	require("live-reload.telescope")._setup()
end

M.load_config_file = function()
	local config_path = vim.loop.cwd() .. "/live-reload.lua"
	if vim.fn.filereadable(config_path) == 1 then
		local config = dofile(config_path)
		-- TODO: check config types
		if config ~= nil then
			M.config.runners = config
		end
	end
end

M.enable = function()
	M.config.enabled = true
end

M.disable = function()
	M.config.enabled = false
end

return M
