local builtin = require("telescope.builtin")
local themes = require("telescope.themes")

require("telescope").setup({
    pickers = {
        find_files = {
            mappings = {
                i = {
                    ["<C-n>"] = "move_selection_previous",
                    ["<C-p>"] = "move_selection_next",
                },
            },
        },
    },
})

require("telescope").load_extension("fzf")

-- KeyMaps --
vim.keymap.set("n", "gr", builtin.lsp_references)

vim.keymap.set("n", "<leader>fb", builtin.buffers)
vim.keymap.set("n", "<leader>fg", builtin.live_grep)
vim.keymap.set("n", "<leader>h", builtin.help_tags)
vim.keymap.set("n", "<leader>m", function()
    builtin.man_pages({ sections = { "ALL" } })
end)

vim.keymap.set("n", "<leader>ff", function()
    builtin.find_files({ hidden = true, layout_config = {} })
end)

vim.keymap.set("n", "<leader>fd", function()
    builtin.git_files(themes.get_dropdown({ cwd = "~/.dotfiles/", previewer = false, show_untracked = true }))
end)

vim.keymap.set("n", "<c-p>", function()
    builtin.git_files(themes.get_dropdown({ previewer = false, show_untracked = true }))
end)

vim.keymap.set("n", "<c-_>", function()
    builtin.current_buffer_fuzzy_find({
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top" },
    })
end)
