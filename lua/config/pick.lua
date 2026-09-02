-- Picker keymaps (mini.pick + mini.extra; setup lives in config.mini)
local MiniPick = require("mini.pick")
local MiniExtra = require("mini.extra")
local pick = MiniPick.builtin
local extra = MiniExtra.pickers

local nmap_leader = function(suffix, rhs, desc)
	vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc })
end

nmap_leader("ff", pick.files, "Files")
nmap_leader("fh", pick.help, "Help tags")
nmap_leader(".", pick.resume, "Resume")
nmap_leader("fq", function()
	extra.list({ scope = "quickfix" })
end, "Quickfix")
nmap_leader("fQ", function()
	extra.list({ scope = "location" })
end, "Loclist")
nmap_leader("fd", function()
	extra.diagnostic({ scope = "current" })
end, "Diagnostic buf")
nmap_leader("fD", function()
	extra.diagnostic({ scope = "all" })
end, "Diagnostic workspace")
nmap_leader("fs", function()
	extra.lsp({ scope = "workspace_symbol_live" })
end, "Symbols workspace")
nmap_leader("fm", function()
	extra.marks()
end, "Marks")
nmap_leader("fr", function()
	extra.registers()
end, "Registers")
nmap_leader("<space>", pick.grep_live, "Grep live")
nmap_leader("/", function()
	extra.buf_lines({ scope = "current" })
end, "Lines")
nmap_leader("fw", function()
	pick.grep({ pattern = vim.fn.expand("<cword>") })
end, "Grep word")
nmap_leader("j/", function()
	extra.history({ scope = "/" })
end, '"/" history')
nmap_leader("j;", function()
	extra.history({ scope = ":" })
end, '":" history')
nmap_leader("k", pick.buffers, "Buffers")

local lsp_location_picker = function(scope)
	return function()
		local win = vim.api.nvim_get_current_win()
		local function on_list(what)
			local items = what.items
			if #items == 0 then
				return
			end
			-- Single result: jump straight there, same as choosing it in a picker.
			if #items == 1 then
				local item = items[1]
				item.path = item.filename or ""
				if vim.api.nvim_win_is_valid(win) then
					return vim.api.nvim_win_call(win, function()
						MiniPick.default_choose(item)
					end)
				end
			end
			-- Multiple results: render like mini.extra's location scopes (public APIs).
			local function prepend_position(item)
				item.path = item.filename or ""
				item.text = item.text or ""
				local path = vim.fn.fnamemodify(item.path, ":p:.")
				local suffix = item.text == "" and "" or ("│ " .. item.text)
				item.text = string.format("%s│%s│%s%s", path, item.lnum or 1, item.col or 1, suffix)
				return item
			end
			local function compare(a, b)
				if a.path < b.path then return true end
				if a.path > b.path then return false end
				if (a.lnum or 1) < (b.lnum or 1) then return true end
				if (a.lnum or 1) > (b.lnum or 1) then return false end
				return (a.col or 1) < (b.col or 1)
			end
			items = vim.tbl_map(prepend_position, items)
			table.sort(items, compare)
			MiniPick.start({
				source = {
					name = string.format("LSP (%s)", scope),
					items = items,
					show = function(buf_id, items_to_show, query)
						MiniPick.default_show(buf_id, items_to_show, query, { show_icons = true })
					end,
					choose = function(item)
						MiniPick.default_choose(item)
						-- mini.extra's workaround to list relative paths in `:buffers`
						vim.fn.chdir(vim.fn.getcwd())
					end,
				},
			})
		end
		if scope == "references" then
			return vim.lsp.buf.references(nil, { on_list = on_list })
		end
		return vim.lsp.buf[scope]({ on_list = on_list })
	end
end

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local function map_buf(lhs, rhs)
			vim.keymap.set("n", lhs, rhs, { buffer = args.buf })
		end
		local lsp_picker = function(scope)
			return function()
				extra.lsp({ scope = scope })
			end
		end

		map_buf("grr", lsp_location_picker("references"))
		map_buf("gri", lsp_location_picker("implementation"))
		map_buf("grt", lsp_location_picker("type_definition"))
		map_buf("gra", vim.lsp.buf.code_action)
		map_buf("gO", lsp_picker("document_symbol"))
		map_buf("gd", lsp_location_picker("definition"))
		map_buf("gD", lsp_location_picker("declaration"))
	end,
})
