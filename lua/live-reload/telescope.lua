local utils = require("live-reload.utils")

---@return boolean
local has_telescope = function()
	local ok, _ = pcall(require, "telescope")
	return ok
end

---@return {buf: number, name: string}[]
local get_buffers = function()
	local buffers = {}
	for _, item in pairs(utils.state) do
		table.insert(buffers, {
			buf = item.buf,
			name = item.buf .. " " .. vim.fn.bufname(item.buf),
		})
	end
	return buffers
end

---@class Telescope
---@field _init fun(module: Module): Telescope
---@field _setup fun()
---@field telescope_picker fun()

---@type Telescope
---@diagnostic disable-next-line: missing-fields
local M = {}

M._setup = function()
	if not has_telescope() then
		return
	end

	M.telescope_picker = function()
		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local conf = require("telescope.config").values
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")

		pickers
			.new({}, {
				prompt_title = "Live reload terminals",
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

	vim.api.nvim_create_user_command("LiveReloadTermShow", function()
		M.telescope_picker()
	end, {})
end

return M
