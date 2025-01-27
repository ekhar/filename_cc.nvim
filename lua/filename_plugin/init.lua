-- lua/filename_plugin/init.lua

local M = {}

-- Attempt to extract a line-comment prefix from commentstring
-- e.g. if commentstring = "// %s", then we want "//"
-- If commentstring = "/* %s */", we might end up with "/* "
-- (which might not be truly single-line, but we'll just demonstrate the logic).
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

local function add_filename_comment()
	-- Get the current filename
	local filename = vim.fn.expand("%:t")
	if filename == "" then
		return
	end

	-- Derive the comment prefix from the commentstring
	local token = get_comment_prefix()

	-- Build the line we want to see at the top
	local filename_mark = token .. " filename: "

	-- Read the first line of the buffer
	local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""

	-- If the first line already matches the pattern, do nothing
	if first_line:find("^" .. vim.pesc(filename_mark) .. filename) then
		return
	end

	-- If we see a line with "filename:" but the wrong file name, replace it
	if first_line:find("^" .. vim.pesc(filename_mark)) then
		vim.api.nvim_buf_set_lines(0, 0, 1, false, { filename_mark .. filename })
	else
		-- Insert a new line at the top
		vim.api.nvim_buf_set_lines(0, 0, 0, false, { filename_mark .. filename })
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
