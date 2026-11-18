-- kotlin-lsp: open dependency sources.
--
-- gd into a dependency gives `jar:///…!/Foo.java` / `jrt:///…` URIs. LSP 3.18 serves their
-- text via `workspace/textDocumentContent`; nvim doesn't wire it to buffer reads yet.
-- Drop this once upstream lands: https://github.com/neovim/neovim/pull/39592
-- (issue https://github.com/neovim/neovim/issues/39526).
local M = {}

local CLIENT = "kotlin_lsp"

function M.setup()
	vim.api.nvim_create_autocmd("BufReadCmd", {
		group = vim.api.nvim_create_augroup("guilhas07.jar", { clear = true }),
		pattern = { "jar://*", "jrt://*" },
		callback = function(ev)
			local client = vim.lsp.get_clients({ name = CLIENT })[1]
			if not client then return end
			-- sync: gd jumps to the line right after this returns
			local res = client:request_sync("workspace/textDocumentContent", { uri = ev.match }, 10000, ev.buf)
			if not (res and res.result) then return end
			vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, vim.split(res.result.text, "\n"))
			vim.bo[ev.buf].buftype = "nofile"
			vim.bo[ev.buf].modifiable = false
			vim.bo[ev.buf].filetype = vim.filetype.match({ filename = ev.match }) or ""
			vim.schedule(function() vim.lsp.buf_attach_client(ev.buf, client.id) end)
		end,
	})
end

return M
