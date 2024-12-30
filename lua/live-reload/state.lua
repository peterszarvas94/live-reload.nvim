-- NOTE: the reload_runners are pattern -> Terminal pairs, the once_runners are a list of Terminals

---@class Terminal
---@field buf number
---@field exec string

---@class ReloadRunners
---@field [string] Terminal

---@class State
---@field running boolean
---@field reload_runners ReloadRunners
---@field once_runners Terminal[]
---@field reset fun(self: State)

---@type State
---@diagnostic disable-next-line: missing-fields
local state = {
	reload_runners = {},
	once_runners = {},
	running = false,
}

function state:reset()
	self.reload_runners = {}
	self.once_runners = {}
	self.running = false
end

return state
