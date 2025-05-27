return {
	"zbirenbaum/copilot.lua",
	keys = {
		{
			"<leader>at",
			function()
				if require("copilot.client").is_disabled() then
					require("copilot.command").enable()
				else
					require("copilot.command").disable()
				end
			end,
			desc = "Toggle (Copilot)",
		},
	},
	opts = {
		logger = {
			log_to_file = false,
			file = vim.fn.stdpath("log") .. "/copilot-lua.log",
			file_log_level = vim.log.levels.WARN,
			print_log = true,
			print_log_level = vim.log.levels.WARN,
			trace_lsp = "off", -- "off" | "messages" | "verbose"
			trace_lsp_progress = false,
		},
	},
}
