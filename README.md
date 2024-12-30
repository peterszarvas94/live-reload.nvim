# Live reload for neovim

Work in progress!

Runs a script on file save for a given pattern.

E.g. with this setup, you can live reload your go server when any .go file changes:

```lua
{
  pattern = '%.go$',
  exec = 'go run main.go',
}
```

## Install

### Lazy

```lua
{
  'peterszarvas94/live-reload.nvim',
  -- if you want to use "LiveReloadBuffers"
  dependencies = {
    { 'nvim-telescope/telescope.nvim', tag = '0.1.8' },
    'nvim-lua/plenary.nvim',
  },
  config = function()
    require('live-reload').setup {}

    vim.keymap.set('n', '<leader>ls', ':LiveReloadStart<CR>', { desc = '[L]ive reload [S]tart', silent = true })
    vim.keymap.set('n', '<leader>lt', ':LiveReloadState<CR>', { desc = '[L]ive reload s[T]ate', silent = true })
    vim.keymap.set('n', '<leader>lb', ':LiveReloadBuffers<CR>', { desc = '[L]ive reload [B]uffers', silent = true })
    vim.keymap.set('n', '<leader>lp', ':LiveReloadStop<CR>', { desc = '[L]ive reload sto[P]', silent = true })
  end,
}
```

### Load project specific runners

You can use a lua config file for your project. You need to create `live-reload.lua` at the root directory of your project. This file must return a runner list.

E.g. `~/my-project/live-reload.lua`:

```lua
---@class Runner
---@field pattern? string
---@field once? boolean
---@field exec string

---@return Runner[]
local dir = vim.fn.expand("~") .. "/projects/test-go/"
local tw_config = dir .. "tailwind.config.js"
local tw_input = dir .. "tailwind.base.css"
local tw_output = dir .. "style.css"

local tw_fn = "tailwindcss -c " .. tw_config .. " -i " .. tw_input .. " -o " .. tw_output .. " --watch"

---@type Runner[]
local runners = {
  {
    once = true,
    exec = tw_fn,
  },
  {
    once = true,
    exec = "templ generate --watch",
  },
  {
    pattern = "%.go$",
    exec = "go run cmd/*.go",
  },
}

return runners
```

## Commands

- `LiveReloadStart`: start
- `LiveReloadStop`: stop
- `LiveReloadState`: print state
- `LiveReloadBuffers`: select running terminals with [telescope](https://github.com/nvim-telescope/telescope.nvim)
