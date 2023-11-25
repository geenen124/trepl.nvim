# trepl.nvim
![Github Actions](https://github.com/geenen124/trepl.nvim/actions/workflows/ci.yml/badge.svg?branch=main)

A lightweight tmux REPL (trepl) interaction plugin for Neovim.

## Overview
`trepl.nvim` is a lightweight plugin for Neovim, designed to easily pass data to tmux panes from within Neovim. 
It allows you to send lines and selections from your current buffer to a tmux pane without leaving your editor,
facilitating quick interaction with other processes, e.g. REPLs.

## Installation

You can install `trepl.nvim` using your favorite package manager.
Please note that pinning to a tag can help provide more stability.

**Using [vim-plug](https://github.com/junegunn/vim-plug):**

```vim
Plug 'geenen124/trepl.nvim', { 'tag': 'v0.1.0' }
```

**Using [packer.nvim](https://github.com/wbthomason/packer.nvim):**

```lua
use {
  "geenen124/trepl.nvim",
  tag="v0.1.0"
}
```

**Using [lazy.nvim](https://github.com/folke/lazy.nvim):**

```lua
use {
  "geenen124/trepl.nvim",
  tag="v0.1.0"
}
```

## Configuration

Here's how you can configure `trepl.nvim` in your `init.vim` or `init.lua`:
```lua
require("trepl").setup {
  -- Configuration settings
  -- default values below
  commands = true, -- set up user commands
}
```

Recommended - set up keyboard mappings as follows:
```lua
vim.keymap.set("n", "<leader>tc", ":Trepl current_line<cr>")
vim.keymap.set("v", "<leader>ts", ":Trepl selection<cr>")
vim.keymap.set("v", "<leader>tl", ":Trepl selected_lines<cr>")
```

## Usage

Commands:

* `TreplSetSocket <socket_path>` - set the tmux socket path. By default trepl will use the socket path defined by the `$TMUX` environment variable.
* `TreplSetPane <pane>` - set the tmux pane trepl will send data to. By default it will send it the to next pane.
* `Trepl current_line` - send the current line.
* `Trepl selection` - send the current selection.
* `Trepl selected_lines` - send the lines included in your current selection.

## License
`trepl.nvim` is open-source software released under the MIT License.

## Roadmap

Add Support For:
* Repeated motions
* Send files
* Implement intelligent treesitter-based sends
