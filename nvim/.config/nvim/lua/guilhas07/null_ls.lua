local nl = require("null-ls")
local b = nl.builtins

local function on_attach(client, bufnr)
        local bufopts = { noremap = true, buffer = bufnr }
        vim.keymap.set("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
        end, bufopts)
end

nl.setup({
    on_attach = on_attach,
    sources = {
        b.formatting.stylua,
        b.formatting.prettier,
        b.formatting.fixjson,
    },
})
