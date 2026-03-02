-- dadbod.lua
local function load_env_db()
	local env_file = vim.fn.getcwd() .. "/.env"
	if vim.fn.filereadable(env_file) == 0 then
		return
	end

	for _, line in ipairs(vim.fn.readfile(env_file)) do
		local key, val = line:match("^([%w_]+)=(.+)$")
		if key == "DATABASE_URL" then
			vim.g.db = val
		end
	end
end

load_env_db()

-- reload when cwd changes (e.g. switching projects)
vim.api.nvim_create_autocmd("DirChanged", {
	callback = load_env_db,
})
