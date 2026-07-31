
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.laststatus = 2

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- 禁用新手拐杖
-- vim.keymap.set('n', '<Down>', '<Nop>', { noremap = true, silent = true })
-- vim.keymap.set('n', '<Left>', '<Nop>', { noremap = true, silent = true })
-- vim.keymap.set('n', '<Right>', '<Nop>', { noremap = true, silent = true })
-- vim.keymap.set('n', '<Up>', '<Nop>', { noremap = true, silent = true })
-- vim.keymap.set('i', '<Down>', '<Nop>', { noremap = true, silent = true })
-- vim.keymap.set('i', '<Left>', '<Nop>', { noremap = true, silent = true })
-- vim.keymap.set('i', '<Right>', '<Nop>', { noremap = true, silent = true })
-- vim.keymap.set('i', '<Up>', '<Nop>', { noremap = true, silent = true })
-- vim.keymap.set('v', '<Down>', '<Nop>', { noremap = true, silent = true })
-- vim.keymap.set('v', '<Left>', '<Nop>', { noremap = true, silent = true })
-- vim.keymap.set('v', '<Right>', '<Nop>', { noremap = true, silent = true })
-- vim.keymap.set('v', '<Up>', '<Nop>', { noremap = true, silent = true })

-- 快速跳至行首和行尾
vim.keymap.set('n', 'H', '^', { noremap = true , silent = true })
vim.keymap.set('n', 'L', '$', { noremap = true , silent = true })

-- 快速窗格选择
vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true , silent = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true , silent = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true , silent = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true , silent = true })

