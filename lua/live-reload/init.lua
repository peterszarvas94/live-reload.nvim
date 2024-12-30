---@class Runner
---@field pattern? string
---@field once? boolean
---@field exec string

---@class Config
---@field runners Runner[]

---@type Config
local default_config = {
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

---@type Module
---@diagnostic disable-next-line: missing-fields
local M = {}

M.config = default_config

M.setup = function(opts)
	M.config = vim.tbl_deep_extend("force", default_config, opts or {})

	M.load_config_file()

	require("live-reload.user_commands")._setup(M.config)
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

return M
