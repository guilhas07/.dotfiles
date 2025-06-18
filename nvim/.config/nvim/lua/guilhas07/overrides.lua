vim.ui.open = (function(overridden)
	return function(path, opt)
		-- Use explorer.exe in wsl
		if _G.IS_WSL then
			opt = { cmd = { "explorer.exe" } }
		end
		return overridden(path, opt)
	end
end)(vim.ui.open)

vim.diagnostic.jump = (function(overridden)
	---@param opts vim.diagnostic.JumpOpts
	return function(opts)
        overridden(vim.tbl_extend("error", opts, { _highest = true, float = true }))
	end
end)(vim.diagnostic.jump)
