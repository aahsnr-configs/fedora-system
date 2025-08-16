# Neovim Setup

Here is the corrected, enhanced, and rewritten Neovim configuration.
[Note]: _Prevent automatic installations of Mason packages. These will handled by nix-shell_

---

### 📂 Final File Structure

The modular structure is preserved and expanded to accommodate the new enhancements.

```
nvim
├── init.lua
└── lua
    ├── core
    │   ├── keymaps.lua
    │   ├── lazy.lua
    │   └── options.lua
    ├── lsp
    │   ├── bash.lua
    │   ├── css.lua
    │   ├── elisp.lua
    │   └── python.lua
    └── plugins
        ├── autopairs.lua
        ├── comment.lua
        ├── completion.lua
        ├── dap.lua
        ├── formatter.lua
        ├── gitsigns.lua
        ├── indent-blankline.lua
        ├── linter.lua
        ├── lsp.lua
        ├── lualine.lua
        ├── nvim-tree.lua
        ├── telescope.lua
        ├── theme.lua
        ├── treesitter.lua
        └── which-key.lua
```

---

### 📜 `init.lua`

**Purpose**: The main entry point. It's kept clean and simple, only loading the core modules. The colorscheme is now set within its own plugin file (`plugins/theme.lua`) to ensure it loads correctly at startup.

```lua
-- init.lua

-- Set leader key before anything else
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Load core configuration modules
-- These must be loaded first
require('core.options')
require('core.keymaps')

-- Load the plugin manager (lazy.nvim)
-- This will automatically load all plugin configurations
require('core.lazy')
```

---

### 🪨 `core` Configuration

This directory contains the essential, foundational settings for Neovim.

#### `core/options.lua`

**Purpose**: Sets global Neovim options for a modern and consistent editing experience.

```lua
-- core/options.lua

local opt = vim.opt -- for conciseness

-- Line numbers
opt.relativenumber = true
opt.number = true

-- Tabs and indentation
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- File handling
opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv('HOME') .. '/.vim/undodir'
opt.undofile = true

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = false

-- Appearance
opt.termguicolors = true
opt.signcolumn = 'yes'
opt.wrap = false

-- Behavior
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.mouse = 'a'
opt.splitright = true
opt.splitbelow = true
opt.updatetime = 250 -- ms to wait for trigger events
opt.clipboard = 'unnamedplus' -- Sync with system clipboard
```

#### `core/keymaps.lua`

**Purpose**: Defines all custom key mappings for improved workflow and ergonomics.

```lua
-- core/keymaps.lua

local keymap = vim.keymap

-- General keymaps
keymap.set('i', 'jk', '<ESC>', { desc = 'Escape insert mode' })
keymap.set('n', '<ESC>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })

-- Window navigation
keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Buffer navigation
keymap.set('n', '[b', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
keymap.set('n', ']b', '<cmd>bnext<CR>', { desc = 'Next buffer' })
keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = 'Delete Buffer' })

-- Move lines
keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = "Move selected line down" })
keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = "Move selected line up" })

-- Make file executable
keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = 'Make file executable' })
```

#### `core/lazy.lua`

**Purpose**: Configures the `lazy.nvim` plugin manager. It now loads plugin specs from the `plugins` directory, ensuring a clean and organized structure.

```lua
-- core/lazy.lua

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = {
    -- Import all plugin configurations from the plugins directory
    { import = 'plugins' },
  },
  -- Configure lazy.nvim options
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
})
```

---

### 🔌 `plugins` Configuration

Each file in this directory represents a plugin and its configuration, making it easy to add, remove, or modify plugins.

#### `plugins/autopairs.lua`

```lua
-- plugins/autopairs.lua
return {
  'windwp/nvim-autopairs',
  event = "InsertEnter",
  config = function()
    require('nvim-autopairs').setup()
  end,
}
```

#### `plugins/comment.lua`

```lua
-- plugins/comment.lua
return {
  'numToStr/Comment.nvim',
  opts = {},
  lazy = false,
}
```

#### `plugins/completion.lua`

**Purpose**: Combines `nvim-cmp` with various sources for a rich autocompletion experience.

```lua
-- plugins/completion.lua
return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    'hrsh7th/cmp-buffer', -- source for text in current buffer
    'hrsh7th/cmp-path', -- source for file system paths
    'L3MON4D3/LuaSnip', -- snippet engine
    'saadparwaiz1/cmp_luasnip', -- for autocompletion
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-k>'] = cmp.mapping.select_prev_item(), -- Previous item
        ['<C-j>'] = cmp.mapping.select_next_item(), -- Next item
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(), -- Show completion
        ['<C-e>'] = cmp.mapping.abort(), -- Close completion
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
      }),
      -- Sources for autocompletion
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
      }),
    })
  end,
}
```

#### `plugins/dap.lua`

**Purpose**: Configures the Debug Adapter Protocol (DAP) for debugging, now using `mason-nvim-dap` to auto-install debuggers.

```lua
-- plugins/dap.lua
return {
  -- Debug Adapter Protocol
  "mfussenegger/nvim-dap",
  dependencies = {
    -- Installs DAP adapters automatically
    "williamboman/mason.nvim",
    "jay-babu/mason-nvim-dap.nvim",

    -- A good UI for DAP
    "rcarriga/nvim-dap-ui",

    -- Simplifies python debugging
    "mfussenegger/nvim-dap-python",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    -- Automatically install and configure DAP servers
    require("mason-nvim-dap").setup({
      ensure_installed = { "python" },
      handlers = {},
    })

    -- nvim-dap-python setup
    require("dap-python").setup("python")

    dapui.setup()

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end

    vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "DAP: Continue" })
    vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "DAP: Step Over" })
    vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "DAP: Step Into" })
    vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
    vim.keymap.set("n", "<leader>dt", dapui.toggle, { desc = "DAP: Toggle UI" })
  end,
}
```

#### `plugins/formatter.lua`

```lua
-- plugins/formatter.lua
return {
  'stevearc/conform.nvim',
  opts = {
    notify_on_error = false,
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'isort', 'black' },
      bash = { 'shfmt' },
      css = { 'prettier' },
    },
  },
}
```

#### `plugins/gitsigns.lua`

```lua
-- plugins/gitsigns.lua
return {
  'lewis6991/gitsigns.nvim',
  opts = {
    signs = { add = { text = '▎' }, change = { text = '▎' }, delete = { text = '' } },
  },
}
```

#### `plugins/indent-blankline.lua`

```lua
-- plugins/indent-blankline.lua
return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  opts = {},
}
```

#### `plugins/linter.lua`

```lua
-- plugins/linter.lua
return {
  "mfussenegger/nvim-lint",
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = {
      python = { "ruff" },
      bash = { "shellcheck" },
    }
    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
      callback = function() lint.try_lint() end,
    })
  end,
}
```

#### `plugins/lsp.lua`

**Purpose**: Handles LSP setup using `mason` to install and manage language servers automatically.

```lua
-- plugins/lsp.lua
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    local on_attach = function(_, bufnr)
      local nmap = function(keys, func, desc)
        if desc then
          desc = "LSP: " .. desc
        end
        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
      end
      nmap("gD", vim.lsp.buf.declaration, "Go to Declaration")
      nmap("gd", vim.lsp.buf.definition, "Go to Definition")
      nmap("K", vim.lsp.buf.hover, "Hover Documentation")
      nmap("<leader>cr", vim.lsp.buf.rename, "Code Rename")
    end

    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "pyright", "bashls", "cssls", "emacs_lisp_ls", "lua_ls", "tsserver" },
      handlers = {
        function(server_name) -- default handler
          require("lspconfig")[server_name].setup({ on_attach = on_attach })
        end,
        ["lua_ls"] = function()
          require("lspconfig").lua_ls.setup({
            on_attach = on_attach,
            settings = { Lua = { diagnostics = { globals = { "vim" } } } },
          })
        end,
      },
    })
  end,
}
```

#### `plugins/lualine.lua`

```lua
-- plugins/lualine.lua
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = { options = { theme = 'tokyonight' } },
}
```

#### `plugins/nvim-tree.lua`

```lua
-- plugins/nvim-tree.lua
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("nvim-tree").setup()
    vim.keymap.set('n', '<leader>ee', '<cmd>NvimTreeToggle<cr>', { desc = 'Toggle File Explorer' })
  end
}
```

#### `plugins/telescope.lua`

**Purpose**: Configures the fuzzy finder `Telescope` and adds `flash.nvim` for enhanced navigation.

```lua
-- plugins/telescope.lua
return {
  'nvim-telescope/telescope.nvim',
  dependencies = { 'nvim-lua/plenary.nvim',
    -- Enhanced navigation
    {
      "folke/flash.nvim",
      event = "VeryLazy",
      opts = {},
      -- Overriding default 's' key for flash
      keys = {
        { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
      },
    },
  },
  config = function()
    require('telescope').setup({})
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live Grep' })
  end,
}
```

#### `plugins/theme.lua`

```lua
-- plugins/theme.lua
return {
  "folke/tokyonight.nvim",
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    -- load the colorscheme here
    vim.cmd.colorscheme 'tokyonight'
  end,
}
```

#### `plugins/treesitter.lua`

**Purpose**: Manages `nvim-treesitter` for advanced syntax highlighting and adds `nvim-ts-autotag` for auto-closing/renaming HTML/XML tags.

```lua
-- plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  dependencies = { "windwp/nvim-ts-autotag" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "bash", "css", "elisp", "html", "javascript", "lua", "python", "typescript", "vim" },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      autotag = { enable = true },
    })
  end,
}
```

#### `plugins/which-key.lua`

```lua
-- plugins/which-key.lua
return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  config = function()
    require('which-key').setup()
  end,
}
```

---

### 🌐 `lsp` Configuration

These files are placeholders for any language-specific overrides you might want in the future. For now, they can remain empty as the main LSP setup is handled centrally. I've added comments explaining their purpose.

#### `lsp/python.lua`

```lua
-- lsp/python.lua
-- This file can be used for Python-specific LSP configurations.
-- For example, to enable inlay hints:
--
-- require('lspconfig').pyright.setup({
--   settings = {
--     python = {
--       analysis = {
--         inlayHints = {
--           variableTypes = true,
--           functionReturnTypes = true,
--         },
--       },
--     },
--   },
-- })

return {}
```

#### `lsp/bash.lua`, `lsp/css.lua`, `lsp/elisp.lua`

These can remain as `return {}`. They exist so you can easily add language-specific settings without modifying the core LSP configuration.
