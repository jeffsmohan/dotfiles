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
  vim.o.winborder = "rounded"
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

      -- Extra build step for compiling C for telescope fuzzy find
      if name == "telescope-fzf-native.nvim" then
        run_build(name, { "make" }, ev.data.path)
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

-- PLUGIN: fidget (bottom-right notifications display)
do
  vim.pack.add({ gh("j-hui/fidget.nvim") })
  require("fidget").setup({})
end

-- PLUGIN: Gitsigns (git status gutter, blame, etc.)
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

-- PLUGIN: guess-indent (autodetect file indentation)
do
  vim.pack.add({ gh("NMAC427/guess-indent.nvim") })
  require("guess-indent").setup({})
end

-- PLUGIN: which-key (vim key binding reminders)
do
  vim.pack.add({ gh("folke/which-key.nvim") })
  require("which-key").setup({
    delay = 500,
    preset = "modern",
    icons = { mappings = vim.g.have_nerd_font },
    spec = {
      { "<leader>s", group = "[S]earch", mode = { "n", "v" } },
      { "<leader>g", group = "[G]it" },
      { "<leader>t", group = "[T]oggle" },
      { "gr", group = "LSP Actions", mode = { "n" } },
    },
  })
end

-- PLUGIN: todo-comments (highlight special comments)
do
  vim.pack.add({ gh("folke/todo-comments.nvim") })
  require("todo-comments").setup({ signs = false })
  vim.keymap.set("n", "<leader>st", "<cmd>TodoTelescope<CR>", {
    desc = "[S]earch [T]odos",
  })
end

-- PLUGIN: mini.nvim modules (various little helpers)
do
  vim.pack.add({ gh("nvim-mini/mini.nvim") })

  require("mini.icons").setup()
  MiniIcons.mock_nvim_web_devicons()

  require("mini.surround").setup()
  require("mini.move").setup()
  require("mini.splitjoin").setup()
  require("mini.pairs").setup()

  require("mini.ai").setup({
    -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
    mappings = {
      around_next = "aa",
      inside_next = "ii",
    },
    n_lines = 500,
  })

  local statusline = require("mini.statusline")
  statusline.setup({ use_icons = true })
  ---@diagnostic disable-next-line: duplicate-set-field
  statusline.section_location = function()
    return "%2l:%-2v"
  end
end

-- PLUGIN: telescope (search/fuzzy find)
do
  vim.pack.add({
    gh("nvim-lua/plenary.nvim"),
    gh("nvim-telescope/telescope.nvim"),
    gh("nvim-telescope/telescope-ui-select.nvim"),
    gh("nvim-telescope/telescope-fzf-native.nvim"),
  })

  require("telescope").setup({
    defaults = {
      sorting_strategy = "ascending",
      layout_config = { prompt_position = "top" },
      path_display = { "truncate" },
    },
    extensions = {
      ["ui-select"] = { require("telescope.themes").get_dropdown() },
    },
  })

  require("telescope").load_extension("fzf")
  require("telescope").load_extension("ui-select")

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
  vim.keymap.set(
    "n",
    "<leader>/",
    builtin.current_buffer_fuzzy_find,
    { desc = "[/] Fuzzily search in current buffer" }
  )
  vim.keymap.set("n", "<leader>s/", function()
    builtin.live_grep({
      grep_open_files = true,
      prompt_title = "Live Grep in Open Files",
    })
  end, { desc = "[S]earch [/] in Open Files" })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
    callback = function(event)
      local buf = event.buf

      vim.keymap.set(
        "n",
        "grr",
        builtin.lsp_references,
        { buffer = buf, desc = "[G]oto [R]eferences" }
      )
      vim.keymap.set(
        "n",
        "gri",
        builtin.lsp_implementations,
        { buffer = buf, desc = "[G]oto [I]mplementation" }
      )
      vim.keymap.set(
        "n",
        "grd",
        builtin.lsp_definitions,
        { buffer = buf, desc = "[G]oto [D]definition" }
      )
      vim.keymap.set(
        "n",
        "gO",
        builtin.lsp_document_symbols,
        { buffer = buf, desc = "Open Document Symbols" }
      )
      vim.keymap.set(
        "n",
        "gW",
        builtin.lsp_dynamic_workspace_symbols,
        { buffer = buf, desc = "Open Workspace Symbols" }
      )
      vim.keymap.set(
        "n",
        "grt",
        builtin.lsp_type_definitions,
        { buffer = buf, desc = "[G]oto [T]type Definition" }
      )
    end,
  })
end

-- MASON: package registry for language servers and tools
do
  vim.pack.add({ gh("mason-org/mason.nvim") })
  require("mason").setup({})
end

-- LSP configuration
do
  -- Turn LSP keymaps/features on/off when attaching
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
    callback = function(event)
      local map = function(keys, func, desc, mode)
        mode = mode or "n"
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
      end

      map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
      map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
      map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

      -- Highlighting when you leave your cursor on a reference
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

      -- "Inlay" hints (e.g. ghost argument names)
      if client and client:supports_method("textDocument/inlayHint", event.buf) then
        map("<leader>th", function()
          vim.lsp.inlay_hint.enable(
            not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
          )
        end, "[T]oggle Inlay [H]ints")
      end
    end,
  })

  -- Enabled LSPs
  ---@type table<string, vim.lsp.Config>
  local servers = {
    -- Web/TypeScript
    vtsls = {},
    eslint = {},
    tailwindcss = {},
    cssls = {},

    -- Config and markup
    jsonls = {},
    yamlls = {},
    taplo = {},
    marksman = {},

    -- Shell and containers
    bashls = {},
    dockerls = {},

    -- Python
    pyright = {
      on_init = function(client)
        -- root_dir is nil for a standalone file opened outside any project,
        -- and vim.fs.root throws rather than returning nil on a nil argument.
        local root = client.config.root_dir
        local venv = root and vim.fs.root(root, ".venv")
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

    -- Lua
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
    gh("mason-org/mason-lspconfig.nvim"),
  })

  -- Installs the servers above, translating between nvim-lspconfig names and
  -- mason.nvim package names (e.g. lua_ls <-> lua-language-server)
  require("mason-lspconfig").setup({
    ensure_installed = vim.tbl_keys(servers or {}),
    automatic_enable = false, -- each server is enabled explicitly below
  })

  for name, server in pairs(servers) do
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
  end
end

-- FORMATTING: conform.nvim
do
  vim.pack.add({
    gh("stevearc/conform.nvim"),
    gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
  })

  -- Global fallbacks for the formatters below. Where a repo vendors its own
  -- (prettier in node_modules, ruff in .venv) conform prefers that one
  require("mason-tool-installer").setup({
    ensure_installed = {
      "stylua", -- lua
      "prettier", -- web, json, yaml, markdown
      "shfmt", -- sh, bash
    },
  })

  require("conform").setup({
    notify_on_error = false,

    -- Format on save everywhere. The formatters below use the
    -- project's own CLI tools, so each one discovers the repo's config on its
    -- own (.stylua.toml, [tool.ruff], .prettierrc, .editorconfig). Where a repo
    -- has no opinion, we format using the tool's defaults.
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return nil
      end
      return { timeout_ms = 1000 }
    end,
    default_format_opts = {
      lsp_format = "fallback", -- Use external formatters if configured below, otherwise use LSP formatting
    },
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_organize_imports", "ruff_format" },
      fish = { "fish_indent" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      toml = { "taplo" },
      css = { "prettier" },
      scss = { "prettier" },
      less = { "prettier" },
      html = { "prettier" },
      graphql = { "prettier" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
    },
    formatters = {
      -- StyLua looks for `.stylua.toml` upward from the buffer's directory, but
      -- this file is reached through a stow symlink, so that search starts in
      -- ~/.config/nvim and never reaches the dotfiles repo. Resolve the symlink
      -- first so the repo's config wins. Elsewhere this returns nil and StyLua
      -- runs with its own defaults, which is the behaviour we want.
      stylua = {
        cwd = function(_, ctx)
          local realpath = vim.uv.fs_realpath(ctx.filename) or ctx.filename
          return vim.fs.root(vim.fs.dirname(realpath), { ".stylua.toml", "stylua.toml" })
        end,
      },
      -- Prefer the project's own ruff over Mason's
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

  vim.api.nvim_create_user_command("FormatDisable", function(args)
    if args.bang then
      vim.b.disable_autoformat = true -- `:FormatDisable!` -- this buffer only
    else
      vim.g.disable_autoformat = true
    end
  end, { desc = "Disable format-on-save (! for current buffer)", bang = true })

  vim.api.nvim_create_user_command("FormatEnable", function()
    vim.b.disable_autoformat = false
    vim.g.disable_autoformat = false
  end, { desc = "Re-enable format-on-save" })
end

-- PLUGIN: blink.cmp (autocompletion)
do
  vim.pack.add({ { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") } })
  require("blink.cmp").setup({
    -- I don't like traditional snippets (like auto-expanding entire functions)
    -- but built-in vim.snippet provides basics (parens when autocompleting a function name
    snippets = { preset = "default" },
    sources = { default = { "lsp", "path" } },
    appearance = { nerd_font_variant = "mono" },

    completion = {
      list = {
        selection = { preselect = true, auto_insert = true },
      },
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
    },
    fuzzy = { implementation = "lua" },
    signature = { enabled = true },

    keymap = {
      preset = "none",

      -- Next/previous primarily with arrows
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
      ["<C-n>"] = { "select_next", "fallback_to_mappings" },

      -- Select primarily with Tab
      ["<Tab>"] = { "select_and_accept", "fallback" },
      ["<C-y>"] = { "select_and_accept", "fallback" },
      ["<C-e>"] = { "cancel", "fallback" },

      -- Extras like signature/documentation
      ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    },
  })
end

-- PLUGIN: treesitter (syntax highlighting, etc.)
do
  vim.pack.add({ { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" } })

  -- Default parsers installed on a fresh nvim setup
  -- (auto-installs others anytime new filetype is opened)
  local parsers = {
    -- injection-only parsers (would never auto-install)
    "comment",
    "jsdoc",
    "luadoc",
    "regex",
    "markdown_inline",
    "printf",

    -- my typical parsers worth always installing
    "bash",
    "css",
    "csv",
    "diff",
    "fish",
    "html",
    "javascript",
    "json",
    "lua",
    "markdown",
    "python",
    "toml",
    "typescript",
    "yaml",
  }
  require("nvim-treesitter").install(parsers)

  ---@param buf integer
  ---@param language string
  local function treesitter_try_attach(buf, language)
    if not vim.treesitter.language.add(language) then
      return
    end
    vim.treesitter.start(buf, language)

    local has_indent_query = vim.treesitter.query.get(language, "indents") ~= nil
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

      -- Attach parser if installed; try auto-install if available for language
      if vim.tbl_contains(installed_parsers, language) then
        treesitter_try_attach(buf, language)
      elseif vim.tbl_contains(available_parsers, language) then
        require("nvim-treesitter").install(language):await(function()
          treesitter_try_attach(buf, language)
        end)
      else
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
