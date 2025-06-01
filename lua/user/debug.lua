local dap = require("dap")

-- Basic keymaps
vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>B", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: Set Conditional Breakpoint" })

-- Go debugging setup
require("dap-go").setup({
	-- Uses delve by default, works with go install github.com/go-delve/delve/cmd/dlv@latest
	dap_configurations = {
		{
			type = "go",
			name = "Debug",
			request = "launch",
			program = "${file}",
		},
		{
			type = "go",
			name = "Debug Package",
			request = "launch",
			program = "${fileDirname}",
		},
		{
			type = "go",
			name = "Debug Test",
			request = "launch",
			mode = "test",
			program = "${workspaceFolder}",
		},
	},
})

-- JavaScript/TypeScript debugging setup
require("dap-vscode-js").setup({
	debugger_cmd = { "js-debug" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
	adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
})

-- JavaScript configurations
for _, language in ipairs({ "typescript", "javascript" }) do
	dap.configurations[language] = {
		{
			type = "pwa-node",
			request = "launch",
			name = "Launch file",
			program = "${file}",
			cwd = "${workspaceFolder}",
		},
		{
			type = "pwa-node",
			request = "attach",
			name = "Attach",
			processId = require("dap.utils").pick_process,
			cwd = "${workspaceFolder}",
		},
		{
			type = "pwa-node",
			request = "launch",
			name = "Debug Jest Tests",
			-- This assumes you have jest installed
			runtimeExecutable = "node",
			runtimeArgs = {
				"./node_modules/jest/bin/jest.js",
				"--runInBand",
			},
			rootPath = "${workspaceFolder}",
			cwd = "${workspaceFolder}",
			console = "integratedTerminal",
			internalConsoleOptions = "neverOpen",
		},
	}
end

-- Simple signs for breakpoints
vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "➡️", texthl = "", linehl = "", numhl = "" })

-- Auto-open/close dap-repl
dap.listeners.after.event_initialized["dapui_config"] = function()
	dap.repl.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dap.repl.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dap.repl.close()
end
