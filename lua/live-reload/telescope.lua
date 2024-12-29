local utils = require("live-reload.utils")

---@class Telescope
---@field module Module
---@field _init fun(module: Module): Telescope
---@field _setup fun()
---@field get_buffers fun(): {buf: number, name: string}[]
---@field telescope_picker fun()

---@type Telescope
---@diagnostic disable-next-line: missing-fields
local M = {}

M._init = function(module)
	M.module = module
	return M
end

M._setup = function()
	if M.module == nil then
		print("Module is not setup for telescope")
	end

	M.get_buffers = function()
		local buffers = {}
		for _, item in pairs(utils.state) do
			table.insert(buffers, {
				buf = item.buf,
				name = item.buf .. " " .. vim.fn.bufname(item.buf),
			})
		end
		return buffers
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
					results = M.get_buffers(),
					entry_maker = function(entry)
						return {
							value = entry,
							display = entry.name,
							ordinal = entry.name,
						}
					end,
				}),
				sorter = conf.generic_sorter({}),
				attach_mappings = function(prompt_bufnr, _)
					actions.select_default:replace(function()
						local selection = action_state.get_selected_entry()
						actions.close(prompt_bufnr)
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
