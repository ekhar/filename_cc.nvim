-- filename: lua/filename_plugin/init.lua
local M = {}

-- Attempt to extract a line-comment prefix from commentstring
local function get_comment_prefix()
	local cstring = vim.api.nvim_buf_get_option(0, "commentstring")
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

-- Check if a file is ignored by Git via .gitignore
local function is_file_ignored_by_git(filepath)
	-- We call `git check-ignore <filepath>`
	-- If the output is non-empty, it means it's matched in .gitignore
	local output = vim.fn.systemlist("git check-ignore " .. vim.fn.shellescape(filepath))
	return (#output > 0)
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
	if vim.bo.filetype == "json" then
		return
	end

	-- Derive the path relative to your current working directory (plus ~ expansion)
	-- Adjust as needed for your workflow
	local relpath = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")

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
