return {
	"nvim-tree/nvim-tree.lua",
	cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{ "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "Tree: Toggle" },
		{ "<leader>nf", "<cmd>NvimTreeFindFile<CR>", desc = "Tree: Reveal file" },
	},
	config = function()
		require("nvim-tree").setup({
			disable_netrw = true,
			hijack_netrw = true,
			sync_root_with_cwd = true,
			respect_buf_cwd = true,
			update_focused_file = { enable = true, update_root = true },
			view = { width = 35, preserve_window_proportions = true },
			renderer = { group_empty = true, highlight_git = true, indent_markers = { enable = true } },
			filters = { dotfiles = false, git_ignored = false },
			actions = { use_system_clipboard = true, open_file = { quit_on_open = false, resize_window = true } },
			trash = { cmd = "trash", require_confirm = true },
		})
		local function on_attach(bufnr)
			local api = require("nvim-tree.api")
			local function map(lhs, rhs, desc)
				vim.keymap.set("n", lhs, rhs, { buffer = bufnr, nowait = true, silent = true, desc = "Tree: " .. desc })
			end
			map("<CR>", api.node.open.edit, "Open")
			map("o", api.node.open.edit, "Open")
			map("<C-r>", api.tree.reload, "Refresh")
			map("?", api.tree.toggle_help, "Help")
			map("a", api.fs.create, "Create")
			map("d", api.fs.remove, "Delete (trash)")
			map("r", api.fs.rename, "Rename")
			map("y", api.fs.copy.node, "Duplicate")
			map("x", api.fs.cut, "Cut")
			map("c", api.fs.copy.node, "Copy")
			map("p", api.fs.paste, "Paste")
			map("H", api.tree.toggle_hidden_filter, "Toggle dotfiles")
		end
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "NvimTree",
			callback = function(a)
				on_attach(a.buf)
			end,
		})
	end,
}
