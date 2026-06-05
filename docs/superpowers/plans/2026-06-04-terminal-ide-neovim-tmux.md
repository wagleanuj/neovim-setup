# Terminal IDE (LazyVim + tmux + Claude Code) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a version-controlled terminal IDE — LazyVim base + custom plugin deltas, a tmux config, and a smart `dev` launcher — installed via symlinks, with in-editor AI through CodeCompanion's Claude Code (ACP) adapter and a Claude Code agent pane.

**Architecture:** A git repo at `~/Documents/Projects/neovim-setup` holds `nvim/`, `tmux/.tmux.conf`, and `bin/dev`. `install.sh` symlinks them into `~/.config/nvim`, `~/.tmux.conf`, `~/.local/bin/dev`. LazyVim owns the Neovim core; each `nvim/lua/plugins/*.lua` is a small, single-purpose spec layered on top. AI in-editor routes through the `claude_code` ACP adapter (subscription auth, no API key).

**Tech Stack:** Neovim 0.11.4 + lazy.nvim/LazyVim, tmux 3.5a + tpm, bash, Mason (LSP/DAP/formatter installer), CodeCompanion.nvim, Claude Code CLI.

**Conventions for every task below:**
- Repo root is `~/Documents/Projects/neovim-setup`. All `git` commands run there.
- The headless Neovim checks must run against the symlinked config, so **Task 2 installs the symlinks first**; later tasks add plugin files that the symlink already points at.
- Commit messages omit the Co-Authored-By trailer here for brevity; add it per repo convention when committing.

---

### Task 1: Repo scaffolding and README

**Files:**
- Create: `README.md`
- Create: `.gitignore` (already exists from spec commit — verify contents)
- Create: `nvim/.keep`, `tmux/.keep`, `bin/.keep` (placeholder dirs)

- [ ] **Step 1: Create directory structure**

Run:
```bash
cd ~/Documents/Projects/neovim-setup
mkdir -p nvim/lua/config nvim/lua/plugins tmux bin
```

- [ ] **Step 2: Verify .gitignore contents**

Run: `cat .gitignore`
Expected output:
```
*.bak
*.bak.*
.DS_Store
```
If different, write exactly those three lines.

- [ ] **Step 3: Write README.md**

`README.md`:
```markdown
# neovim-setup — Terminal IDE

LazyVim + tmux + Claude Code. Version-controlled dotfiles, installed via symlinks.

## Install

\`\`\`bash
git clone <this-repo> ~/Documents/Projects/neovim-setup
cd ~/Documents/Projects/neovim-setup
./install.sh
\`\`\`

Then:
1. Open `nvim` once — Mason auto-installs LSPs/formatters/debuggers.
2. Run `claude setup-token` so in-editor AI (CodeCompanion) can use your Claude subscription.
3. In tmux, press `C-a I` to install tmux plugins.
4. From any project: run `dev`.

## Requirements

- Neovim ≥ 0.10, tmux ≥ 3.4
- A Nerd Font set in your terminal (for icons)
- Claude Code CLI (for AI)

## Layout

| Path | Symlinked to | Purpose |
|------|--------------|---------|
| `nvim/` | `~/.config/nvim` | LazyVim + plugin deltas |
| `tmux/.tmux.conf` | `~/.tmux.conf` | tmux config |
| `bin/dev` | `~/.local/bin/dev` | smart project launcher |

See `docs/superpowers/specs/` for the design.
```

- [ ] **Step 4: Commit**

Run:
```bash
cd ~/Documents/Projects/neovim-setup
git add README.md .gitignore nvim tmux bin
git commit -m "chore: scaffold repo structure and README"
```
Expected: commit succeeds (the `.keep`-less dirs are tracked once they contain files in later tasks; if git complains about empty dirs, add `touch nvim/.keep tmux/.keep bin/.keep` and re-add).

---

### Task 2: install.sh (dependency check + symlinks)

**Files:**
- Create: `install.sh`

This task creates the installer and runs it so the symlinks exist for all later verification. LazyVim files don't exist yet, so the symlink target `nvim/` will be populated in Task 3 — that's fine, the symlink points at the directory.

- [ ] **Step 1: Write install.sh**

`install.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CFG="$HOME/.config/nvim"
TMUX_CFG="$HOME/.tmux.conf"
DEV_BIN="$HOME/.local/bin/dev"
TPM_DIR="$HOME/.tmux/plugins/tpm"

info()  { printf '\033[0;36m==>\033[0m %s\n' "$1"; }
warn()  { printf '\033[0;33m!!\033[0m %s\n'  "$1"; }
ok()    { printf '\033[0;32mok\033[0m %s\n'  "$1"; }

# --- dependency checks ---
command -v nvim >/dev/null || { warn "Neovim not found"; exit 1; }
command -v tmux >/dev/null || { warn "tmux not found"; exit 1; }
command -v git  >/dev/null || { warn "git not found";  exit 1; }

for tool in lazygit fd; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1; then
      info "Installing $tool via brew"
      brew install "$tool"
    else
      warn "$tool missing and brew not available — install it manually"
    fi
  fi
done

# --- backup helper: never clobber a real (non-symlink) file ---
backup() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    local n=0; local dest="$target.bak"
    while [ -e "$dest" ]; do n=$((n+1)); dest="$target.bak.$n"; done
    warn "Backing up $target -> $dest"
    mv "$target" "$dest"
  elif [ -L "$target" ]; then
    rm -f "$target"
  fi
}

link() {
  local src="$1" dest="$2"
  backup "$dest"
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  ok "linked $dest -> $src"
}

link "$REPO/nvim"            "$NVIM_CFG"
link "$REPO/tmux/.tmux.conf" "$TMUX_CFG"
link "$REPO/bin/dev"         "$DEV_BIN"
chmod +x "$REPO/bin/dev" 2>/dev/null || true

# --- tpm ---
if [ ! -d "$TPM_DIR" ]; then
  info "Cloning tpm"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  ok "tpm already installed"
fi

cat <<'NEXT'

Next steps:
  1. Open `nvim` once — Mason will install LSPs/formatters/debuggers.
  2. Run `claude setup-token` so CodeCompanion can use your Claude subscription.
  3. In tmux, press  C-a  then  I  to install tmux plugins.
  4. Ensure your terminal uses a Nerd Font (for icons).
  5. From any project directory, run:  dev
NEXT
```

- [ ] **Step 2: Make executable and run it**

Run:
```bash
cd ~/Documents/Projects/neovim-setup
chmod +x install.sh
./install.sh
```
Expected: installs `lazygit`/`fd` if missing, prints `ok linked ...` for the three symlinks, clones tpm, prints the "Next steps" block. No errors.

- [ ] **Step 3: Verify symlinks exist and point at the repo**

Run:
```bash
ls -l ~/.config/nvim ~/.tmux.conf ~/.local/bin/dev | grep -- '->'
```
Expected: three lines, each `... -> /Users/anujwagle/Documents/Projects/neovim-setup/...`.

- [ ] **Step 4: Commit**

Run:
```bash
cd ~/Documents/Projects/neovim-setup
git add install.sh
git commit -m "feat: add install.sh with dep checks and symlinks"
```

---

### Task 3: LazyVim bootstrap (init.lua + config)

**Files:**
- Create: `nvim/init.lua`
- Create: `nvim/lua/config/lazy.lua`
- Create: `nvim/lua/config/options.lua`
- Create: `nvim/lua/config/keymaps.lua`
- Create: `nvim/lua/config/autocmds.lua`
- Create: `nvim/lua/plugins/colorscheme.lua`

- [ ] **Step 1: Write nvim/init.lua**

`nvim/init.lua`:
```lua
-- bootstrap lazy.nvim + LazyVim, then load config and plugin specs
require("config.lazy")
```

- [ ] **Step 2: Write nvim/lua/config/lazy.lua**

`nvim/lua/config/lazy.lua`:
```lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" } }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- LazyVim core
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- our plugin deltas
    { import = "plugins" },
  },
  defaults = { lazy = false, version = false },
  checker = { enabled = true, notify = false },
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
    },
  },
})
```

- [ ] **Step 3: Write nvim/lua/config/options.lua**

`nvim/lua/config/options.lua`:
```lua
-- LazyVim loads this automatically. mapleader must be set before lazy (LazyVim sets it),
-- but we keep explicit values for clarity.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt
opt.relativenumber = true
opt.number = true
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.wrap = false
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.termguicolors = true
```

- [ ] **Step 4: Write nvim/lua/config/keymaps.lua**

`nvim/lua/config/keymaps.lua`:
```lua
-- LazyVim loads this automatically (in addition to its own keymaps).
-- Only bind keys LazyVim leaves free. Plugin-specific keys live in their plugin specs.
local map = vim.keymap.set

-- quick window nav (complements tmux h/j/k/l)
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
```

- [ ] **Step 5: Write nvim/lua/config/autocmds.lua**

`nvim/lua/config/autocmds.lua`:
```lua
-- LazyVim loads this automatically. Keep custom autocmds here.
local aug = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = aug,
  callback = function() vim.highlight.on_yank({ timeout = 150 }) end,
})
```

- [ ] **Step 6: Write nvim/lua/plugins/colorscheme.lua**

`nvim/lua/plugins/colorscheme.lua`:
```lua
return {
  { "folke/tokyonight.nvim", opts = { style = "night" } },
  { "LazyVim/LazyVim", opts = { colorscheme = "tokyonight" } },
}
```

- [ ] **Step 7: Sync plugins headlessly and verify they resolve**

Run:
```bash
nvim --headless "+Lazy! sync" +qa 2>&1 | tail -20
```
Expected: lazy.nvim clones LazyVim and dependencies; ends without `ERROR`. First run may take 1–2 minutes. If it hangs on input, the spec import path is wrong — re-check `import = "plugins"`.

- [ ] **Step 8: Run checkhealth and confirm no fatal lazy errors**

Run:
```bash
nvim --headless "+checkhealth lazy" +qa 2>&1 | tail -20
```
Expected: no `ERROR` lines for lazy. Warnings (e.g. optional deps) are acceptable.

- [ ] **Step 9: Commit**

Run:
```bash
cd ~/Documents/Projects/neovim-setup
git add nvim/init.lua nvim/lua/config nvim/lua/plugins/colorscheme.lua nvim/lazy-lock.json
git commit -m "feat: bootstrap LazyVim with base config and tokyonight"
```

---

### Task 4: Editor UX plugins (oil, snacks, telescope, trouble, which-key)

**Files:**
- Create: `nvim/lua/plugins/editor.lua`

Note: LazyVim already ships snacks, telescope, trouble, which-key. This file tunes them and adds oil.nvim.

- [ ] **Step 1: Write nvim/lua/plugins/editor.lua**

`nvim/lua/plugins/editor.lua`:
```lua
return {
  -- oil: edit the filesystem like a buffer
  {
    "stevearc/oil.nvim",
    opts = {
      default_file_explorer = true,
      view_options = { show_hidden = true },
      keymaps = { ["q"] = "actions.close" },
    },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent dir (oil)" },
    },
    lazy = false,
  },

  -- trouble: diagnostics / references list
  {
    "folke/trouble.nvim",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
      { "<leader>xr", "<cmd>Trouble lsp_references toggle<cr>", desc = "LSP References" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
    },
  },
}
```

- [ ] **Step 2: Verify the spec loads (headless)**

Run:
```bash
nvim --headless "+Lazy! sync" "+lua print('oil:', pcall(require,'oil'))" +qa 2>&1 | tail -10
```
Expected: a line containing `oil: true`. No `ERROR`.

- [ ] **Step 3: Commit**

Run:
```bash
cd ~/Documents/Projects/neovim-setup
git add nvim/lua/plugins/editor.lua nvim/lazy-lock.json
git commit -m "feat: add oil + trouble editor UX tuning"
```

---

### Task 5: LSP servers for the polyglot stack

**Files:**
- Create: `nvim/lua/plugins/lsp.lua`

- [ ] **Step 1: Write nvim/lua/plugins/lsp.lua**

`nvim/lua/plugins/lsp.lua`:
```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {},
        vue_ls = {},
        pyright = {},
        gopls = {},
        rust_analyzer = {},
        tailwindcss = {},
        prismals = {},
        graphql = {},
        dockerls = {},
        yamlls = {},
        jsonls = {},
        lua_ls = {},
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- formatters / linters (LSP servers are handled by mason-lspconfig)
        "prettier", "eslint_d", "stylua", "ruff", "black",
      },
    },
  },
}
```

Note: LazyVim's language "extras" (e.g. `lazyvim.plugins.extras.lang.typescript`) also enable these — this file declares them directly so the setup is explicit and self-contained.

- [ ] **Step 2: Headless sync and confirm lspconfig loads**

Run:
```bash
nvim --headless "+Lazy! sync" "+lua print('lspconfig:', pcall(require,'lspconfig'))" +qa 2>&1 | tail -10
```
Expected: `lspconfig: true`, no `ERROR`. (Mason downloads happen lazily / on first real edit; this only checks the spec resolves.)

- [ ] **Step 3: Commit**

Run:
```bash
cd ~/Documents/Projects/neovim-setup
git add nvim/lua/plugins/lsp.lua nvim/lazy-lock.json
git commit -m "feat: declare LSP servers for ts/vue/py/go/rust/web"
```

---

### Task 6: Formatting (conform.nvim, format-on-save)

**Files:**
- Create: `nvim/lua/plugins/formatting.lua`

- [ ] **Step 1: Write nvim/lua/plugins/formatting.lua**

`nvim/lua/plugins/formatting.lua`:
```lua
return {
  {
    "stevearc/conform.nvim",
    opts = {
      format_on_save = { timeout_ms = 2000, lsp_format = "fallback" },
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        python = { "ruff_format", "black" },
        go = { "gofmt" },
        rust = { "rustfmt" },
        lua = { "stylua" },
      },
    },
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
  },
}
```

- [ ] **Step 2: Headless sync and confirm conform loads**

Run:
```bash
nvim --headless "+Lazy! sync" "+lua print('conform:', pcall(require,'conform'))" +qa 2>&1 | tail -10
```
Expected: `conform: true`, no `ERROR`.

- [ ] **Step 3: Commit**

Run:
```bash
cd ~/Documents/Projects/neovim-setup
git add nvim/lua/plugins/formatting.lua nvim/lazy-lock.json
git commit -m "feat: conform format-on-save for the polyglot stack"
```

---

### Task 7: Git integration (neogit, diffview, git-conflict, octo)

**Files:**
- Create: `nvim/lua/plugins/git.lua`

LazyVim ships gitsigns; this adds the rest.

- [ ] **Step 1: Write nvim/lua/plugins/git.lua**

`nvim/lua/plugins/git.lua`:
```lua
return {
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    cmd = "Neogit",
    opts = {},
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit status" },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff view" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    },
  },
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>gc", "<cmd>GitConflictListQf<cr>", desc = "Git conflicts" },
    },
  },
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
    keys = {
      { "<leader>gi", "<cmd>Octo issue list<cr>", desc = "GitHub issues" },
      { "<leader>gp", "<cmd>Octo pr list<cr>", desc = "GitHub PRs" },
    },
  },
}
```

- [ ] **Step 2: Headless sync and confirm specs resolve**

Run:
```bash
nvim --headless "+Lazy! sync" "+lua print('neogit:', pcall(require,'neogit'))" +qa 2>&1 | tail -10
```
Expected: `neogit: true`, no `ERROR`. (octo requires `gh` auth at use time, not load time.)

- [ ] **Step 3: Commit**

Run:
```bash
cd ~/Documents/Projects/neovim-setup
git add nvim/lua/plugins/git.lua nvim/lazy-lock.json
git commit -m "feat: neogit + diffview + git-conflict + octo"
```

---

### Task 8: Debugging (nvim-dap + ui for JS/TS, Python, Go, Rust)

**Files:**
- Create: `nvim/lua/plugins/dap.lua`

- [ ] **Step 1: Write nvim/lua/plugins/dap.lua**

`nvim/lua/plugins/dap.lua`:
```lua
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      "theHamsta/nvim-dap-virtual-text",
      "jay-babu/mason-nvim-dap.nvim",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      require("nvim-dap-virtual-text").setup()
      require("mason-nvim-dap").setup({
        ensure_installed = { "js", "python", "delve", "codelldb" },
        automatic_installation = true,
        handlers = {},
      })
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
    end,
  },
}
```

- [ ] **Step 2: Headless sync and confirm dap loads**

Run:
```bash
nvim --headless "+Lazy! sync" "+lua print('dap:', pcall(require,'dap'))" +qa 2>&1 | tail -10
```
Expected: `dap: true`, no `ERROR`.

- [ ] **Step 3: Commit**

Run:
```bash
cd ~/Documents/Projects/neovim-setup
git add nvim/lua/plugins/dap.lua nvim/lazy-lock.json
git commit -m "feat: nvim-dap with ui + adapters for js/py/go/rust"
```

---

### Task 9: Testing (neotest + adapters)

**Files:**
- Create: `nvim/lua/plugins/testing.lua`

- [ ] **Step 1: Write nvim/lua/plugins/testing.lua**

`nvim/lua/plugins/testing.lua`:
```lua
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/nvim-nio",
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-go",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-jest"),
          require("neotest-vitest"),
          require("neotest-python"),
          require("neotest-go"),
        },
      })
    end,
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file tests" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Test output" },
    },
  },
}
```

- [ ] **Step 2: Headless sync and confirm neotest loads**

Run:
```bash
nvim --headless "+Lazy! sync" "+lua print('neotest:', pcall(require,'neotest'))" +qa 2>&1 | tail -10
```
Expected: `neotest: true`, no `ERROR`.

- [ ] **Step 3: Commit**

Run:
```bash
cd ~/Documents/Projects/neovim-setup
git add nvim/lua/plugins/testing.lua nvim/lazy-lock.json
git commit -m "feat: neotest with jest/vitest/python/go adapters"
```

---

### Task 10: Database UI (vim-dadbod)

**Files:**
- Create: `nvim/lua/plugins/database.lua`

- [ ] **Step 1: Write nvim/lua/plugins/database.lua**

`nvim/lua/plugins/database.lua`:
```lua
return {
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
    end,
    keys = {
      { "<leader>Du", "<cmd>DBUIToggle<cr>", desc = "Database UI" },
    },
  },
}
```

- [ ] **Step 2: Headless sync and confirm spec resolves**

Run:
```bash
nvim --headless "+Lazy! sync" "+lua print('dadbod-ui spec ok')" +qa 2>&1 | tail -10
```
Expected: `dadbod-ui spec ok`, no `ERROR`. (dadbod-ui is a vimscript plugin loaded on `:DBUI`; there is no `require` module, so we only assert the sync succeeds.)

- [ ] **Step 3: Commit**

Run:
```bash
cd ~/Documents/Projects/neovim-setup
git add nvim/lua/plugins/database.lua nvim/lazy-lock.json
git commit -m "feat: vim-dadbod database UI"
```

---

### Task 11: REST client (kulala.nvim)

**Files:**
- Create: `nvim/lua/plugins/rest.lua`

- [ ] **Step 1: Write nvim/lua/plugins/rest.lua**

`nvim/lua/plugins/rest.lua`:
```lua
return {
  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    opts = {},
    keys = {
      { "<leader>rs", function() require("kulala").run() end, ft = "http", desc = "Run request" },
      { "<leader>ra", function() require("kulala").run_all() end, ft = "http", desc = "Run all requests" },
      { "<leader>rp", function() require("kulala").jump_prev() end, ft = "http", desc = "Prev request" },
      { "<leader>rn", function() require("kulala").jump_next() end, ft = "http", desc = "Next request" },
    },
  },
}
```

- [ ] **Step 2: Headless sync and confirm kulala loads**

Run:
```bash
nvim --headless "+Lazy! sync" "+lua print('kulala:', pcall(require,'kulala'))" +qa 2>&1 | tail -10
```
Expected: `kulala: true`, no `ERROR`.

- [ ] **Step 3: Commit**

Run:
```bash
cd ~/Documents/Projects/neovim-setup
git add nvim/lua/plugins/rest.lua nvim/lazy-lock.json
git commit -m "feat: kulala.nvim .http REST client"
```

---

### Task 12: Markdown + Mermaid

**Files:**
- Create: `nvim/lua/plugins/markdown.lua`

- [ ] **Step 1: Write nvim/lua/plugins/markdown.lua**

`nvim/lua/plugins/markdown.lua`:
```lua
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    opts = {},
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown preview" },
    },
  },
}
```

Note: render-markdown renders Mermaid code blocks inline-styled; the browser preview (markdown-preview) renders Mermaid diagrams visually.

- [ ] **Step 2: Headless sync and confirm render-markdown loads**

Run:
```bash
nvim --headless "+Lazy! sync" "+lua print('render-markdown:', pcall(require,'render-markdown'))" +qa 2>&1 | tail -10
```
Expected: `render-markdown: true`, no `ERROR`.

- [ ] **Step 3: Commit**

Run:
```bash
cd ~/Documents/Projects/neovim-setup
git add nvim/lua/plugins/markdown.lua nvim/lazy-lock.json
git commit -m "feat: render-markdown + markdown browser preview"
```

---

### Task 13: AI — CodeCompanion via Claude Code (ACP)

**Files:**
- Create: `nvim/lua/plugins/ai.lua`

- [ ] **Step 1: Write nvim/lua/plugins/ai.lua**

`nvim/lua/plugins/ai.lua`:
```lua
return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    opts = {
      -- route in-editor AI through the Claude Code CLI (ACP) -> uses your
      -- Claude subscription via CLAUDE_CODE_OAUTH_TOKEN. No metered API key.
      strategies = {
        chat = { adapter = "claude_code" },
        inline = { adapter = "claude_code" },
      },
      adapters = {
        acp = {
          claude_code = function()
            return require("codecompanion.adapters").extend("claude_code", {
              env = {
                -- generated once via:  claude setup-token
                CLAUDE_CODE_OAUTH_TOKEN = "cmd:echo $CLAUDE_CODE_OAUTH_TOKEN",
              },
            })
          end,
        },
      },
    },
    keys = {
      { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI chat toggle" },
      { "<leader>ac", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI actions" },
      { "<leader>ae", "<cmd>CodeCompanion /explain<cr>", mode = "v", desc = "AI explain selection" },
      { "<leader>ar", "<cmd>CodeCompanion /refactor<cr>", mode = "v", desc = "AI refactor selection" },
    },
  },
}
```

Note on auth: CodeCompanion's `claude_code` adapter reads `CLAUDE_CODE_OAUTH_TOKEN`. The `cmd:` prefix tells CodeCompanion to resolve the value by running the shell command at request time, so the token stays in your environment, never in the repo. The token is generated once by `claude setup-token`; export it in your shell profile (documented in Task 15).

- [ ] **Step 2: Headless sync and confirm codecompanion loads**

Run:
```bash
nvim --headless "+Lazy! sync" "+lua print('codecompanion:', pcall(require,'codecompanion'))" +qa 2>&1 | tail -10
```
Expected: `codecompanion: true`, no `ERROR`. (No AI call is made here; auth is only needed when you actually chat.)

- [ ] **Step 3: Commit**

Run:
```bash
cd ~/Documents/Projects/neovim-setup
git add nvim/lua/plugins/ai.lua nvim/lazy-lock.json
git commit -m "feat: CodeCompanion via claude_code ACP adapter (no API key)"
```

---

### Task 14: tmux config

**Files:**
- Create: `tmux/.tmux.conf`

- [ ] **Step 1: Write tmux/.tmux.conf**

`tmux/.tmux.conf`:
```tmux
# --- general ---
set -g mouse on
set -g history-limit 50000
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g status-position top
set -g escape-time 10
set -g focus-events on
set -ga terminal-overrides ",xterm-256color:Tc"

# --- prefix: C-a ---
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# reload
bind r source-file ~/.tmux.conf \; display-message "tmux reloaded"

# --- splits (open in cwd) ---
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# --- vim-style pane nav ---
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# --- resize ---
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# --- plugins (tpm) ---
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

set -g @continuum-restore 'on'
set -g @resurrect-capture-pane-contents 'on'

run '~/.tmux/plugins/tpm/tpm'
```

- [ ] **Step 2: Verify the config parses**

Run:
```bash
tmux -f tmux/.tmux.conf new-session -d -s smoke 2>&1 && tmux kill-session -t smoke && echo "PARSE_OK"
```
Expected: prints `PARSE_OK` with no error lines above it. (tpm's `run` line is harmless if tpm isn't loaded in this throwaway session.)

- [ ] **Step 3: Commit**

Run:
```bash
cd ~/Documents/Projects/neovim-setup
git add tmux/.tmux.conf
git commit -m "feat: tmux config (C-a prefix, vim panes, tpm + resurrect)"
```

---

### Task 15: The smart `dev` launcher

**Files:**
- Create: `bin/dev`

- [ ] **Step 1: Write bin/dev**

`bin/dev`:
```bash
#!/usr/bin/env bash
set -euo pipefail

SESSION="$(basename "$PWD" | tr '.:' '__')"

# already running? attach (or switch if inside tmux)
if tmux has-session -t "$SESSION" 2>/dev/null; then
  if [ -n "${TMUX:-}" ]; then
    exec tmux switch-client -t "$SESSION"
  else
    exec tmux attach-session -t "$SESSION"
  fi
fi

# --- detect dev + test commands ---
dev_cmd=""
test_cmd=""
if [ -f package.json ]; then
  if [ -f pnpm-lock.yaml ]; then pm="pnpm";
  elif [ -f yarn.lock ]; then pm="yarn";
  else pm="npm"; fi
  grep -q '"dev"'  package.json && dev_cmd="$pm run dev"
  grep -q '"test"' package.json && test_cmd="$pm test"
elif [ -f go.mod ]; then
  dev_cmd="go run ./..."
  test_cmd="go test ./..."
elif [ -f Cargo.toml ]; then
  dev_cmd="cargo run"
  test_cmd="cargo test"
fi

# infra command
infra_cmd="echo 'no compose file'"
if [ -f docker-compose.yml ] || [ -f docker-compose.yaml ] || [ -f compose.yml ] || [ -f compose.yaml ]; then
  infra_cmd="docker compose ps"
fi

# --- build session ---
tmux new-session -d -s "$SESSION" -n editor
tmux send-keys -t "$SESSION:editor" "nvim ." C-m

win=2
if [ -n "$dev_cmd" ]; then
  tmux new-window -t "$SESSION:$win" -n server
  tmux send-keys -t "$SESSION:server" "$dev_cmd" C-m
  win=$((win+1))
fi
if [ -n "$test_cmd" ]; then
  tmux new-window -t "$SESSION:$win" -n tests
  tmux send-keys -t "$SESSION:tests" "$test_cmd" C-m
  win=$((win+1))
fi

tmux new-window -t "$SESSION:$win" -n infra
tmux send-keys -t "$SESSION:infra" "$infra_cmd" C-m
win=$((win+1))

tmux new-window -t "$SESSION:$win" -n ai
tmux send-keys -t "$SESSION:ai" "claude" C-m

tmux select-window -t "$SESSION:editor"

if [ -n "${TMUX:-}" ]; then
  exec tmux switch-client -t "$SESSION"
else
  exec tmux attach-session -t "$SESSION"
fi
```

- [ ] **Step 2: Make executable**

Run:
```bash
chmod +x ~/Documents/Projects/neovim-setup/bin/dev
```

- [ ] **Step 3: Syntax-check the script**

Run:
```bash
bash -n ~/Documents/Projects/neovim-setup/bin/dev && echo "SYNTAX_OK"
```
Expected: `SYNTAX_OK`.

- [ ] **Step 4: Smoke-test session creation in a temp project (detached, no attach)**

Run:
```bash
tmpdir="$(mktemp -d)"; cd "$tmpdir"
printf '{"scripts":{"dev":"true","test":"true"}}' > package.json
touch pnpm-lock.yaml
# run dev but intercept the final attach by faking we're inside tmux-less + non-interactive:
# instead, build the session manually using the same logic by sourcing is unsafe; just call dev in background-safe way:
SESSION="$(basename "$PWD" | tr '.:' '__')"
~/Documents/Projects/neovim-setup/bin/dev </dev/null >/dev/null 2>&1 || true
tmux list-windows -t "$SESSION" -F '#W' 2>/dev/null | sort | tr '\n' ' '; echo
tmux kill-session -t "$SESSION" 2>/dev/null || true
cd ~ && rm -rf "$tmpdir"
```
Expected: the window list contains `ai editor infra server tests` (order may vary). Because `dev` ends in `exec tmux attach`, running it with stdin redirected from /dev/null returns immediately in a non-TTY context while the detached session persists — the `list-windows` line is the real assertion.

If attach blocks in your environment, instead verify by checking `tmux ls` shows the session, then kill it.

- [ ] **Step 5: Document the OAuth token export in README**

Append to `README.md` under a new `## AI auth` section:
```markdown
## AI auth (one-time)

CodeCompanion uses your Claude subscription via the Claude Code CLI. Generate a token once:

\`\`\`bash
claude setup-token
\`\`\`

Then export it in your shell profile (`~/.zshrc`):

\`\`\`bash
export CLAUDE_CODE_OAUTH_TOKEN="<token-from-setup-token>"
\`\`\`

The tmux `ai` pane runs `claude` directly and uses your normal login — no token needed there.
```

- [ ] **Step 6: Commit**

Run:
```bash
cd ~/Documents/Projects/neovim-setup
git add bin/dev README.md
git commit -m "feat: smart dev tmux launcher + AI auth docs"
```

---

### Task 16: Full system verification

**Files:** none (verification only)

- [ ] **Step 1: Clean headless sync from scratch passes**

Run:
```bash
nvim --headless "+Lazy! sync" +qa 2>&1 | tail -5
```
Expected: completes, no `ERROR`.

- [ ] **Step 2: checkhealth has no fatal errors**

Run:
```bash
nvim --headless "+checkhealth" +qa 2>&1 | grep -iE "ERROR" | grep -viE "treesitter|optional|node|deno|perl|ruby" | head -20
```
Expected: no output (filtered to ignore known-optional warnings). If lines appear, investigate each.

- [ ] **Step 3: Every plugin spec file loads without error**

Run:
```bash
for m in oil trouble lspconfig conform neogit dap neotest kulala codecompanion render-markdown; do
  nvim --headless "+lua print('$m:', pcall(require,'$m'))" +qa 2>&1 | grep "$m:"
done
```
Expected: every line ends in `true`.

- [ ] **Step 4: tmux + dev confirmed (from Task 14/15) still pass**

Run:
```bash
tmux -f ~/.tmux.conf new-session -d -s verify && tmux kill-session -t verify && echo "TMUX_OK"
bash -n ~/.local/bin/dev && echo "DEV_OK"
```
Expected: `TMUX_OK` then `DEV_OK`.

- [ ] **Step 5: Final commit (lock file + any drift)**

Run:
```bash
cd ~/Documents/Projects/neovim-setup
git add -A
git commit -m "chore: lock plugin versions after full verification" || echo "nothing to commit"
git log --oneline | head -20
```
Expected: clean tree; the log shows the task commits.

---

## Manual acceptance (human, post-implementation)

These need a real TTY and can't be headless-verified:
1. `dev` inside a real pnpm repo opens editor/server/tests/infra/ai windows; `C-a 1..5` switches.
2. Open a `.ts` file with an error → red diagnostic appears inline; `<leader>xx` lists it in Trouble.
3. `<leader>aa` opens CodeCompanion chat; after `claude setup-token` + export, a prompt gets a reply.
4. `<leader>gg` opens Neogit; `<leader>gd` opens a diff view.
5. Icons render (Nerd Font present in terminal).
