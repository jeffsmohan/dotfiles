-- Helpers
local function gh(repo)
  return "https://github.com/" .. repo
end

-- Whether `dir` itself configures a Python type checker (dir is the directory
-- containing the python venv).
---@param dir string
---@return boolean
local function configures_python_type_checker(dir)
  -- A Python project that configures its own type checker owns its types.
  -- (Otherwise, we'll fall back to pyright for type checking.)
  local python_type_checker_markers = {
    { file = "mypy.ini" },
    { file = ".mypy.ini" },
    { file = "ty.toml" },
    { file = "setup.cfg", patterns = { "^%[mypy%]" } },
    { file = "pyproject.toml", patterns = { "^%[tool%.mypy%]", "^%[tool%.ty%]" } },
  }
  for _, marker in ipairs(python_type_checker_markers) do
    local path = dir .. "/" .. marker.file
    if vim.uv.fs_stat(path) then
      if not marker.patterns then
        return true
      end
      for _, line in ipairs(vim.fn.readfile(path)) do
        for _, pattern in ipairs(marker.patterns) do
          if line:match(pattern) then
            return true
          end
        end
      end
    end
  end
  return false
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
  vim.o.laststatus = 3 -- one status line for the tab page, not one per window
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
  vim.o.splitright = true
  vim.o.splitbelow = true
  vim.o.winborder = "rounded"

  -- Cursor line only in the focused window (indicates active window)
  local cursorline_group =
    vim.api.nvim_create_augroup("cursorline-follows-focus", { clear = true })
  vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
    desc = "Show the cursor line in the focused window",
    group = cursorline_group,
    callback = function()
      vim.wo.cursorline = true
    end,
  })
  vim.api.nvim_create_autocmd("WinLeave", {
    desc = "Hide the cursor line in unfocused windows",
    group = cursorline_group,
    callback = function()
      vim.wo.cursorline = false
    end,
  })
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

  -- Up/down paging
  vim.keymap.set("n", "<C-u>", "<C-u>zz")
  vim.keymap.set("n", "<C-d>", "<C-d>zz")

  vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
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

  require("kanagawa").setup({
    overrides = function(colors)
      -- Custom coloring of status line segments
      local p = colors.palette
      local band = p.sumiInk5
      return {
        -- Make the window separation line read clearer
        WinSeparator = { fg = p.sumiInk6 },
        -- Status line segments
        StatusLineBase = { fg = p.oldWhite, bg = band },
        StatusLineDim = { fg = p.fujiGray, bg = band },
        StatusLineFile = { fg = p.fujiWhite, bg = band, bold = true },
        StatusLineBranch = { fg = p.springGreen, bg = band },
        StatusLineModified = { fg = p.roninYellow, bg = band },
        StatusLineReadonly = { fg = p.samuraiRed, bg = band },
        StatusLineAlert = { fg = p.samuraiRed, bg = band, bold = true },
        StatusLineNotice = { fg = p.surimiOrange, bg = band },
        StatusLineError = { fg = p.samuraiRed, bg = band, bold = true },
        StatusLineWarn = { fg = p.roninYellow, bg = band, bold = true },
        StatusLineInfo = { fg = p.dragonBlue, bg = band },
        StatusLineHint = { fg = p.waveAqua1, bg = band },
      }
    end,
  })

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

-- PLUGIN: gitlinker (shareable permalinks)
do
  vim.pack.add({ gh("linrongbin16/gitlinker.nvim") })
  require("gitlinker").setup({})

  vim.keymap.set({ "n", "v" }, "<leader>gl", "<cmd>GitLink<CR>", {
    desc = "[G]it [L]ink (copy)",
  })
  vim.keymap.set({ "n", "v" }, "<leader>gL", "<cmd>GitLink!<CR>", {
    desc = "[G]it [L]ink (open in browser)",
  })
end

-- PLUGIN: guess-indent (autodetect file indentation)
do
  vim.pack.add({ gh("NMAC427/guess-indent.nvim") })
  require("guess-indent").setup({})
end

-- PLUGIN: indent-blankline (visual bars for indent levels)
do
  vim.pack.add({ gh("lukas-reineke/indent-blankline.nvim") })
  require("ibl").setup({
    indent = {
      char = "▏",
    },
    scope = { enabled = false },
  })
end

-- PLUGIN: which-key (vim key binding reminders)
do
  vim.pack.add({ gh("folke/which-key.nvim") })
  require("which-key").setup({
    delay = 500,
    preset = "modern",
    icons = { mappings = true },
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
end

-- STATUS LINE: mini.statusline
do
  -- Custom status line:
  -- - Left half is ~identity (mode, branch, directory, file)
  -- - Right half is ~transient/warnings (diagnostics/errors, recording macro)
  -- - Prefer auto-hide segments where possible (only show when useful/alerting)

  local statusline = require("mini.statusline")
  local icons = {
    branch = "", -- oct-git_branch
    folder = "", -- fa-folder
    readonly = "", -- fa-lock
    modified = "●",
  }
  local diagnostic_signs = {
    ERROR = "%#StatusLineError#E",
    WARN = "%#StatusLineWarn#W",
    INFO = "%#StatusLineInfo#I",
    HINT = "%#StatusLineHint#H",
  }

  local function diagnostics()
    return vim.trim(
      statusline.section_diagnostics({ icon = "", signs = diagnostic_signs })
    )
  end

  local function section_path()
    if vim.bo.buftype == "terminal" then
      return "%t"
    end
    local name = vim.api.nvim_buf_get_name(0)
    if name == "" then
      return icons.folder .. " %#StatusLineFile#[No Name]"
    end

    local relative = vim.fn.fnamemodify(name, ":~:.") -- relative to git by default
    local dir = vim.fn.fnamemodify(relative, ":h")
    local file = vim.fn.fnamemodify(relative, ":t")

    local flags = {}
    if vim.bo.modified then
      table.insert(flags, "%#StatusLineModified#" .. icons.modified)
    end
    if vim.bo.readonly or not vim.bo.modifiable then
      table.insert(flags, "%#StatusLineReadonly#" .. icons.readonly)
    end

    return table.concat({
      icons.folder,
      " ",
      dir == "." and "" or dir .. "/",
      "%#StatusLineFile#",
      file,
      #flags > 0 and " " or "",
      table.concat(flags, " "),
    })
  end

  -- `q` is easy to hit by accident, and recording is otherwise silent
  local function section_macro()
    local register = vim.fn.reg_recording()
    return register == "" and "" or "REC @" .. register
  end

  -- Whether format-on-save is active is otherwise hard to tell
  local function section_autoformat()
    local disabled = vim.g.disable_autoformat or vim.b.disable_autoformat
    return disabled and "no-fmt" or ""
  end

  local function section_encoding()
    local parts = {}
    local encoding = vim.bo.fileencoding
    if encoding ~= "" and encoding ~= "utf-8" then
      table.insert(parts, encoding)
    end
    if vim.bo.fileformat ~= "unix" then
      table.insert(parts, "[" .. vim.bo.fileformat .. "]")
    end
    return table.concat(parts)
  end

  statusline.setup({
    use_icons = true,
    content = {
      -- No `inactive`: laststatus=3 means only the active content is ever drawn.
      active = function()
        local mode, mode_hl = statusline.section_mode({ trunc_width = 0 })
        return statusline.combine_groups({
          { hl = mode_hl, strings = { mode:upper() } },
          {
            hl = "StatusLineBranch",
            strings = { statusline.section_git({ icon = icons.branch }) },
          },
          -- Borrow gitsigns formatted hunks (vs mini's diff section, which renders "-"
          -- for no changes)
          { hl = "StatusLineDim", strings = { vim.b.gitsigns_status } },
          "%<", -- shorten the path before anything to its right
          { hl = "StatusLineDim", strings = { section_path() } },
          "%=",
          { hl = "StatusLineAlert", strings = { section_macro() } },
          {
            hl = "StatusLineNotice",
            strings = { section_autoformat(), section_encoding() },
          },
          { hl = "StatusLineBase", strings = { diagnostics() } },
          { hl = "StatusLineBase", strings = { statusline.section_searchcount({}) } },
          -- Short form: filetype and icon, without the encoding, line ending and
          -- size the long form adds
          {
            hl = "StatusLineBase",
            strings = { statusline.section_fileinfo({ trunc_width = math.huge }) },
          },
          { hl = "StatusLineBase", strings = { "%2l:%-2v" } },
        })
      end,
    },
  })
end

-- PLUGIN: nvim-tree (file explorer sidebar)
do
  -- nvim-tree wants netrw gone
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1

  vim.pack.add({ gh("nvim-tree/nvim-tree.lua") })
  require("nvim-tree").setup({
    -- Move the cursor to the current buffer's file whenever you switch.
    update_focused_file = { enable = true },
    modified = { enable = true },
    diagnostics = { enable = true },
    git = { enable = true },
    renderer = { highlight_git = "name", highlight_diagnostics = "name" },
  })

  vim.keymap.set(
    "n",
    "<leader>e",
    "<cmd>NvimTreeToggle<CR>",
    { desc = "File [E]xplorer" }
  )
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
    group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
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
          vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
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
          group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds({
              group = "lsp-highlight",
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
    tailwindcss = {
      -- By default, tailwind attaches on any filetype that can embed html/css,
      -- which is LOTS (think php, markdown, etc.) that I generally don't want
      filetypes = {
        "css",
        "html",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
      },
    },
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
        if not root then
          return
        end

        ---@type table<string, any>
        local python = {}

        local venv = vim.fs.root(root, ".venv")
        local interpreter = venv and (venv .. "/.venv/bin/python")
        if interpreter and vim.uv.fs_stat(interpreter) then
          python.pythonPath = interpreter
        end

        -- Where a type checker is configured, pyright does not handle types
        if configures_python_type_checker(root) then
          python.analysis = { typeCheckingMode = "off" }
        end

        if not vim.tbl_isempty(python) then
          client.settings =
            vim.tbl_deep_extend("force", client.settings or {}, { python = python })
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

-- TYPE CHECKING: mypy on save
do
  vim.pack.add({ gh("mfussenegger/nvim-lint") })
  local lint = require("lint")

  -- nvim-lint's built-in mypy linter parses the output and, because its pattern
  -- captures a `file` group, already drops diagnostics belonging to other files.
  -- mypy follows imports, so without that a break elsewhere would be reported
  -- against whatever line it fell on in this buffer.
  vim.api.nvim_create_autocmd("BufWritePost", {
    desc = "Type check with the project's own mypy",
    group = vim.api.nvim_create_augroup("mypy-on-save", { clear = true }),
    pattern = "*.py",
    callback = function(event)
      -- The root pyright picked for this buffer; reusing it keeps the two in agreement
      local client = vim.lsp.get_clients({ bufnr = event.buf, name = "pyright" })[1]
      local root = client and client.config.root_dir
      if not root or not configures_python_type_checker(root) then
        return
      end
      local mypy = root .. "/.venv/bin/mypy"
      if not vim.uv.fs_stat(mypy) then
        return
      end
      lint.linters.mypy.cmd = mypy
      lint.try_lint("mypy", { cwd = root })
    end,
  })
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

  -- Generally only want format-on-save when the formatter can auto-discover
  -- a proactively defined config. (Otherwise, multiple devs editing the same
  -- file in a repo might thrash on formatting.) The exceptions are formatters
  -- whose default is the whole convention: fish_indent has no config and no
  -- rival, ruff's defaults are black's.
  -- Manually triggered formatting is always available.
  local taplo_config = { ".taplo.toml", "taplo.toml" }
  local function find_stylua_config(_, ctx)
    local realpath = vim.uv.fs_realpath(ctx.filename) or ctx.filename
    return vim.fs.root(vim.fs.dirname(realpath), { ".stylua.toml", "stylua.toml" })
  end
  local find_prettier_config = require("conform.formatters.prettierd").cwd

  local config_required_on_save = {
    markdown = find_prettier_config,
    yaml = find_prettier_config,
    json = find_prettier_config,
    jsonc = find_prettier_config,
    lua = find_stylua_config,
    -- taplo reads neither .editorconfig nor any other shared convention
    toml = function(_, ctx)
      return vim.fs.root(ctx.dirname, taplo_config)
    end,
  }

  require("conform").setup({
    notify_on_error = false,

    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return nil
      end
      local find_config = config_required_on_save[vim.bo[bufnr].filetype]
      if find_config then
        local filename = vim.api.nvim_buf_get_name(bufnr)
        local ctx = { filename = filename, dirname = vim.fs.dirname(filename) }
        if not find_config(nil, ctx) then
          return nil
        end
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
      stylua = { cwd = find_stylua_config },
      taplo = {
        cwd = require("conform.util").root_file(taplo_config),
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
