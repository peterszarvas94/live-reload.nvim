# Live reload for neovim

Work in progress

## Config for lazy

```lua
return {
  -- dir = vim.fn.expand '~' .. '/projects/live-reload.nvim/', -- only for local dev
  'peterszarvas94/live-reload.nvim'
  config = function()
    require('live-reload').setup {
      languages = {
        {
          pattern = '%.templ$',
          exec = 'templ generate',
        },
        {
          pattern = '%.go$',
          exec = 'go run main.go',
        },
      },
    }
  end,
}
```
