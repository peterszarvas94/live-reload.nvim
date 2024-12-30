local state = require("live-reload.state")

---@return {buf: number, name: string}[]
local get_buffers = function()
	local buffers = {}
	for _, item in pairs(state.reload_runners) do
		table.insert(buffers, {
			buf = item.buf,
			name = item.buf .. " " .. vim.fn.bufname(item.buf),
		})
	end
	for _, item in ipairs(state.once_runners) do
		table.insert(buffers, {
			buf = item.buf,
			name = item.buf .. " " .. vim.fn.bufname(item.buf),
		})
	end
	return buffers
end

---@class Telescope
---@field picker fun()
---@field is_installed fun(): boolean

---@type Telescope
---@diagnostic disable-next-line: missing-fields
local M = {}

M.is_installed = function()
	local ok, _ = pcall(require, "telescope")
	return ok
end

M.picker = function()
	if not M.is_installed() then
		print("telescope.nvim needs to be installed for this feature")
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	pickers
		.new({}, {
			prompt_title = "Live reload buffers",
			finder = finders.new_table({
				results = get_buffers(),
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.name,
						ordinal = entry.name,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			---@diagnostic disable-next-line: unused-local
			attach_mappings = function(prompt_buf, map)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_buf)
					-- Jump to the selected buffer
					vim.api.nvim_set_current_buf(selection.value.buf)
				end)
				return true
			end,
		})
		:find()
end

return M
