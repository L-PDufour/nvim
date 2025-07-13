local cmp = require("blink.cmp")
local lazydev = require("lazydev")

lazydev.setup({ ft = "lua" })
require("luasnip.loaders.from_vscode").lazy_load()
cmp.setup({
	keymap = { preset = "super-tab" },
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
		default = { "lazydev", "lsp", "path", "snippets", "buffer", "ripgrep" },
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
			ripgrep = {
				module = "blink-ripgrep",
				name = "Ripgrep",
				-- see the full configuration below for all available options
				---@module "blink-ripgrep"
				---@type blink-ripgrep.Options
				opts = {
					prefix_min_len = 4,
					backend = {
						-- The backend to use for searching. Defaults to "ripgrep".
						-- Available options:
						-- - "ripgrep", always use ripgrep
						-- - "gitgrep", always use git grep
						-- - "gitgrep-or-ripgrep", use git grep if possible, otherwise
						--   use ripgrep. Uses the same options as the gitgrep backend
						use = "gitgrep-or-ripgrep",
					},
				},
			},
		},
	},
	fuzzy = { implementation = "prefer_rust_with_warning" },
	-- experimental signature help support
	signature = { enabled = true },
})
