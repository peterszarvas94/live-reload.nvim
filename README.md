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
  -- from local:
  -- dir = vim.fn.expand '~' .. '/projects/live-reload.nvim/',
  -- from remote:
  'peterszarvas94/live-reload.nvim'
  -- if you want to use telescope picker (LiveReloadBuffers):
  dependencies = {
    { 'nvim-telescope/telescope.nvim', tag = '0.1.8' },
    'nvim-lua/plenary.nvim'
  }
  config = function()
    require('live-reload').setup {
      enabled = true,
      runners = {
        -- {
        --   pattern = '%.go$',
        --   exec = 'go run cmd/*.go',
        -- },
      },
    }

    vim.keymap.set('n', '<leader>ls', ':LiveReloadStart<CR>', { desc = '[L]iveReload[S]tart', silent = true })
    vim.keymap.set('n', '<leader>lb', ':LiveReloadBuffers<CR>', { desc = '[L]iveReload[B]uffers', silent = true })
    vim.keymap.set('n', '<leader>lk', ':LiveReloadKill<CR>', { desc = '[L]iveReload[K]ill', silent = true })
  end,
}
```

### Load project specific runners

You can use a lua config file for your project. You need to create `live-reload.lua` at the root directory of your project. This file must return a runner list.

E.g. `~/my-project/live-reload.lua`:

```lua
---@class Runner
---@field pattern string
---@field exec string

---@return Runner[]
local get_runners = function()
  local dir = vim.fn.expand("~") .. "/my-project/"
  local tw_config = dir .. "tailwind.config.js"
  local tw_input = dir .. "tailwind.base.css"
  local tw_output = dir .. "style.css"

  local tw_fn = "tailwindcss -c " .. tw_config .. " -i " .. tw_input .. " -o " .. tw_output

  ---@type Runner[]
  local runners = {
    {
      pattern = "%.templ$",
      exec = "templ generate && " .. tw_fn,
    },
    {
      pattern = "%.go$",
      exec = "go run cmd/*.go",
    },
  }

  return runners
end

return get_runners()
```

## Commands

- `LiveReloadBuffers`
- `LiveReloadKill`
- `LiveReloadEnable`
- `LiveReloadDisable`
- `LiveReloadState`
