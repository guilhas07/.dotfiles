vim.ui.open = (function(overridden)
	return function(path, opt)
		-- Use explorer.exe in wsl
		if _G.IS_WSL then
			opt = { cmd = { "explorer.exe" } }
		end
		return overridden(path, opt)
	end
end)(vim.ui.open)
