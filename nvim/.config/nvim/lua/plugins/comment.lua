return {
	"numToStr/Comment.nvim",
	keys = { { "<leader>/", mode = "n" }, { "<leader>/", mode = "x" } },
	config = function()
		require("Comment").setup()
		vim.keymap.set("n", "<leader>/", function()
			require("Comment.api").toggle.linewise.current()
		end, { desc = "Toggle comment" })
		vim.keymap.set("x", "<leader>/", function()
			local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
			vim.api.nvim_feedkeys(esc, "nx", false)
			require("Comment.api").toggle.linewise(vim.fn.visualmode())
		end, { desc = "Toggle comment (visual)" })
	end,
}
