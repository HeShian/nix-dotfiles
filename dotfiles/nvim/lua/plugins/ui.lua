return {
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		config = function()
			require('lualine').setup({
				options = {
					theme = 'auto',
					-- section_separators = { left = '', right = '' },
					-- component_separators = { left = '', right = '' },
				},
			})
		end,
	},

	{
		'edkolev/tmuxline.vim',
		config = function()
			if os.getenv("TMUX") then
				vim.cmd(':Tmuxline')
			end
		end
	},

	---@type LazySpec
	{
		"mikavilpas/yazi.nvim",
		event = "VeryLazy",
		keys = {
			{
				"<leader>-",
				"<cmd>Yazi<cr>",
				desc = "Open yazi at the current file",
			},
			{
				"<leader>cw",
				"<cmd>Yazi cwd<cr>",
				desc = "Open the file manager in nvim's working directory",
			},
			{
				-- 需要 yazi 包含 PR #1305（2024-07-18）
				'<c-up>',
				"<cmd>Yazi toggle<cr>",
				desc = "Resume the last yazi session",
			},
		},
		---@type YaziConfig
		opts = {
			-- 若想用 yazi 代替 netrw 打开目录，见插件文档
			open_for_directories = false,
			keymaps = {
				show_help = '<f1>',
			},
		},
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
	},

	{
		'akinsho/toggleterm.nvim',
		event = "VeryLazy",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = 20,
				open_mapping = [[<C-\>]],
				hide_numbers = true,
				shade_terminals = true,
				shading_factor = 2,
				start_in_insert = true,
				insert_mappings = true,
				terminal_mappings = true,
				direction = "float", -- 可选 horizontal/vertical/float/tab
				close_on_exit = true,
				shell = vim.o.shell,
				float_opts = {
					border = "curved", -- 可选 single/double/shadow/curved
					winblend = 30,
				},
			})
		end
	},

	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},
}
