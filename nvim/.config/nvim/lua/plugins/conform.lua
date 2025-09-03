return {
	"stevearc/conform.nvim",
	event = "VeryLazy",
	config = function()
		require("conform").setup({
			format_on_save = { lsp_fallback = true, timeout_ms = 1500 },
			notify_on_error = false,
			formatters_by_ft = {
				python = { "isort", "black" },
				lua = { "stylua" },
				nix = { "nixfmt" },
				json = { "prettier" },
				markdown = { "prettier" },
				["markdown.mdx"] = { "prettier" },
				yaml = { "prettier" },
			},
		})
		vim.keymap.set({ "n", "v" }, "<leader>cf", function()
			require("conform").format({ async = true })
		end, { desc = "Format buffer/selection" })
	end,
}
