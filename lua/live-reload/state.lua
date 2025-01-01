---@class Terminal
---@field runner Runner
---@field buf number

---@class State
---@field running boolean
---@field terminals Terminal[]
---@field reset fun(self: State)

---@type State
---@diagnostic disable-next-line: missing-fields
local state = {
	running = false,
	terminals = {},
}

function state:reset()
	self.running = false
	self.terminals = {}
end

return state
