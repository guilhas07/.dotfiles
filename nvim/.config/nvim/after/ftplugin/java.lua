local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
local path_to_plugins = jdtls_path .. "/plugins"
local path_to_config = jdtls_path .. "/config_linux"
local lombok_path = jdtls_path .. "/lombok.jar"
local path_to_jar = path_to_plugins .. "/org.eclipse.equinox.launcher_1.6.800.v20240304-1850.jar"

local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls/" .. project_name

local config = {
	cmd = {
		"java",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xms1g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"-javaagent:" .. lombok_path,
		"-jar",
		path_to_jar,
		"-configuration",
		path_to_config,
		"-data",
		workspace_dir,
	},
	settings = {
		java = {
			inlayHints = { enabled = "all" },
			signatureHelp = { enabled = true },
			-- FIX(saveActions): when formatting removes imports if there are errors.
			-- saveActions = { organizeImports = true },
			-- cleanUp = {
			-- 	"qualifyMembers",
			-- 	"qualifyStaticMembers",
			-- 	"addOverride",
			-- 	"addDeprecated",
			-- 	"stringConcatToTextBlock",
			-- 	"invertEquals",
			-- 	"addFinalModifier",
			-- 	"instanceofPatternMatch",
			-- 	"lambdaExpression",
			-- 	"switchExpression",
			-- },
		},
	},
	root_dir = vim.fs.dirname(vim.fs.find(root_markers, { upward = true })[1]),
	on_attach = require("guilhas07.lsp.utils").on_attach,
}

require("jdtls").start_or_attach(config)
