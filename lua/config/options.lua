-- Consolidated options (remove duplicates)
vim.g.have_nerd_font = true

-- Use vim.opt for better performance
local opt = vim.opt

-- General
opt.mouse = "a"
opt.mousescroll = "ver:25,hor:6"
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.updatetime = 100
opt.timeoutlen = 300

-- UI
opt.termguicolors = true
opt.number = true
opt.cursorline = true
opt.cursorlineopt = "screenline,number"
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.wrap = false
opt.breakindent = true
opt.linebreak = true
opt.showmode = false
opt.ruler = false
opt.pumheight = 10
opt.pumblend = 10
opt.winblend = 10
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"
opt.list = true
opt.listchars = { tab = "> ", extends = "…", precedes = "…", nbsp = "␣" }
opt.fillchars = { eob = " ", fold = "╌" }
opt.colorcolumn = "+1"

-- Editing
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.autoindent = true
opt.smartindent = true
opt.virtualedit = "block"
opt.formatoptions = "rqnl1j"
opt.iskeyword:append("-")

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.infercase = true
opt.incsearch = true
opt.hlsearch = true

-- Completion
opt.completeopt = "menuone,noinsert,noselect"
opt.complete = ".,w,b,kspell"

-- Folds
opt.foldlevel = 10
opt.foldmethod = "indent"
opt.foldnestmax = 10
opt.foldtext = ""

-- Clipboard (delayed for startup performance)
vim.schedule(function()
	opt.clipboard = "unnamedplus"
end)
