local cmp = require("blink.cmp")

local luasnip = require("luasnip")

local lazydev = require("lazydev")

lazydev.setup({ ft = "lua" })

require("luasnip.loaders.from_vscode").lazy_load()
cmp.setup({
	keymap = { preset = "default" },
	appearance = {
		use_nvim_cmp_as_default = false,
		nerd_font_variant = "mono",
	},
	completion = {
		accept = {
			auto_brackets = {
				enabled = true,
			},
		},

		documentation = {
			auto_show = true,
			auto_show_delay_ms = 200,
		},
		ghost_text = {
			enabled = vim.g.ai_cmp,
		},
	},
	cmdline = {
		keymap = { preset = "inherit" },
		completion = { menu = { auto_show = true } },
	},
	snippets = { preset = "luasnip" },
	sources = {
		default = { "lazydev", "lsp", "path", "snippets", "buffer" },
		per_filetype = {
			org = { "orgmode" },
			["gitcommit"] = { "conventional", "buffer", "spell" },
		},
		providers = {
			orgmode = {
				name = "Orgmode",
				module = "orgmode.org.autocompletion.blink",
				fallbacks = { "buffer" },
			},
			lazydev = {
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				-- make lazydev completions top priority (see `:h blink.cmp`)
				score_offset = 100,
			},
		},
	},
	-- experimental signature help support
	signature = { enabled = true },
})
