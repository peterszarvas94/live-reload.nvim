# Live reload for neovim

Work in progress

## Config for lazy

```lua
return {
  -- dir = vim.fn.expand '~' .. '/projects/live-reload.nvim/', -- only for local dev
  'peterszarvas94/live-reload.nvim'
  opts = {
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
  },
}
```
