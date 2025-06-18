local colorize = function()

    -- remove lsp comment highlighting
    -- vim.api.nvim_set_hl(0, '@lsp.type.comment', {})

    -- patch gruvbox colors
    if vim.g.colors_name == "gruvbox" then
        -- clear semantic token for gruvbox functions
        local cursor_hl = vim.api.nvim_get_hl(0, { name = "CursorLineNr" })
        vim.api.nvim_set_hl(0, "@lsp.type.function.lua", {})

        -- fix sign/number column
        vim.api.nvim_set_hl(0, "SignColumn", {})
        vim.api.nvim_set_hl(0, "CursorLineNr", { fg = cursor_hl["fg"], bg = "none" })
    end
end

local group = vim.api.nvim_create_augroup("Colors", {})
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = colorize,
    group = group,
})

vim.cmd.colorscheme("gruvbox")
