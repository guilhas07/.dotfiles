local border = "rounded"

local M = {}

function M.setup(on_attach)
    local null_ls = require("null-ls")
    local b = null_ls.builtins

    null_ls.setup({
        on_attach = on_attach,
        sources = {
            b.formatting.stylua,
            b.formatting.prettier,
            --b.formatting.fixjson,
            --b.diagnostics.selene.with(),
        },
        border = border,
    })
end

return M
