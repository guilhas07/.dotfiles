local cmp = require 'cmp'
local lspkind = require('lspkind')

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<C-y>'] = cmp.mapping.confirm({select = true}),
    }),
    formatting = {
        format = lspkind.cmp_format({
            with_text = true,
            menu = {
                buffer = '[Buffer]',
                nvim_lsp = '[LSP]',
                nvim_lua = '[Lua]',
                path = '[Path]',
                luasnip = '[Snip]'
            }

        })
    },

    sources = {
        { name = 'nvim_lua' },
        { name = 'nvim_lsp' },
        { name = 'path' },
        { name = 'luasnip' },
        { name = 'buffer', keyword_length = 5 },
    },
    experimental = {
        ghost_text = true,
    },
    view = {
        entries = 'custom'
    }
})

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- local lsp_installer = require("nvim-lsp-installer").setup{}

require("mason").setup()
require("mason-lspconfig").setup({
      ensure_installed = { "sumneko_lua", "tsserver", "ccls", "jdtls" }
})

local function on_attach(client, bufnr)
  -- Set up buffer-local keymaps (vim.api.nvim_buf_set_keymap()), etc.
  vim.keymap.set("n", "K", vim.lsp.buf.hover, {buffer = bufnr})
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, {buffer = bufnr})
  vim.keymap.set("n", "<leader>[d", vim.diagnostic.goto_next, {buffer = bufnr})
  vim.keymap.set("n", "<leader>d]", vim.diagnostic.goto_prev, {buffer = bufnr})
  vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, {buffer = bufnr})
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {buffer = bufnr})
end

local lspconfig = require("lspconfig")

lspconfig.sumneko_lua.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            },
        },
    }
}
lspconfig.tsserver.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

lspconfig.ccls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

lspconfig.jdtls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

-- lsp_installer.on_server_ready(function(server)
 -- -- Specify the default options which we'll use to setup all servers
 --   local opts = {
 --       capabilities = capabilities,
 --       on_attach = on_attach,
 --   }

 --   if server.name == 'sumneko_lua' then
 --       opts.settings = {
 --           Lua = {
 --               diagnostics = {globals = {'vim'}}
 --           }
 --       }
 --   end
  --if enhance_server_opts[server.name] then
  --  -- Enhance the default opts with the server-specific ones
  --  enhance_server_opts[server.name](opts)
  --end

--  server:setup(opts)
--end)


-- Register a handler that will be called for each installed server when it's ready (i.e. when installation is finished
-- or if the server is already installed).
--lsp_installer.on_server_ready(function(server)
--    local opts = {}
--
--    -- (optional) Customize the options passed to the server
--    -- if server.name == "tsserver" then
--    --     opts.root_dir = function() ... end
--    -- end
--
--    -- This setup() function will take the provided server configuration and decorate it with the necessary properties
--    -- before passing it onwards to lspconfig.
--    -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
--    server:setup(opts)
--end)
