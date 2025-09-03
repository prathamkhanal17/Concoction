return {
	"akinsho/bufferline.nvim",
	event = "BufAdd",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("bufferline").setup({
			options = {
				mode = "buffers",
				diagnostics = "nvim_lsp",
				separator_style = "slant",
				show_buffer_close_icons = true,
				show_close_icon = false,
				always_show_bufferline = true,
				offsets = {
					{ filetype = "NvimTree", text = "File Explorer", highlight = "Directory", text_align = "left" },
				},
			},
		})
		vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer tab" })
		vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer tab" })
		vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close current buffer" })
		vim.keymap.set("n", "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", { desc = "Close other buffers" })
	end,
}
