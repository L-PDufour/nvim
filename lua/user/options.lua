-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

-- Enable 24-bit RGB color
vim.o.termguicolors = true

-- Set colorscheme
require("catppuccin").setup({
	flavour = "frappe",
})
vim.cmd.colorscheme("catppuccin")
vim.o.winborder = "rounded"
-- General settings
vim.o.updatetime = 100 -- Faster completion

vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)
-- Line numbers
vim.o.number = true -- Display the absolute line number of the current line

-- Buffer settings
vim.o.hidden = true -- Keep closed buffer open in the background

-- Mouse settings
vim.o.mouse = "a" -- Enable mouse control

-- Split settings
vim.o.splitbelow = true -- A new window is put below the current one
vim.o.splitright = true -- A new window is put right of the current one

-- File settings
vim.o.swapfile = false -- Disable the swap file
vim.o.backup = false
vim.o.writebackup = false
vim.o.modeline = true -- Tags such as 'vim:ft=sh'
vim.o.modelines = 100 -- Sets the type of modelines
vim.o.undofile = true -- Automatically save and restore undo history

-- Search settings
vim.o.incsearch = true -- Incremental search: show match for partly typed search command
vim.o.ignorecase = true -- When the search query is lower-case, match both lower and upper-case patterns
vim.o.smartcase = true -- Override the 'ignorecase' option if the search pattern contains upper case characters
vim.o.infercase = true -- Infer letter cases for a richer built-in keyword completion
vim.o.smartindent = true -- Make indenting smart

-- Display settings
vim.o.scrolloff = 8 -- Number of screen lines to show around the cursor
vim.o.cursorline = true -- Highlight the screen line of the cursor
vim.o.signcolumn = "yes" -- Whether to show the signcolumn
vim.o.fillchars = "eob: " -- Don't show `~` outside of buffer
vim.o.fileencoding = "utf-8" -- File-content encoding for the current buffer
vim.o.wrap = false -- Prevent text from wrapping

-- Tab settings
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Other settings
vim.o.showmode = false
vim.o.timeoutlen = 300
vim.o.hlsearch = true -- Highlight search results
vim.o.completeopt = "menuone,noinsert,noselect" -- Customize completions
vim.o.breakindent = true -- Indent wrapped lines to match line start
vim.o.linebreak = true -- Wrap long lines at 'breakat' (if 'wrap' is set)
vim.o.ruler = false -- Don't show cursor position in command line
vim.o.virtualedit = "block" -- Allow going past the end of line in visual block mode
vim.opt.formatoptions:append("qjl1")
-- Some opinioneted extra UI options
vim.o.pumblend = 10 -- Make builtin completion menus slightly transparent
vim.o.pumheight = 10 -- Make popup menu smaller
vim.o.winblend = 10 -- Make floating windows slightly transparent
vim.o.listchars = "tab:> ,extends:…,precedes:…,nbsp:␣" -- Define which helper symbols to show
vim.o.list = true -- Show some helper symbols

vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)
vim.keymap.set("n", ";", ":", { noremap = true })
vim.keymap.set("n", ":", ";", { noremap = true })
vim.keymap.set("v", ";", ":", { noremap = true })
vim.keymap.set("v", ":", ";", { noremap = true })
local normal_mode_mappings = {
	-- Clear search results with Esc
	["<Esc>"] = { ":noh<CR>", { noremap = true, silent = true } },

	-- Fix 'Y' behavior to yank till the end of the line
	["Y"] = { "y$", { noremap = true, silent = true } },

	["L"] = { "$", { noremap = true, silent = true } }, -- Jump to the end of the line
	["H"] = { "^", { noremap = true, silent = true } }, -- Jump to the start of the line

	-- Resize windows with arrow keys
	["<C-Up>"] = { ":resize -2<CR>", { noremap = true, silent = true } }, -- Decrease window height
	["<C-Down>"] = { ":resize +2<CR>", { noremap = true, silent = true } }, -- Increase window height
	["<C-Left>"] = { ":vertical resize +2<CR>", { noremap = true, silent = true } }, -- Increase window width
	["<C-Right>"] = { ":vertical resize -2<CR>", { noremap = true, silent = true } }, -- Decrease window width

	-- Move current line up/down with Alt+K/J
	["<M-k>"] = { ":move-2<CR>", { noremap = true, silent = true } }, -- Move line up
	["<M-j>"] = { ":move+<CR>", { noremap = true, silent = true } }, -- Move line down

	--Primestuff
	["J"] = { "mzJ`z", { desc = "Join lines and keep cursor position" } },
	["<C-d>"] = { "<C-d>zz", { desc = "Scroll down and center cursor" } },
	["<C-u>"] = { "<C-u>zz", { desc = "Scroll up and center cursor" } },
	["n"] = { "nzzzv", { desc = "Next search result and center view" } },
	["N"] = { "Nzzzv", { desc = "Previous search result and center view" } },

	["<leader>ut"] = { "<cmd>UndotreeToggle<cr>", { desc = "Undo Tree" } },
}

-- Define key mappings for Visual mode
local visual_mode_mappings = {
	-- Better indenting in visual mode
	[">"] = { ">gv", { noremap = true, silent = true } }, -- Indent right and reselect
	["<"] = { "<gv", { noremap = true, silent = true } }, -- Indent left and reselect
	["<TAB>"] = { ">gv", { noremap = true, silent = true } }, -- Indent right and reselect
	["<S-TAB>"] = { "<gv", { noremap = true, silent = true } }, -- Indent left and reselect

	-- Move selected lines up/down in visual mode
	["K"] = { ":m '<-2<CR>gv=gv", { noremap = true, silent = true } }, -- Move selected lines up
	["J"] = { ":m '>+1<CR>gv=gv", { noremap = true, silent = true } }, -- Move selected lines down
	["<leader>d"] = { [["_d]], { desc = "Delete selection without yanking" } },
}
local shared_mappings = {
	["<C-s>"] = { "<Esc>:w<CR>", { noremap = true, silent = true } },
	["<C-x>"] = { ":close<CR>", { noremap = true, silent = true } },
	["<C-c>"] = { ":b#<CR>", { noremap = true, silent = true } },
}
-- Set key mappings for Normal and Visual modes
for key, value in pairs(normal_mode_mappings) do
	vim.keymap.set("n", key, value[1], value[2])
end

for key, value in pairs(visual_mode_mappings) do
	vim.keymap.set("v", key, value[1], value[2])
end

for key, value in pairs(shared_mappings) do
	vim.keymap.set({ "n", "v" }, key, value[1], value[2])
end

vim.keymap.set("c", "<C-a>", "<Home>", { noremap = true }) -- Go to beginning of line
vim.keymap.set("c", "<C-e>", "<End>", { noremap = true }) -- Go to end of line
vim.keymap.set("c", "<C-b>", "<Left>", { noremap = true }) -- Move one character backward
vim.keymap.set("c", "<C-f>", "<Right>", { noremap = true }) -- Move one character forward
vim.keymap.set("c", "<C-d>", "<Del>", { noremap = true }) -- Delete character under cursor
vim.keymap.set("c", "<C-h>", "<BS>", { noremap = true }) -- Delete character before cursor
vim.keymap.set("c", "<C-k>", '<C-\\>e("\\<C-E>\\<C-U>")<CR>', { noremap = true }) -- Delete to end of line

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<leader>xq", function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Quickfix List" })
