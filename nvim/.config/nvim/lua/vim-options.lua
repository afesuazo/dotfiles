vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set foldmethod=indent")
vim.cmd("set nu")
vim.cmd("set rnu")
vim.cmd("set hlsearch")
vim.cmd("set incsearch")
vim.cmd("set ignorecase")
vim.cmd("set cmdheight=1")
vim.cmd("set cursorline")

vim.g.mapleader = " "

-- Navigate vim panes 
vim.api.nvim_set_keymap("n", "<C-j>", "<C-W>j", {noremap = true})
vim.api.nvim_set_keymap("n", "<C-h>", "<C-W>h", {noremap = true})
vim.api.nvim_set_keymap("n", "<C-k>", "<C-W>k", {noremap = true})
vim.api.nvim_set_keymap("n", "<C-l>", "<C-W>l", {noremap = true})

vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')
vim.wo.number = true
