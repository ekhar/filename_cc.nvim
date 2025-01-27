# Filename Comment

With LLM's becoming more popular, it's important to have a way to easily refer to the current file.

filename_cc is a Neovim plugin that automatically adds or updates a filename comment at the top of your files when saving. The plugin is intelligent about file paths, using git root or relative paths, and respects `.gitignore` settings.

## Features

- Automatically adds a filename comment at the top of files on save
- Uses Git root directory for path resolution when available
- Respects `.gitignore` rules (skips ignored files)
- Intelligently handles comment syntax based on filetype
- Skips files that don't support comments (e.g., JSON)
- Updates existing filename comments if the path changes
- Minimal setup required

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "dhruvasagar/filename-comment.nvim",
    config = function()
        require("filename_cc").setup()
    end,
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
    'dhruvasagar/filename-comment.nvim',
    config = function()
        require('filename_cc').setup()
    end
}
```

## Usage

The plugin works automatically after setup. When you save any file, it will:
1. Add a comment with the relative filepath at the top of the file
2. Update the comment if the filepath changes
3. Skip files that are git-ignored or don't support comments

Example output:
```lua
-- filename: lua/my_project/init.lua
```

## Configuration

The plugin works out of the box with no configuration needed. It uses your filetype's native comment syntax and intelligently determines file paths.

## Requirements

- Neovim >= 0.8.0
- Git (optional, for git-root path resolution and `.gitignore` support)

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
