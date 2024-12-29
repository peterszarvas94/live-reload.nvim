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
---@field enable fun()
---@field disable fun()

---@type Module
---@diagnostic disable-next-line: missing-fields
local M = {}

M.config = default_config

M.setup = function(opts)
	M.config = vim.tbl_deep_extend("force", default_config, opts or {})

	require("live-reload.utils")._init(M)._setup()
	require("live-reload.autocommands")._init(M)._setup()
	require("live-reload.usercommands")._init(M)._setup()
	require("live-reload.telescope")._setup()
end

M.enable = function()
	M.config.enabled = true
end

M.disable = function()
	M.config.enabled = false
end

return M
