return {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = function()
		local actions = require("telescope.actions")
		return {
			defaults = {
				mappings = {
					i = {
						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,
						["<C-q>"] = function(...)
							actions.smart_send_to_qflist(...)
							actions.open_qflist(...)
						end,
					},
					n = {
						["<C-q>"] = function(...)
							actions.smart_send_to_qflist(...)
							actions.open_qflist(...)
						end,
					},
				},
			},
		}
	end,
}
