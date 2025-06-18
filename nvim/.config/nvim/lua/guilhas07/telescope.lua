local builtin = require('telescope.builtin')

require('telescope').setup{
}

require('telescope').load_extension('fzf')

-- KeyMaps --
vim.keymap.set('n', '<C-p>', builtin.git_files)
vim.keymap.set('n', '<leader>ff', builtin.find_files)
vim.keymap.set('n', '<leader>fb', builtin.buffers)
vim.keymap.set('n', '<C-_>',
    function()
        return builtin.current_buffer_fuzzy_find({sorting_strategy='ascending', layout_config={prompt_position='top'}})
    end)
