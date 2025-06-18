local prefix = "guilhas07"

local M = {}
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup(prefix .. ":Highlight_on_yank", {}),
	callback = function()
		vim.highlight.on_yank()
	end,
})

function M.inlay_hint(buf)
	local group = vim.api.nvim_create_augroup(prefix .. ":Toggle_inlay_hints_on_insert", {})
	vim.api.nvim_clear_autocmds({ group = group, buffer = buf })
	vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
		desc = "Toggle inlay hints on insert.",
		group = group,
		buffer = buf,
		callback = (function()
			local bufs = {}
			local scheduled = nil
			return function(ev)
				if ev.event == "InsertEnter" then
					local is_enabled = vim.lsp.inlay_hint.is_enabled()
					bufs[ev.buf] = is_enabled
					vim.lsp.inlay_hint.enable(false, { bufnr = ev.buf })
				else
					if scheduled then
						-- print("here closing on " .. ev.buf)
						scheduled:close()
					end
					scheduled = vim.defer_fn(function()
						vim.lsp.inlay_hint.enable(bufs[ev.buf], { bufnr = ev.buf })
						bufs[ev.buf] = nil
						scheduled = nil
					end, 2000)
				end
			end
		end)(),
	})
end

return M
-- redir >> % | silent messages | redir END
