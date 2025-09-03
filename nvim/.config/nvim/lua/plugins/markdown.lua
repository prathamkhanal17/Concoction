return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "rmd", "mdx" },
		opts = {},
		keys = {
			{ "<leader>rm", "<cmd>RenderMarkdown toggle<CR>", desc = "Markdown: inline toggle" },
		},
	},

	{
		"iamcco/markdown-preview.nvim",
		ft = { "markdown", "mdx" },
		build = "sh -c 'cd app && npm install'",
		config = function()
			vim.g.mkdp_auto_close = 1
			vim.g.mkdp_filetypes = { "markdown", "mdx" }
		end,
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreview<CR>", desc = "Markdown: preview (browser)" },
			{ "<leader>ms", "<cmd>MarkdownPreviewStop<CR>", desc = "Markdown: stop preview" },
		},
	},

	{
		"dhruvasagar/vim-table-mode",
		ft = { "markdown", "mdx" },
		keys = {
			{ "<leader>mt", "<cmd>TableModeToggle<CR>", desc = "Markdown: table mode" },
		},
	},
}
