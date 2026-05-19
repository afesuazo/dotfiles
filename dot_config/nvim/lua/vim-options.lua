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

-- Window/pane navigation (Ctrl-h/j/k/l) is provided by vim-tmux-navigator

vim.api.nvim_set_keymap("n", "<leader>h", ":noh<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>r", ":bufdo e!<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>w", ":wa<CR>", {})

vim.wo.number = true
