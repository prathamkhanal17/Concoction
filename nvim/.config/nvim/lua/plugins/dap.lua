return {
	{
		"mfussenegger/nvim-dap",
		event = "VeryLazy",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			require("nvim-dap-virtual-text").setup()

			local dap, dapui = require("dap"), require("dapui")
			dapui.setup()

			-- Python debug adapter (uses debugpy from Nix/venv)
			dap.adapters.python = {
				type = "executable",
				command = "python",
				args = { "-m", "debugpy.adapter" },
			}

			dap.configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Launch file",
					program = function()
						return vim.fn.expand("%:p")
					end,
					console = "integratedTerminal",
					pythonPath = function()
						if vim.env.VIRTUAL_ENV then
							return vim.env.VIRTUAL_ENV .. "/bin/python"
						end
						return "python"
					end,
				},
			}

			-- Keymaps
			vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
			vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
			vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
			vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
			vim.keymap.set("n", "<leader>dB", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "Debug: Conditional BP" })
			vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Debug: REPL" })
			vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug: UI toggle" })

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end,
	},
}
