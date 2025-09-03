return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lspconfig = require("lspconfig")
		local caps = require("cmp_nvim_lsp").default_capabilities()
		local util = require("lspconfig.util")

		local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		local function on_attach(_, bufnr)
			local map = function(lhs, rhs, desc)
				vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
			end
			map("gd", vim.lsp.buf.definition, "Go to definition")
			map("gD", vim.lsp.buf.declaration, "Go to declaration")
			map("gi", vim.lsp.buf.implementation, "Go to implementation")
			map("gr", vim.lsp.buf.references, "List references")
			map("g0", vim.lsp.buf.document_symbol, "Document symbols")
			map("K", vim.lsp.buf.hover, "Hover docs")
			map("<leader>ca", vim.lsp.buf.code_action, "Code action")
			map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
			map("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
			map("]d", vim.diagnostic.goto_next, "Next diagnostic")
			map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
			map("<leader>cli", "<cmd>LspInfo<CR>", "LSP info")
		end

		local root = util.root_pattern("pyproject.toml", "setup.cfg", "setup.py", "requirements.txt", ".git")

		lspconfig.pyright.setup({
			on_attach = on_attach,
			capabilities = caps,
			cmd = { "pyright-langserver", "--stdio" },
			root_dir = function(fname)
				return root(fname) or vim.loop.cwd()
			end,
			settings = { python = { analysis = { typeCheckingMode = "basic", autoImportCompletions = true } } },
		})

		lspconfig.ruff.setup({
			on_attach = on_attach,
			capabilities = caps,
			cmd = { "ruff", "server" },
			root_dir = function(fname)
				return root(fname) or vim.loop.cwd()
			end,
			-- init_options = { settings = { args = { "--ignore=F821" } } }, -- optional to avoid Pyright overlap
		})

		lspconfig.marksman.setup({
			on_attach = on_attach,
			capabilities = caps,
			cmd = { "marksman", "server" },
			filetypes = { "markdown", "mdx" },
			root_dir = util.root_pattern(".git", ".marksman.toml") or vim.loop.cwd,
		})
	end,
}
