# Filename Comment

A Neovim plugin that automatically adds and maintains filename comments at the top of your files. With the growing popularity of LLMs and AI coding assistants, having clear file identifiers is increasingly important for context awareness.

## Features

- **Automatic Comment Generation**: Adds/updates filename comments on file save
- **Smart Path Resolution**: Uses Git root or relative paths intelligently
- **Git Integration**: 
  - Respects `.gitignore` rules
  - Uses Git root for consistent path references
- **Language Aware**: 
  - Supports multiple programming languages
  - Uses appropriate comment syntax for each filetype
  - Skips unsupported files (e.g., JSON)
- **Zero Config**: Works out of the box with sensible defaults
- **Lightweight**: Minimal impact on save operations

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "ekhar/filename_cc.nvim",
    event = "BufWritePre", -- Load right before saving
    config = function()
        require("filename_cc").setup()
    end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    'ekhar/filename_cc.nvim',
    config = function()
        require('filename_cc').setup()
    end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'ekhar/filename_cc.nvim'
```

After installation, add to your init.lua:
```lua
require('filename_cc').setup()
```

## Configuration

The plugin works out of the box, but can be customized:

```lua
require('filename_cc').setup({
    -- Enable/disable the plugin
    enabled = true,
    
    -- Skip specific filetypes
    skip_filetypes = { "json", "markdown" },
    
    -- Custom comment format for specific filetypes
    comment_formats = {
        lua = "-- %s",
        python = "# %s",
        -- Add your own formats
    },
    
    -- Format of the filename comment
    -- Available variables: {filepath}, {filename}, {git_root}
    format = "filename: {filepath}",
    
    -- Position of the comment (1 = top of file)
    position = 1,
})
```

## Usage

The plugin works automatically after setup:

1. Save any file to add/update the filename comment
2. Comments are formatted based on filetype:

```python
# filename: src/main.py
```

```javascript
// filename: src/index.js
```

```lua
-- filename: lua/config/init.lua
```

## Requirements

- Neovim >= 0.8.0
- Git (optional) - for git-root path resolution and `.gitignore` support

## Troubleshooting

### Common Issues

1. **Comments not appearing**: 
   - Ensure the filetype is supported
   - Check if the file is git-ignored
   - Verify the plugin is loaded (`:PackerStatus` or `:Lazy`)

2. **Wrong comment syntax**: 
   - Add custom comment format in setup configuration
   - File an issue with the filetype details

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to your branch
5. Open a Pull Request

Please ensure your PR includes:
- Clear description of changes
- Tests for new features
- Documentation updates

## License

MIT License - See [LICENSE](./LICENSE) for details

## Acknowledgments

- Inspired by the need for better context in AI-assisted coding
- Thanks to all contributors and users for their feedback and support

## Support

- Open an issue for bugs or feature requests
- Star the repository if you find it useful
- Follow [@ekhar](https://github.com/ekhar) for updates
