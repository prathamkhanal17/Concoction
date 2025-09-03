return {
	{
		"lewis6991/gitsigns.nvim",
		event = "BufReadPre",
		config = function()
			require("gitsigns").setup({
				current_line_blame = false,
				current_line_blame_opts = { delay = 300, virt_text_pos = "eol" },
				current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> • <summary>",
			})

			local gs = require("gitsigns")
			vim.keymap.set("n", "]h", gs.next_hunk, { desc = "Git: next hunk" })
			vim.keymap.set("n", "[h", gs.prev_hunk, { desc = "Git: prev hunk" })
			vim.keymap.set("n", "<leader>gp", gs.preview_hunk_inline, { desc = "Git: preview hunk" })
			vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { desc = "Git: stage hunk" })
			vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { desc = "Git: reset hunk" })
			vim.keymap.set("n", "<leader>gS", gs.undo_stage_hunk, { desc = "Git: undo stage hunk" })
			vim.keymap.set("n", "<leader>gB", gs.blame, { desc = "Git: full blame" })
			vim.keymap.set("n", "<leader>gb", gs.toggle_current_line_blame, { desc = "Git: toggle inline blame" })
			vim.keymap.set("n", "<leader>gdt", gs.diffthis, { desc = "Git: diff this buffer" })
			vim.keymap.set("n", "<leader>gdo", function()
				gs.diffthis("~")
			end, { desc = "Git: diff vs HEAD~" })

			local tb = require("telescope.builtin")
			vim.keymap.set("n", "<leader>gC", tb.git_commits, { desc = "Git: commits" })
			vim.keymap.set("n", "<leader>gc", tb.git_bcommits, { desc = "Git: buffer commits" })
			vim.keymap.set("n", "<leader>gS", tb.git_status, { desc = "Git: status" })
		end,
	},

	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
		config = function()
			require("diffview").setup({
				enhanced_diff_hl = true,
				view = { default = { winbar_info = true } },
			})
			vim.keymap.set("n", "<leader>dv", "<cmd>DiffviewOpen<CR>", { desc = "Diff: open" })
			vim.keymap.set("n", "<leader>dx", "<cmd>DiffviewClose<CR>", { desc = "Diff: close" })
			vim.keymap.set(
				"n",
				"<leader>dh",
				"<cmd>DiffviewFileHistory %<CR>",
				{ desc = "Diff: file history (current)" }
			)
			vim.keymap.set("n", "<leader>dH", "<cmd>DiffviewFileHistory<CR>", { desc = "Diff: repo history" })
		end,
	},
}
