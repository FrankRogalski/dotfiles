-- Minimal, mostly OOTB Neovim (Helix-ish) — no plugins
vim.g.python3_host_prog = vim.fn.expand("~/.local/share/nvim/py3/bin/python")
vim.g.perl_host_prog = "/opt/homebrew/opt/perl/bin/perl"
vim.g.loaded_perl_provider = 0
-- ---------- Options ----------
vim.g.mapleader = " "
local o = vim.opt
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.mouse = "a"
o.termguicolors = true
vim.cmd.colorscheme("habamax")
o.clipboard = "unnamedplus"
o.ignorecase = true
o.smartcase = true
o.incsearch = true
o.updatetime = 200
o.splitright = true
o.splitbelow = true
o.completeopt = { "menuone", "noinsert", "noselect" }
o.grepprg = "rg --vimgrep --smart-case"
o.grepformat = "%f:%l:%c:%m"

-- netrw (built-in file explorer)
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 0
vim.g.netrw_use_errorwindow = 0

-- ---------- Keymaps ----------
local map = vim.keymap.set
map("n", "<leader>e", ":Lexplore<CR>", { silent = true, desc = "Toggle netrw" })
map("n", "<leader>sf", function()
	local input = vim.fn.input("rg › ")
	if input ~= "" then
		vim.cmd("grep! " .. input)
		vim.cmd("copen")
	end
end, { desc = "Search project (rg)" })
map("n", "<leader>sw", function()
	vim.cmd("grep! " .. vim.fn.expand("<cword>"))
	vim.cmd("copen")
end, { desc = "Search word under cursor (rg)" })
map("n", "[q", ":cprev<CR>", { silent = true })
map("n", "]q", ":cnext<CR>", { silent = true })
map("n", "<leader>q", ":copen<CR>", { silent = true })

-- ---------- Diagnostics UI ----------
vim.diagnostic.config({
	underline = true,
	virtual_text = { spacing = 2 },
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
})

-- ---------- LSP (no lspconfig, pure core) ----------
-- Helper: find project root by patterns
local function root_dir(bufnr, patterns)
	patterns = patterns or { ".git" }
	local fname = vim.api.nvim_buf_get_name(bufnr)
	local dir = vim.fs.dirname(fname)
	local found = vim.fs.find(patterns, { path = dir, upward = true })[1]
	return found and vim.fs.dirname(found) or vim.loop.cwd()
end

local function on_attach(client, bufnr)
	local bmap = function(mode, lhs, rhs, desc)
		map(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
	end
	bmap("n", "gd", vim.lsp.buf.definition, "Goto Definition")
	bmap("n", "gr", vim.lsp.buf.references, "References")
	bmap("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
	bmap("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
	bmap("n", "K", vim.lsp.buf.hover, "Hover")
	bmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
	bmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
	bmap("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
	bmap("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
	bmap("n", "<leader>e", vim.diagnostic.open_float, "Line Diagnostics")
	vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
end

-- Trigger completion like Helix: <C-Space>
map("i", "<C-Space>", "<C-x><C-o>")

-- Autostart a few popular servers if available on PATH.
-- Remove what you don't need, add others analogously.
local servers = {
	-- JS/TS
	{
		name = "tsserver",
		cmd = { "typescript-language-server", "--stdio" },
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
		root = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	},
	-- Python
	{
		name = "basedpyright",
		cmd = { "uvx", "--from", "basedpyright", "basedpyright-langserver", "--stdio" },
		filetypes = { "python" },
		root = { "pyproject.toml", "setup.cfg", "setup.py", "requirements.txt", ".git" },
	},

	{
		name = "ruff_lsp",
		cmd = { "uvx", "--from", "ruff", "ruff", "server" },
		filetypes = { "python" },
		root = { "pyproject.toml", ".git" },
	},
	-- Go
	{ name = "gopls",         cmd = { "gopls" },                         filetypes = { "go" },   root = { "go.work", "go.mod", ".git" } },
	-- Rust
	{ name = "rust_analyzer", cmd = { "rust-analyzer" },                 filetypes = { "rust" }, root = { "Cargo.toml", ".git" } },
	-- Shell
	{ name = "bashls",        cmd = { "bash-language-server", "start" }, filetypes = { "sh" },   root = { ".git" } },
	-- Lua (for editing Neovim config)
	{
		name = "lua_ls",
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
		root = { ".luarc.json", ".luarc.jsonc", ".git" },
		settings = { Lua = { diagnostics = { globals = { "vim" } } } },
	},
}

for _, s in ipairs(servers) do
	vim.api.nvim_create_autocmd("FileType", {
		pattern = s.filetypes,
		callback = function(args)
			local bufnr = args.buf
			-- Avoid dupes
			for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
				if c.name == s.name then return end
			end
			vim.lsp.start({
				name = s.name,
				cmd = s.cmd,
				root_dir = root_dir(bufnr, s.root),
				settings = s.settings,
				on_attach = on_attach,
				capabilities = vim.lsp.protocol.make_client_capabilities(),
			})
		end,
	})
end

-- Format on save (fast, synchronous)
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function(args)
		pcall(vim.lsp.buf.format, { bufnr = args.buf, timeout_ms = 1000 })
	end,
})
