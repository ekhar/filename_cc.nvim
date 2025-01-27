-- filename: lua/filename_cc/init.lua
local M = {}

-- Attempt to extract a line-comment prefix from commentstring
local function get_comment_prefix()
	local cstring = vim.bo.commentstring
	-- If it's empty or just "%s", fallback to "#"
	if not cstring or cstring == "" or cstring == "%s" then
		return "#"
	end

	-- Try to capture everything before "%s"
	local prefix = cstring:match("^(.-)%%s")
	if prefix and prefix ~= "" then
		return vim.trim(prefix)
	end

	-- If we can't parse it meaningfully, fallback to "#"
	return "#"
end
-- Get the full relative path from project root
local function get_relative_path()
	-- First try to get the git root directory
	local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")

	if git_root ~= "" then
		-- If we're in a git repo, get path relative to git root
		local full_path = vim.fn.expand("%:p")
		local rel_path = full_path:sub(#git_root + 2) -- +2 to account for the trailing slash
		return rel_path
	else
		-- Fallback to path relative to current working directory
		return vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")
	end
end

-- Check if a file is ignored by Git via .gitignore
local function is_file_ignored_by_git(filepath)
	-- We call `git check-ignore <filepath>`
	-- If the output is non-empty, it means it's matched in .gitignore
	local output = vim.fn.systemlist("git check-ignore " .. vim.fn.shellescape(filepath))
	return (#output > 0)
end
local function should_skip_file()
	-- List of filetypes to skip
	local skip_filetypes = {
		-- Documentation/Text formats
		"markdown",
		"text",
		"txt",
		"org",
		"rst", -- ReStructuredText
		"asciidoc", -- AsciiDoc
		"tex", -- LaTeX files

		-- Data formats
		"json",
		"yaml", -- YAML files often need clean structure
		"toml", -- TOML configuration files
		"xml", -- XML files

		-- VCS and Config
		"gitcommit",
		"gitrebase",
		"gitconfig",
		"git",
		"ignore", -- .gitignore and similar

		-- Documentation
		"help",
		"man", -- Man pages
		"doc", -- Documentation files

		-- Special Neovim filetypes
		"TelescopePrompt",
		"lazy", -- Lazy plugin manager
		"mason", -- Mason package manager
		"notify", -- Notification windows
		"NvimTree", -- File explorer
		"neo-tree", -- Neo-tree file explorer
		"qf", -- Quickfix lists
		"help", -- Help files
		"startify", -- Startify
		"dashboard", -- Dashboard
		"alpha", -- Alpha dashboard
		"lspinfo", -- LSP info
		"checkhealth", -- Health check

		-- Special buffers
		"nofile",
		"terminal",
		"prompt",
		"popup",
	}

	-- List of filename patterns to skip
	local skip_patterns = {
		-- Documentation
		"^README",
		"^LICENSE",
		"^CHANGELOG",
		"^CONTRIBUTING",
		"^AUTHORS",
		"^PATENTS",
		"^SECURITY",
		"^CODE_OF_CONDUCT",
		"^PULL_REQUEST_TEMPLATE",
		"^ISSUE_TEMPLATE",

		-- Common extensions to skip
		"%.md$",
		"%.txt$",
		"%.org$",
		"%.rst$",
		"%.adoc$",
		"%.json$",
		"%.yaml$",
		"%.yml$",
		"%.toml$",
		"%.lock$", -- Lock files
		"%.min%.", -- Minified files

		-- Git related
		"^%.git/",
		"^%.github/",
		"^%.gitignore$",
		"^%.gitattributes$",
		"^%.gitmodules$",

		-- Config files
		"^%.env", -- Environment files
		"^%.editorconfig$",
		"^%.dockerignore$",
		"^Dockerfile$",
		"^docker%-compose",

		-- Package files
		"^package%.json$",
		"^package%-lock%.json$",
		"^yarn%.lock$",
		"^pnpm%-lock%.yaml$",
		"^composer%.json$",
		"^Cargo%.toml$",
		"^Cargo%.lock$",
		"^go%.mod$",
		"^go%.sum$",

		-- Cache and build artifacts
		"^node_modules/",
		"^build/",
		"^dist/",
		"^%.cache/",
		"^%.tmp/",

		-- Project specific
		"^%.vscode/",
		"^%.idea/",
		"^%.sublime/",
		"^%.vim/",
		"^%.nvim/",
	}

	-- Add check for binary files
	local function is_binary_file()
		local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""
		return first_line:find("%z") ~= nil
	end

	-- Skip binary files
	if is_binary_file() then
		return true
	end

	-- Check filetype
	local ft = vim.bo.filetype
	for _, skip_ft in ipairs(skip_filetypes) do
		if ft == skip_ft then
			return true
		end
	end

	-- Check filename patterns
	local filename = vim.fn.expand("%:t")
	local filepath = vim.fn.expand("%")
	for _, pattern in ipairs(skip_patterns) do
		if filename:match(pattern) or filepath:match(pattern) then
			return true
		end
	end

	return false
end

local function add_filename_comment()
	-- If the buffer doesn't have a filename yet (new, unsaved file), bail out
	local abspath = vim.fn.expand("%:p")
	if abspath == "" then
		return
	end

	-- 1) If this file is ignored in .gitignore, skip
	if is_file_ignored_by_git(abspath) then
		return
	end

	-- 2) If the filetype does not allow comments (e.g., JSON), skip
	--    This is a simple check.  If you have more filetypes to skip,
	--    you could expand this logic or create a config list of them.
	if should_skip_file() then
		return
	end

	-- Derive the path relative to your current working directory (plus ~ expansion)
	-- Adjust as needed for your workflow
	local relpath = get_relative_path()

	-- Derive the comment prefix from the commentstring
	local token = get_comment_prefix()

	-- Build the line we want to see at the top
	local filename_mark = token .. " filename: "

	-- Read the first line of the buffer
	local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""

	-- If the first line already matches the pattern, do nothing
	if first_line:find("^" .. vim.pesc(filename_mark) .. relpath) then
		return
	end

	-- If we see a line with "filename:" but the wrong file name, replace it
	if first_line:find("^" .. vim.pesc(filename_mark)) then
		vim.api.nvim_buf_set_lines(0, 0, 1, false, { filename_mark .. relpath })
	else
		-- Otherwise, insert a new line at the top
		vim.api.nvim_buf_set_lines(0, 0, 0, false, { filename_mark .. relpath })
	end
end

function M.setup()
	local augroup = vim.api.nvim_create_augroup("FilenamePluginGroup", { clear = true })

	-- Run our function right before saving (BufWritePre)
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = augroup,
		pattern = "*",
		callback = add_filename_comment,
	})
end

return M
