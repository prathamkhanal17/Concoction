-- ~/.config/nvim/lua/config/keymaps.lua
local map = vim.keymap.set
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Quit all (force)" })
map("n", "<leader>ev", "<cmd>e $MYVIMRC<CR>", { desc = "Open init.lua" })
map("n", "<leader>sv", "<cmd>luafile %<CR>", { desc = "Source current lua" })
map("i", "jk", "<Esc>", { desc = "JK for escape" })
