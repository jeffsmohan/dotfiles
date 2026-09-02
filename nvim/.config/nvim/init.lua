-- Helpers
local function gh(repo)
  return "https://github.com/" .. repo
end

-- OPTIONS: Core nvim settings, leaders, options
do
  vim.loader.enable() -- Cache compiled Lua modules

  -- Leader key: <Space>
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  -- Input helpers
  vim.o.number = true
  vim.o.relativenumber = true
  vim.o.cursorline = true
  vim.o.signcolumn = "yes"
  vim.o.scrolloff = 10
  vim.o.sidescrolloff = 10
  vim.o.mouse = "a" -- all modes
  vim.o.showmode = false -- displayed in status line instead
  vim.o.undofile = true

  -- Timing/behaviors
  vim.o.confirm = true
  vim.o.updatetime = 250
  vim.o.timeoutlen = 1000
  vim.schedule(function() -- deferred for faster startup time
    vim.o.clipboard = "unnamedplus" -- sync nvim/OS clipboards
  end)

  -- Coding helpers
  vim.o.breakindent = true
  vim.o.list = true
  vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
  vim.o.shiftwidth = 2
  vim.o.softtabstop = -1 -- Use shiftwidth
  vim.o.expandtab = true

  -- Line wrap off for code; on for prose
  vim.o.wrap = false
  vim.api.nvim_create_autocmd("FileType", {
    desc = "Set line wrap on for prose content",
    group = vim.api.nvim_create_augroup("wrap-by-filetype", { clear = true }),
    callback = function(args)
      local prose = { markdown = true, text = true, gitcommit = true, rst = true }
      vim.wo.wrap = prose[args.match]
    end,
  })

  -- Find/replace
  vim.o.ignorecase = true
  vim.o.smartcase = true
  vim.o.inccommand = "split"

  -- Windows/UI
  vim.g.have_nerd_font = true
  vim.o.splitright = true
  vim.o.splitbelow = true
  vim.o.winborder = "bold"
end

-- KEYMAPS: basic mappings
do
  -- Clear highlights on search when pressing <Esc> in normal mode
  vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

  -- Diagnostic Config & Keymaps
  vim.diagnostic.config({
    update_in_insert = false,
    severity_sort = true,
    float = { source = "if_many" },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },
    virtual_text = true,
    jump = {
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float({
          bufnr = bufnr,
          scope = "cursor",
          focus = false,
        })
      end,
    },
  })
  vim.keymap.set(
    "n",
    "<leader>q",
    vim.diagnostic.setloclist,
    { desc = "Open diagnostic [Q]uickfix list" }
  )

  -- Rebind arrow keys to window resizing
  vim.keymap.set("n", "<Up>", "<cmd>resize +2<CR>", { desc = "Grow window height" })
  vim.keymap.set("n", "<Down>", "<cmd>resize -2<CR>", { desc = "Shrink window height" })
  vim.keymap.set(
    "n",
    "<Left>",
    "<cmd>vertical resize -2<CR>",
    { desc = "Narrow window width" }
  )
  vim.keymap.set(
    "n",
    "<Right>",
    "<cmd>vertical resize +2<CR>",
    { desc = "Grow window width" }
  )

  -- Window navigation
  vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
  vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
  vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
  vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
  vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
  vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
  vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
  vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

  vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
      vim.hl.on_yank()
    end,
  })
end

-- PLUGIN MANAGER: vim.pack
do
  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local stderr = result.stderr or ""
      local stdout = result.stdout or ""
      local output = stderr ~= "" and stderr or stdout
      if output == "" then
        output = "No output from build command."
      end
      vim.notify(("Build failed for %s:\n%s"):format(name, output), vim.log.levels.ERROR)
    end
  end

  vim.api.nvim_create_autocmd("PackChanged", {
    desc = "Runs build command or setup after plugin installed or updated",
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      if kind ~= "install" and kind ~= "update" then
        return
      end

      if name == "telescope-fzf-native.nvim" and vim.fn.executable("make") == 1 then
        run_build(name, { "make" }, ev.data.path)
        return
      end

      if name == "LuaSnip" then
        if vim.fn.has("win32") ~= 1 and vim.fn.executable("make") == 1 then
          run_build(name, { "make", "install_jsregexp" }, ev.data.path)
        end
        return
      end

      if name == "nvim-treesitter" then
        if not ev.data.active then
          vim.cmd.packadd("nvim-treesitter")
        end
        vim.cmd("TSUpdate")
        return
      end
    end,
  })
end

-- THEME/COLORS: Kanagawa Wave
do
  -- Terminal palette isn't rich enough an editor, so use the full vim theme
  vim.pack.add({ gh("rebelot/kanagawa.nvim") })
  vim.cmd.colorscheme("kanagawa-wave")
end

-- PLUGIN: Gitsigns
do
  vim.pack.add({ gh("lewis6991/gitsigns.nvim") })
  local gitsigns = require("gitsigns")

  -- Helper to toggle blame sidebar (close buffer if open; open if not)
  local function toggle_blame()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == "gitsigns-blame" then
        vim.api.nvim_win_close(win, false)
        return
      end
    end
    gitsigns.blame()
  end

  -- Gitsigns config and keymaps
  gitsigns.setup({
    on_attach = function(buffer)
      local map = function(keys, func, desc)
        vim.keymap.set("n", "<leader>g" .. keys, func, { buffer = buffer, desc = desc })
      end
      map("b", gitsigns.blame_line, "[G]it [B]lame line")
      map("B", toggle_blame, "[G]it [B]lame file (toggle)")
      map("s", gitsigns.stage_hunk, "[G]it [S]tage hunk")
      map("S", gitsigns.reset_hunk, "[G]it un[S]tage hunk")
      map("p", gitsigns.preview_hunk, "[G]it [P]review hunk")
      map("d", gitsigns.diffthis, "[G]it [D]iff")
    end,
  })

  -- Gitsigns blame sidebar keymaps
  vim.api.nvim_create_autocmd("FileType", {
    desc = "Set up toggle/close commands on blame buffers",
    pattern = "gitsigns-blame",
    group = vim.api.nvim_create_augroup("gitsigns-blame-keys", { clear = true }),
    callback = function(args)
      vim.keymap.set("n", "<leader>gB", toggle_blame, {
        buffer = args.buf,
        desc = "[G]it [B]lame file (toggle)",
      })
      vim.keymap.set("n", "q", "<cmd>close<CR>", {
        buffer = args.buf,
        desc = "Close blame",
      })
    end,
  })
end

-- PLUGIN: guess-indent
do
  vim.pack.add({ gh("NMAC427/guess-indent.nvim") })
  require("guess-indent").setup({})
end

-- PLUGIN: which-key
do
  vim.pack.add({ gh("folke/which-key.nvim") })
  require("which-key").setup({
    delay = 500,
    preset = "modern",
    icons = { mappings = vim.g.have_nerd_font },
    spec = {
      { "<leader>s", group = "[S]earch", mode = { "n", "v" } },
      { "<leader>g", group = "[G]it" },
      { "gr", group = "LSP Actions", mode = { "n" } },
    },
  })
end

-- PLUGIN: todo-comments
do
  vim.pack.add({ gh("folke/todo-comments.nvim") })
  require("todo-comments").setup({ signs = false })
  vim.keymap.set("n", "<leader>st", "<cmd>TodoTelescope<CR>", {
    desc = "[S]earch [T]odos",
  })
end

-- PLUGIN: mini.nvim modules
do
  vim.pack.add({ gh("nvim-mini/mini.nvim") })

  require("mini.icons").setup()
  MiniIcons.mock_nvim_web_devicons()

  require("mini.ai").setup({
    -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
    mappings = {
      around_next = "aa",
      inside_next = "ii",
    },
    n_lines = 500,
  })

  -- Add/delete/replace surroundings (brackets, quotes, etc.)
  --
  -- - saiw) - [S]urround [A]dd [I]inner [W]ord [)]Paren
  -- - sd'   - [S]urround [D]elete [']quotes
  -- - sr)'  - [S]urround [R]eplace [)] [']
  require("mini.surround").setup()

  -- Simple and easy statusline.
  --  You could remove this setup call if you don't like it,
  --  and try some other statusline plugin
  local statusline = require("mini.statusline")
  -- Set `use_icons` to true if you have a Nerd Font
  statusline.setup({ use_icons = vim.g.have_nerd_font })

  -- You can configure sections in the statusline by overriding their
  -- default behavior. For example, here we set the section for
  -- cursor location to LINE:COLUMN
  ---@diagnostic disable-next-line: duplicate-set-field
  statusline.section_location = function()
    return "%2l:%-2v"
  end

  -- ... and there is more!
  --  Check out: https://github.com/nvim-mini/mini.nvim
end

-- ============================================================
-- SECTION 5: SEARCH & NAVIGATION
-- Telescope setup, keymaps, LSP picker mappings
-- ============================================================
do
  -- [[ Fuzzy Finder (files, lsp, etc) ]]
  --
  -- Telescope is a fuzzy finder that comes with a lot of different things that
  -- it can fuzzy find! It's more than just a "file finder", it can search
  -- many different aspects of Neovim, your workspace, LSP, and more!
  --
  -- There are lots of other alternative pickers (like snacks.picker, or fzf-lua)
  -- so feel free to experiment and see what you like!
  --
  -- The easiest way to use Telescope, is to start by doing something like:
  --  :Telescope help_tags
  --
  -- After running this command, a window will open up and you're able to
  -- type in the prompt window. You'll see a list of `help_tags` options and
  -- a corresponding preview of the help.
  --
  -- Two important keymaps to use while in Telescope are:
  --  - Insert mode: <c-/>
  --  - Normal mode: ?
  --
  -- This opens a window that shows you all of the keymaps for the current
  -- Telescope picker. This is really useful to discover what Telescope can
  -- do as well as how to actually do it!

  ---@type (string|vim.pack.Spec)[]
  local telescope_plugins = {
    gh("nvim-lua/plenary.nvim"),
    gh("nvim-telescope/telescope.nvim"),
    gh("nvim-telescope/telescope-ui-select.nvim"),
  }
  if vim.fn.executable("make") == 1 then
    table.insert(telescope_plugins, gh("nvim-telescope/telescope-fzf-native.nvim"))
  end

  -- NOTE: You can install multiple plugins at once
  vim.pack.add(telescope_plugins)

  -- These pickers shell out to ripgrep, which reads ~/.config/ripgrep/ripgreprc
  -- via RIPGREP_CONFIG_PATH. That is where dot-directories are switched on for
  -- search, so there is deliberately no `hidden` option below.
  --
  -- See `:help telescope` and `:help telescope.setup()`
  require("telescope").setup({
    -- You can put your default mappings / updates / etc. in here
    --  All the info you're looking for is in `:help telescope.setup()`
    --
    -- defaults = {
    --   mappings = {
    --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
    --   },
    -- },
    -- pickers = {}
    extensions = {
      ["ui-select"] = { require("telescope.themes").get_dropdown() },
    },
  })

  -- Enable Telescope extensions if they are installed
  pcall(require("telescope").load_extension, "fzf")
  pcall(require("telescope").load_extension, "ui-select")

  -- See `:help telescope.builtin`
  local builtin = require("telescope.builtin")
  vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
  vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
  vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
  vim.keymap.set(
    "n",
    "<leader>ss",
    builtin.builtin,
    { desc = "[S]earch [S]elect Telescope" }
  )
  vim.keymap.set(
    { "n", "v" },
    "<leader>sw",
    builtin.grep_string,
    { desc = "[S]earch current [W]ord" }
  )
  vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
  vim.keymap.set(
    "n",
    "<leader>sd",
    builtin.diagnostics,
    { desc = "[S]earch [D]iagnostics" }
  )
  vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
  vim.keymap.set(
    "n",
    "<leader>s.",
    builtin.oldfiles,
    { desc = '[S]earch Recent Files ("." for repeat)' }
  )
  vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
  vim.keymap.set(
    "n",
    "<leader><leader>",
    builtin.buffers,
    { desc = "[ ] Find existing buffers" }
  )

  -- Add Telescope-based LSP pickers when an LSP attaches to a buffer.
  -- If you later switch picker plugins, this is where to update these mappings.
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
    callback = function(event)
      local buf = event.buf

      -- Find references for the word under your cursor.
      vim.keymap.set(
        "n",
        "grr",
        builtin.lsp_references,
        { buffer = buf, desc = "[G]oto [R]eferences" }
      )

      -- Jump to the implementation of the word under your cursor.
      -- Useful when your language has ways of declaring types without an actual implementation.
      vim.keymap.set(
        "n",
        "gri",
        builtin.lsp_implementations,
        { buffer = buf, desc = "[G]oto [I]mplementation" }
      )

      -- Jump to the definition of the word under your cursor.
      -- This is where a variable was first declared, or where a function is defined, etc.
      -- To jump back, press <C-t>.
      vim.keymap.set(
        "n",
        "grd",
        builtin.lsp_definitions,
        { buffer = buf, desc = "[G]oto [D]definition" }
      )

      -- Fuzzy find all the symbols in your current document.
      -- Symbols are things like variables, functions, types, etc.
      vim.keymap.set(
        "n",
        "gO",
        builtin.lsp_document_symbols,
        { buffer = buf, desc = "Open Document Symbols" }
      )

      -- Fuzzy find all the symbols in your current workspace.
      -- Similar to document symbols, except searches over your entire project.
      vim.keymap.set(
        "n",
        "gW",
        builtin.lsp_dynamic_workspace_symbols,
        { buffer = buf, desc = "Open Workspace Symbols" }
      )

      -- Jump to the type of the word under your cursor.
      -- Useful when you're not sure what type a variable is and you want to see
      -- the definition of its *type*, not where it was *defined*.
      vim.keymap.set(
        "n",
        "grt",
        builtin.lsp_type_definitions,
        { buffer = buf, desc = "[G]oto [T]type Definition" }
      )
    end,
  })

  -- Override default behavior and theme when searching
  vim.keymap.set("n", "<leader>/", function()
    -- You can pass additional configuration to Telescope to change the theme, layout, etc.
    builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
      winblend = 10,
      previewer = false,
    }))
  end, { desc = "[/] Fuzzily search in current buffer" })

  -- It's also possible to pass additional configuration options.
  --  See `:help telescope.builtin.live_grep()` for information about particular keys
  vim.keymap.set("n", "<leader>s/", function()
    builtin.live_grep({
      grep_open_files = true,
      prompt_title = "Live Grep in Open Files",
    })
  end, { desc = "[S]earch [/] in Open Files" })

  -- Shortcut for searching your Neovim configuration files
  vim.keymap.set("n", "<leader>sn", function()
    builtin.find_files({ cwd = vim.fn.stdpath("config"), follow = true })
  end, { desc = "[S]earch [N]eovim files" })
end

-- ============================================================
-- SECTION 6: LSP
-- LSP keymaps, server configuration, Mason tools installations
-- ============================================================
do
  -- [[ LSP Configuration ]]
  -- Brief aside: **What is LSP?**
  --
  -- LSP is an initialism you've probably heard, but might not understand what it is.
  --
  -- LSP stands for Language Server Protocol. It's a protocol that helps editors
  -- and language tooling communicate in a standardized fashion.
  --
  -- In general, you have a "server" which is some tool built to understand a particular
  -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
  -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
  -- processes that communicate with some "client" - in this case, Neovim!
  --
  -- LSP provides Neovim with features like:
  --  - Go to definition
  --  - Find references
  --  - Autocompletion
  --  - Symbol Search
  --  - and more!
  --
  -- Thus, Language Servers are external tools that must be installed separately from
  -- Neovim. This is where `mason` and related plugins come into play.
  --
  -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
  -- and elegantly composed help section, `:help lsp-vs-treesitter`

  -- Useful status updates for LSP.
  vim.pack.add({ gh("j-hui/fidget.nvim") })
  require("fidget").setup({})

  --  This function gets run when an LSP attaches to a particular buffer.
  --    That is to say, every time a new file is opened that is associated with
  --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
  --    function will be executed to configure the current buffer
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
    callback = function(event)
      -- NOTE: Remember that Lua is a real programming language, and as such it is possible
      -- to define small helper and utility functions so you don't have to repeat yourself.
      --
      -- In this case, we create a function that lets us more easily define mappings specific
      -- for LSP related items. It sets the mode, buffer and description for us each time.
      local map = function(keys, func, desc, mode)
        mode = mode or "n"
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
      end

      -- Rename the variable under your cursor.
      --  Most Language Servers support renaming across files, etc.
      map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

      -- Execute a code action, usually your cursor needs to be on top of an error
      -- or a suggestion from your LSP for this to activate.
      map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

      -- WARN: This is not Goto Definition, this is Goto Declaration.
      --  For example, in C this would take you to the header.
      map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

      -- The following two autocommands are used to highlight references of the
      -- word under your cursor when your cursor rests there for a little while.
      --    See `:help CursorHold` for information about when this is executed
      --
      -- When you move your cursor, the highlights will be cleared (the second autocommand).
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if
        client and client:supports_method("textDocument/documentHighlight", event.buf)
      then
        local highlight_augroup =
          vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd("LspDetach", {
          group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds({
              group = "kickstart-lsp-highlight",
              buffer = event2.buf,
            })
          end,
        })
      end

      -- The following code creates a keymap to toggle inlay hints in your
      -- code, if the language server you are using supports them
      --
      -- This may be unwanted, since they displace some of your code
      if client and client:supports_method("textDocument/inlayHint", event.buf) then
        map("<leader>th", function()
          vim.lsp.inlay_hint.enable(
            not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
          )
        end, "[T]oggle Inlay [H]ints")
      end
    end,
  })

  -- Enable the following language servers
  --  See `:help lsp-config` for information about keys and how to configure
  ---@type table<string, vim.lsp.Config>
  local servers = {
    ts_ls = {},
    pyright = {
      on_init = function(client)
        -- Point pyright at the project's venv automatically
        -- (set client.settings and notify, or pyright won't see it)
        local venv = vim.fs.root(client.config.root_dir, ".venv")
        local python = venv and (venv .. "/.venv/bin/python")
        if python and vim.uv.fs_stat(python) then
          client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
            python = { pythonPath = python },
          })
          client:notify("workspace/didChangeConfiguration", { settings = nil })
        end
      end,
    },
    ruff = {},
    -- Special Lua Config, as recommended by neovim help docs
    lua_ls = {
      on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if
            path ~= vim.fn.stdpath("config")
            and (
              vim.uv.fs_stat(path .. "/.luarc.json")
              or vim.uv.fs_stat(path .. "/.luarc.jsonc")
            )
          then
            return
          end
        end

        local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
        client.config.settings.Lua = vim.tbl_deep_extend("force", current_settings.Lua, {
          runtime = {
            version = "LuaJIT",
            path = { "lua/?.lua", "lua/?/init.lua" },
          },
          workspace = {
            checkThirdParty = false,
            -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
            --  See https://github.com/neovim/nvim-lspconfig/issues/3189
            library = vim.api.nvim_get_runtime_file("", true),
          },
        })
      end,
      ---@type lspconfig.settings.lua_ls
      settings = {
        Lua = {
          format = { enable = false }, -- Disable formatting (formatting is done by stylua)
        },
      },
    },
  }

  vim.pack.add({
    gh("neovim/nvim-lspconfig"),
    gh("mason-org/mason.nvim"),
    gh("mason-org/mason-lspconfig.nvim"),
    gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
  })

  -- Automatically install LSPs and related tools to stdpath for Neovim
  require("mason").setup({})

  -- Translates between nvim-lspconfig server names and mason.nvim package names (e.g. lua_ls <-> lua-language-server)
  require("mason-lspconfig").setup({
    automatic_enable = false, -- Change this to true if you want to automatically enable servers that are installed manually (e.g. via :Mason / :MasonInstall)
  })

  -- Ensure the servers and tools above are installed
  --
  -- To check the current status of installed tools and/or manually install
  -- other tools, you can run
  --    :Mason
  --
  -- You can press `g?` for help in this menu.
  local ensure_installed = vim.tbl_keys(servers or {})
  vim.list_extend(ensure_installed, {
    -- You can add other tools here that you want Mason to install
    "stylua", -- Used to format lua code
  })

  require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

  for name, server in pairs(servers) do
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
  end
end

-- ============================================================
-- SECTION 7: FORMATTING
-- conform.nvim setup and keymap
-- ============================================================
do
  -- [[ Formatting ]]
  vim.pack.add({ gh("stevearc/conform.nvim") })
  require("conform").setup({
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- You can specify filetypes to autoformat on save here:
      local enabled_filetypes = {
        -- lua = true,
        -- python = true,
      }
      if enabled_filetypes[vim.bo[bufnr].filetype] then
        return { timeout_ms = 500 }
      else
        return nil
      end
    end,
    default_format_opts = {
      lsp_format = "fallback", -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
    },
    -- You can also specify external formatters in here.
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format" },
      fish = { "fish_indent" },
      css = { "prettier" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
    },
    formatters = {
      -- Only format Lua where a `.stylua.toml` actually governs the file.
      -- Otherwise, StyLua falls back to its own defaults, and since this file
      -- is a symline to dotfiles, discvoery starts outside the repo and finds none.
      stylua = { require_cwd = true },
      -- Prefer the project's own ruff over Mason's (prevent version drift)
      ruff_format = {
        command = function(_, ctx)
          local venv = vim.fs.root(ctx.dirname, ".venv")
          local ruff = venv and (venv .. "/.venv/bin/ruff")
          return (ruff and vim.uv.fs_stat(ruff)) and ruff or "ruff"
        end,
      },
    },
  })

  vim.keymap.set({ "n", "v" }, "<leader>f", function()
    require("conform").format({ async = true })
  end, { desc = "[F]ormat buffer" })
end

-- ============================================================
-- SECTION 8: AUTOCOMPLETE & SNIPPETS
-- blink.cmp and luasnip setup
-- ============================================================
do
  -- [[ Snippet Engine ]]

  -- NOTE: You can also specify plugin using a version range for its git tag.
  --  See `:help vim.version.range()` for more info
  vim.pack.add({ { src = gh("L3MON4D3/LuaSnip"), version = vim.version.range("2.*") } })
  require("luasnip").setup({})

  -- `friendly-snippets` contains a variety of premade snippets.
  --    See the README about individual language/framework/plugin snippets:
  --    https://github.com/rafamadriz/friendly-snippets
  --
  -- vim.pack.add { gh 'rafamadriz/friendly-snippets' }
  -- require('luasnip.loaders.from_vscode').lazy_load()

  -- [[ Autocomplete Engine ]]
  vim.pack.add({ { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") } })
  require("blink.cmp").setup({
    keymap = {
      -- 'default' (recommended) for mappings similar to built-in completions
      --   <c-y> to accept ([y]es) the completion.
      --    This will auto-import if your LSP supports it.
      --    This will expand snippets if the LSP sent a snippet.
      -- 'super-tab' for tab to accept
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- For an understanding of why the 'default' preset is recommended,
      -- you will need to read `:help ins-completion`
      --
      -- No, but seriously. Please read `:help ins-completion`, it is really good!
      --
      -- All presets have the following mappings:
      -- <tab>/<s-tab>: move to right/left of your snippet expansion
      -- <c-space>: Open menu or open docs if already open
      -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
      -- <c-e>: Hide menu
      -- <c-k>: Toggle signature help
      --
      -- See `:help blink-cmp-config-keymap` for defining your own keymap
      preset = "default",

      -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
      --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = "mono",
    },

    completion = {
      -- By default, you may press `<c-space>` to show the documentation.
      -- Optionally, set `auto_show = true` to show the documentation after a delay.
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
    },

    sources = {
      default = { "lsp", "path", "snippets" },
    },

    snippets = { preset = "luasnip" },

    -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
    -- which automatically downloads a prebuilt binary when enabled.
    --
    -- By default, we use the Lua implementation instead, but you may enable
    -- the rust implementation via `'prefer_rust_with_warning'`
    --
    -- See `:help blink-cmp-config-fuzzy` for more information
    fuzzy = { implementation = "lua" },

    -- Shows a signature help window while you type arguments for a function
    signature = { enabled = true },
  })
end

-- ============================================================
-- SECTION 9: TREESITTER
-- Parser installation, syntax highlighting, folds, indentation
-- ============================================================
do
  -- [[ Configure Treesitter ]]
  --  Used to highlight, edit, and navigate code
  --
  --  See `:help nvim-treesitter-intro`

  -- NOTE: You can also specify a branch or a specific commit
  vim.pack.add({ { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" } })

  -- Ensure basic parsers are installed
  local parsers = {
    "bash",
    "c",
    "diff",
    "html",
    "lua",
    "luadoc",
    "markdown",
    "markdown_inline",
    "query",
    "vim",
    "vimdoc",
  }
  require("nvim-treesitter").install(parsers)

  ---@param buf integer
  ---@param language string
  local function treesitter_try_attach(buf, language)
    -- Check if a parser exists and load it
    if not vim.treesitter.language.add(language) then
      return
    end
    -- Enable syntax highlighting and other treesitter features
    vim.treesitter.start(buf, language)

    -- Enable treesitter based folds
    -- For more info on folds see `:help folds`
    -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    -- vim.wo.foldmethod = 'expr'

    -- Check if treesitter indentation is available for this language, and if so enable it
    -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
    local has_indent_query = vim.treesitter.query.get(language, "indents") ~= nil

    -- Enable treesitter based indentation
    if has_indent_query then
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end

  local available_parsers = require("nvim-treesitter").get_available()
  vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
      local buf, filetype = args.buf, args.match

      local language = vim.treesitter.language.get_lang(filetype)
      if not language then
        return
      end

      local installed_parsers = require("nvim-treesitter").get_installed("parsers")

      if vim.tbl_contains(installed_parsers, language) then
        -- Enable the parser if it is already installed
        treesitter_try_attach(buf, language)
      elseif vim.tbl_contains(available_parsers, language) then
        -- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
        require("nvim-treesitter").install(language):await(function()
          treesitter_try_attach(buf, language)
        end)
      else
        -- Try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
        treesitter_try_attach(buf, language)
      end
    end,
  })
end

-- ============================================================
-- SECTION 10: OPTIONAL EXAMPLES / NEXT STEPS
-- kickstart.plugins.* examples
-- ============================================================
do
  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug'
  -- require 'kickstart.plugins.indent_line'
  -- require 'kickstart.plugins.lint'
  -- require 'kickstart.plugins.autopairs'
  -- require 'kickstart.plugins.neo-tree'
  -- require 'kickstart.plugins.gitsigns' -- adds gitsigns recommended keymaps

  -- NOTE: You can add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  -- require 'custom.plugins'
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
