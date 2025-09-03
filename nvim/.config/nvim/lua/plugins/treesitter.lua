return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPost", "BufNewFile" }, -- not on VimEnter
	build = ":TSUpdate",
	opts = {
		ensure_installed = {}, -- don’t force installs yet
		auto_install = false, -- avoid compile on startup
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end,
}
