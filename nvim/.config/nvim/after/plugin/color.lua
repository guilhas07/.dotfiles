local colorize = function()
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "none" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
    vim.api.nvim_set_hl(0, "CursorLineNR", { fg = "#fabd2f", bg = "none" })
    vim.api.nvim_set_hl(0, "LineNr", { fg = "#5eacd3" })
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "FloatBorder", { link = "Normal" })
    vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
    vim.api.nvim_set_hl(0, "DiagnosticSignError", { link = "DiagnosticError" })
    vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { link = "DiagnosticWarn" })
    vim.api.nvim_set_hl(0, "DiagnosticSignHint", { link = "DiagnosticHint" })
    vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { link = "DiagnosticInfo" })
end
local group = vim.api.nvim_create_augroup("Colors", {})
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = colorize,
    group = group,
})

vim.cmd.colorscheme("gruvbox")
