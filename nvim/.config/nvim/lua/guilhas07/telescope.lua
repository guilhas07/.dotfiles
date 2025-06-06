local telescope = require("telescope")

local builtin = require("telescope.builtin")
local themes = require("telescope.themes")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local config = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

telescope.setup({
    defaults = {
        mappings = {
            i = {
                ["<C-n>"] = "move_selection_previous",
                ["<C-p>"] = "move_selection_next",
            },
        },
        path_display = {"smart"},
    },
})

function find_files()
	builtin.find_files({ hidden = true, no_ignore = true })
end

local private_plugin = {}
local id = 1
for _, plugin in ipairs(require("lazy").plugins()) do
	-- local plugin
	if plugin[1] == nil then
		private_plugin[id] = plugin["name"]
		id = id + 1
	end
end

local reload_opts = {
	prompt_title = "Reload Plugins",
	finder = finders.new_table({
		results = private_plugin,
	}),
	sorter = config.generic_sorter({}),
	attach_mappings = function(prompt_bufnr, _)
		actions.select_default:replace(function()
			actions.close(prompt_bufnr)
			local selected = action_state.get_selected_entry()
			require("lazy.core.loader").reload(selected[1])
		end)
		return true
	end,
}

telescope.load_extension("fzf")

-- KeyMaps --
vim.keymap.set("n", "<leader>pr", function()
	pickers.new({}, reload_opts):find()
end)

vim.keymap.set("n", "gr", builtin.lsp_references)

vim.keymap.set("n", "<leader>fb", builtin.buffers)
vim.keymap.set("n", "<leader>fgg", builtin.live_grep)
vim.keymap.set("n", "<leader>fgh", function()
	builtin.live_grep({ additional_args = { "--no-ignore" } })
end)
vim.keymap.set("n", "<leader>h", builtin.help_tags)
vim.keymap.set("n", "<leader>dl", builtin.diagnostics)
vim.keymap.set("n", "<leader>m", function()
	builtin.man_pages({ sections = { "ALL" } })
end)

vim.keymap.set("n", "<leader>ff", find_files)

vim.keymap.set("n", "<leader>fd", function()
	builtin.find_files({ cwd = "~/.dotfiles/", hidden = true })
end)

vim.keymap.set("n", "<c-p>", function()
	local ok = pcall(builtin.git_files, { show_untracked = true })
	if not ok then
		find_files()
	end
end)


local key = (_G.IS_WSL or vim.fn.exists("$TMUX") ~= 0) and "<c-_>" or "<c-/>"

vim.keymap.set("n", key, function()
	builtin.current_buffer_fuzzy_find({
		sorting_strategy = "ascending",
		layout_config = { prompt_position = "top" },
	})
end)
