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

## Install for lazy

```lua
{
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

## Commands

- `LiveReloadTermShow`
- `LiveReloadTermKill`
- `LiveReloadEnable`
- `LiveReloadDisable`
- `LiveReloadState`
