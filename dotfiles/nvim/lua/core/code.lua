vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

vim.opt.backspace = 'indent,eol,start'

vim.opt.clipboard = 'unnamedplus'
vim.opt.termguicolors = true

vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 300

-- 设置 leader 键
vim.g.mapleader = ' '

-- 快速保存、退出
vim.keymap.set('n', '<Leader>w', ':w<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>q', ':q<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>wq', ':wq<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>Q', ':q!<CR>', { noremap = true, silent = true })

-- 快速缩进
vim.keymap.set('v', '<Tab>', '>gv', { noremap = true, silent = true })
vim.keymap.set('v', '<S-Tab>', '<gv', { noremap = true, silent = true })

-- 快速分割窗口
vim.keymap.set('n', '|', ':vsplit<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '-', ':split<CR>', { noremap = true, silent = true })
