return {
	default_config = {
		cmd = { "vtsls", "--stdio" },
		filetypes = {
			"javascript",
			"javascriptreact",
			"javascript.jsx",
			"typescript",
			"typescriptreact",
			"typescript.tsx",
		},
		root_dir = function(bufnr, cb)
			local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))

			local ts_root = vim.fs.find("jsconfig.json", { upward = true, path = fname })[1]
			-- Use the git root to deal with monorepos where TypeScript is installed in the root node_modules folder.
			local git_root = vim.fs.find(".git", { upward = true, path = fname })[1]

			if git_root then
				cb(vim.fn.fnamemodify(git_root, ":h"))
			elseif ts_root then
				cb(vim.fn.fnamemodify(ts_root, ":h"))
			end
		end,
		single_file_support = true,
	},
	docs = {
		description = [[
https://github.com/yioneko/vtsls

`vtsls` can be installed with npm:
```sh
npm install -g @vtsls/language-server
```

To configure a TypeScript project, add a
[`tsconfig.json`](https://www.typescriptlang.org/docs/handbook/tsconfig-json.html)
or [`jsconfig.json`](https://code.visualstudio.com/docs/languages/jsconfig) to
the root of your project.
]],
	},
}
