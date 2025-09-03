return {
	"mhinz/vim-startify",
	event = "VimEnter",
	init = function()
		vim.g.startify_disable_at_vimenter = 0
	end,
}
