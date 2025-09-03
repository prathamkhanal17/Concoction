return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		local wk = require("which-key")
		wk.setup({})
		local tb = require("telescope.builtin")
		wk.add({
			{
				"<leader>/",
				function()
					require("Comment.api").toggle.linewise.current()
				end,
				desc = "Toggle comment",
			},

			{ "<leader>f", group = "Find" },
			{
				"<leader>ff",
				function()
					tb.find_files()
				end,
				desc = "Files",
			},
			{
				"<leader>fg",
				function()
					tb.live_grep()
				end,
				desc = "Live grep",
			},
			{
				"<leader>fb",
				function()
					tb.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>fh",
				function()
					tb.help_tags()
				end,
				desc = "Help",
			},
			{
				"<leader>fd",
				function()
					tb.diagnostics()
				end,
				desc = "Diagnostics (workspace)",
			},

			{ "<leader>n", group = "File Tree" },
			{ "<leader>nt", "<cmd>NvimTreeToggle<CR>", desc = "Tree: Toggle" },
			{ "<leader>nf", "<cmd>NvimTreeFindFile<CR>", desc = "Tree: Reveal file" },

			{ "<leader>m", group = "Markdown" },
			{ "<leader>mp", "<cmd>MarkdownPreview<CR>", desc = "Preview (browser)" },
			{ "<leader>ms", "<cmd>MarkdownPreviewStop<CR>", desc = "Preview: stop" },
			{ "<leader>mt", "<cmd>TableModeToggle<CR>", desc = "Table mode toggle" },

			{ "<leader>c", group = "Code (LSP)" },
			{ "<leader>ca", vim.lsp.buf.code_action, desc = "Code action" },
			{ "<leader>cd", vim.diagnostic.open_float, desc = "Line diagnostics" },
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true })
				end,
				desc = "Format buffer/selection",
			},
			{ "<leader>cr", vim.lsp.buf.rename, desc = "Rename symbol" },
			{ "<leader>cl", group = "LSP" },
			{ "<leader>cli", "<cmd>LspInfo<CR>", desc = "LSP info" },

			{ "<leader>t", group = "Trouble" },
			{ "<leader>tt", "<cmd>Trouble diagnostics toggle<CR>", desc = "Toggle Trouble" },

			{ "<leader>b", group = "Buffers" },
			{ "<leader>bn", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
			{ "<leader>bp", "<cmd>BufferLineCyclePrev<CR>", desc = "Prev buffer" },
			{ "<leader>bd", "<cmd>bdelete<CR>", desc = "Delete buffer" },
			{ "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", desc = "Close others" },
		})
	end,
}
