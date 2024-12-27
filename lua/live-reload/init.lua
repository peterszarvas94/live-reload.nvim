---@diagnostic disable: duplicate-set-field
---@diagnostic disable: duplicate-doc-field

---@class Language
---@field pattern string
---@field exec string

---@class Config
---@field enabled boolean
---@field languages Language[]

---@class Module
---@field config Config Module configuration
---@field setup fun(opts?: Config) Set up the module
---@field enable fun() Enable live reload
---@field disable fun() Disable live reload

---@type Module
---@diagnostic disable-next-line: missing-fields
local M = {}

---@type Config
local default_config = {
	enabled = false,
	languages = {},
}

M.config = default_config

---@param opts? Config
M.setup = function(opts)
	M.config = vim.tbl_deep_extend("force", default_config, opts or {})
end

M.enable = function()
	M.config.enabled = true
end

M.disable = function()
	M.config.enabled = false
end

---@class State
---@field job_id number
---@field buf number
---@field exec string

---@type State
local state = {
	job_id = -1,
	buf = -1,
	exec = "",
}

---@return boolean
local function kill_buff()
	if state.buf ~= -1 and vim.api.nvim_buf_is_valid(state.buf) then
		if state.job_id then
			vim.fn.jobstop(state.job_id)
			state.job_id = nil
		end

		vim.api.nvim_buf_delete(state.buf, { force = true })
		return true
	else
		return false
	end
end

local function matches_pattern(filename, pattern)
	local result = filename:match(pattern) ~= nil
	return result
end

local function find_language(filepath)
	for _, lang in ipairs(M.config.languages) do
		if matches_pattern(filepath, lang.pattern) then
			return lang
		end
	end
	return nil
end

local function run_terminal()
	local bufnr = vim.api.nvim_get_current_buf()
	local filepath = vim.api.nvim_buf_get_name(bufnr)
	local language = find_language(filepath)
	if language then
		state.exec = language.exec
	else
		return
	end

	kill_buff()
	state.buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_set_current_buf(state.buf)
	state.job_id = vim.fn.termopen(state.exec)
end

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*",
	callback = function()
		run_terminal()
	end,
})

vim.api.nvim_create_user_command("LiveReloadTermShow", function()
	if state.buf ~= -1 and vim.api.nvim_buf_is_valid(state.buf) then
		vim.api.nvim_set_current_buf(state.buf)
	else
		print("No buf")
	end
end, {})

vim.api.nvim_create_user_command("LiveReloadTermKill", function()
	local killed = kill_buff()
	if not killed then
		print("No buf")
	else
		print("Killed")
	end
end, {})

vim.api.nvim_create_user_command("LiveReloadEnable", function()
	M.enable()
	print("Live reload is enabled")
end, {})

vim.api.nvim_create_user_command("LiveReloadDisable", function()
	M.disable()
	print("Live reload is disabled")
end, {})

vim.api.nvim_create_user_command("LiveReloadState", function()
	if M.config.enabled then
		print("Live reload is enabled")
	else
		print("Live reload is disabled")
	end
end, {})

return M
