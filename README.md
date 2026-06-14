# neovim-setup — A Terminal IDE

A fast, opinionated terminal IDE built on **Neovim (LazyVim) + tmux + Claude Code**.
Version-controlled dotfiles, installed via symlinks. Everything VS Code / Cursor give you —
file tree, LSP, formatting, git, debugging, tests, database, REST, AI, inline images,
session persistence — without the Electron weight.

> Full keybinding reference lives in **[CHEATSHEET.md](CHEATSHEET.md)**.

---

## Table of contents

- [Quick start](#quick-start)
- [Requirements](#requirements)
- [Repository layout](#repository-layout)
- [The two prefixes](#the-two-prefixes-the-whole-mental-model)
- [tmux: windows, panes, the bottom bar](#tmux)
- [The `dev` launcher](#the-dev-launcher)
- [Neovim feature tour](#neovim-feature-tour)
  - [File tree (neo-tree) & oil](#file-tree-neo-tree--oil)
  - [Finding things](#finding-things)
  - [Code intelligence (LSP)](#code-intelligence-lsp)
  - [Formatting](#formatting)
  - [Diagnostics / the Problems panel](#diagnostics--the-problems-panel)
  - [Git](#git)
  - [Debugging](#debugging)
  - [Testing](#testing)
  - [Database](#database)
  - [REST client](#rest-client)
  - [Markdown + inline images](#markdown--inline-images)
  - [AI: Claude Code in the editor](#ai-claude-code-in-the-editor)
  - [Sessions: remembering open files](#sessions-remembering-open-files)
- [Languages supported](#languages-supported)
- [Customizing](#customizing)
- [Troubleshooting](#troubleshooting)

---

## Quick start

```bash
git clone https://github.com/wagleanuj/neovim-setup ~/Documents/Projects/neovim-setup
cd ~/Documents/Projects/neovim-setup
./install.sh
```

Then, one time:

1. **Open `nvim` once** — Mason auto-installs LSP servers, formatters, and debuggers.
2. **Log into Claude** — run `claude` once and sign in. In-editor AI uses this login;
   **no API key or token needed.**
3. **Install tmux plugins** — start tmux, press `C-a` then `I` (capital i).
4. **Use a Nerd Font** in your terminal (icons). Ghostty/iTerm2/WezTerm/Kitty all work.
5. From any project directory, run **`dev`**.

`install.sh` is idempotent: it checks dependencies (installs `lazygit`/`fd` via brew if
missing), backs up any existing `~/.config/nvim` / `~/.tmux.conf`, symlinks this repo into
place, and clones tpm.

---

## Requirements

- **Neovim ≥ 0.10** (built/tested on 0.11)
- **tmux ≥ 3.4** (3.5+ recommended for graphics passthrough)
- **A Nerd Font** in your terminal (for icons)
- **Claude Code CLI** (`claude`) — for the AI integration
- macOS or Linux. `brew`, `git`, `node`, and a per-language toolchain as needed.
- Optional but recommended: `ImageMagick` (inline images), `lazygit`, `fd`, `ripgrep`.

---

## Repository layout

```
neovim-setup/
├── install.sh              idempotent installer (deps + symlinks + tpm)
├── README.md               this file
├── CHEATSHEET.md           full keybinding reference
├── nvim/         ────────► ~/.config/nvim
│   ├── init.lua            bootstraps LazyVim
│   └── lua/
│       ├── config/
│       │   ├── lazy.lua    plugin specs + LazyVim extras imported
│       │   ├── options.lua editor options
│       │   ├── keymaps.lua custom keymaps
│       │   └── autocmds.lua custom autocmds
│       └── plugins/
│           ├── colorscheme.lua  tokyonight
│           ├── editor.lua       oil, trouble
│           ├── explorer.lua     neo-tree (+ auto-open sidebar)
│           ├── snacks.lua       dashboard off, inline images on
│           ├── lsp.lua          language servers
│           ├── formatting.lua   conform + format-on-save
│           ├── git.lua          neogit, diffview, git-conflict, octo
│           ├── dap.lua          debugging
│           ├── testing.lua      neotest
│           ├── database.lua     vim-dadbod
│           ├── rest.lua         kulala (.http)
│           └── markdown.lua     render-markdown + browser preview
├── tmux/.tmux.conf ──────► ~/.tmux.conf
└── bin/dev        ───────► ~/.local/bin/dev   (smart project launcher)
```

LazyVim owns the core; each `plugins/*.lua` is a small, focused override.

---

## The two prefixes (the whole mental model)

You drive everything with two "leader" keys. Keep them straight and the rest follows:

| Prefix | Wakes up | For |
|--------|----------|-----|
| **`Ctrl-a`** (written `C-a`) | **tmux** | windows, panes, sessions |
| **`Space`** | **Neovim** | everything inside the editor |

Notation: `C-a 1` = Ctrl+a, release, then `1`. `Space ff` = tap Space, then `f`, `f`.
Forgot a key? In Neovim press **`Space`** and pause — the which-key menu shows everything.
In tmux press **`C-a ?`**.

---

## tmux

`tmux` keeps a persistent multi-window workspace per project. Prefix is **`C-a`**.

### Windows (your "tabs")

The bottom status bar shows each window with an app icon, active one highlighted:

```
 myproject     1  editor   2  server   3  tests   4 󰡨 infra   5 󰚩 ai      Sat 14 Jun  12:30
              └ nvim ─────── server ───── tests ──── docker ──── claude ┘
```

| Key | Action |
|-----|--------|
| `C-a 1`..`5` | Jump to window by number |
| `C-a n` / `C-a p` | Next / previous window |
| `C-a l` | **Last** window (toggle between two) |
| `C-a c` | New window · `C-a ,` rename |
| `C-a d` | **Detach** (session keeps running) |
| `C-a Q` | **Kill the whole session** (confirms y/n) |
| `C-a X` | Kill the current window (confirms y/n) |

### Panes (splits within a window)

| Key | Action |
|-----|--------|
| `C-a \|` | Split vertical · `C-a -` split horizontal (both open in cwd) |
| `C-a h/j/k/l` | Move between panes (vim-style) |
| `C-a H/J/K/L` | Resize pane (repeatable) |
| `C-a z` | Zoom pane fullscreen (toggle) |
| `C-a x` | Kill pane |
| `C-a [` | Scroll/copy mode (vim keys; `q` exits) |

Other: mouse is **on** (click windows/panes, scroll). `C-a r` reloads the config.
Plugins: tmux-sensible, **tmux-resurrect** + **tmux-continuum** (layout auto-restored on
reboot). Graphics passthrough is enabled so inline images work through tmux.

---

## The `dev` launcher

Run `dev` from any project to spin up (or re-attach to) a tmux session named after the repo:

```bash
cd ~/my-app
dev
```

Windows created: **editor · server · tests · infra · ai** — `server`/`tests` appear only
when a project type is detected.

**Nothing auto-runs except your editor.** The other windows open with the likely command
*pre-typed on the prompt but NOT executed* — you review/edit and press Enter yourself:

```
editor: nvim                 (runs — opens tree + editor)
server: % pnpm run dev       (typed, waiting for Enter)
tests:  % pnpm test          (typed, waiting)
infra:  % docker compose ps  (typed, only if a compose file exists)
ai:     % claude             (typed, waiting)
```

Detection: `package.json` (pnpm/yarn/npm by lockfile) · `go.mod` · `Cargo.toml`. A bun repo
shows `npm run dev` — just edit it to `bun run dev` before Enter. Re-running `dev` in the
same repo **re-attaches** instead of duplicating.

---

## Neovim feature tour

Leader is **`Space`**. The which-key menu (press Space, pause) is your safety net.

### File tree (neo-tree) & oil

A VS Code-style **neo-tree sidebar auto-opens on startup** (left), focus stays in the editor.

| Key | Action |
|-----|--------|
| `Space e` | Toggle the tree (collapse/expand the whole sidebar) |
| `Enter` / `o` | Open file (in the editor to the right) |
| `h` / `l` | Collapse / expand a folder |
| `a` `d` `r` | Add / delete / rename |
| `s` / `S` | Open highlighted file in vertical / horizontal split |
| `H` | Toggle hidden/dotfiles · `P` preview · `?` all keys |

**oil** is the other explorer — edit the filesystem *like a text buffer*. Press `-` to open
the current directory; rename by editing names, delete by deleting lines, then `:w` to apply.

### Finding things

| Key | Action |
|-----|--------|
| `Space Space` or `Space ff` | Find files (fuzzy) |
| `Space /` or `Space sg` | Grep the whole project |
| `Space fr` | Recent files · `Space ,` open buffers |
| `Space fc` | Open your nvim config |

In any picker: type to filter, `C-n`/`C-p` move, `Enter` open, `C-v` open in vsplit, `Esc` cancel.

### Code intelligence (LSP)

| Key | Action |
|-----|--------|
| `gd` / `gD` | Go to definition / declaration |
| `gr` / `gI` / `gy` | References / implementation / type definition |
| `K` | Hover docs (press again to enter the float) |
| `Space ca` | Code action (quick fix, auto-import) |
| `Space cr` | Rename symbol (project-wide) |
| `Space cd` | Line diagnostics · `]d`/`[d` next/prev diagnostic |
| `C-Space` | Trigger completion (insert mode) · `Tab` accept |

### Formatting

- **On save:** every `:w` auto-formats supported files. Nothing to press.
- **Whole file:** `Space cf`
- **Just a selection:** select with `v`/`V`, then `Space cf` (formats only the range)
- **Toggle auto-format:** `Space uf` (global) · `Space uF` (this buffer)

Formatters: prettier (web), ruff+black (py), gofmt (go), rustfmt (rust), stylua (lua).
Falls back to the LSP formatter if a tool is missing.

### Diagnostics / the Problems panel

**Trouble** is the VS Code "Problems" panel.

| Key | Action |
|-----|--------|
| `Space xx` | All diagnostics (the Problems panel) |
| `Space xX` | Current-buffer diagnostics |
| `Space xq` | Quickfix list · `Space xr` LSP references |
| `]e` / `[e` | Next / previous error (skip warnings) |

Inline you always get gutter signs, end-of-line virtual text, and statusline counts.
Note: like all nvim LSPs, diagnostics cover files you've **opened** this session, not the
whole disk — use the linter/CI or `Space sg` for a project-wide sweep.

### Git

| Key | Action |
|-----|--------|
| `Space gg` | **Neogit** (stage/commit/push UI) |
| `Space gd` | **Diffview** (side-by-side working-tree diff) |
| `Space gh` | File history · `Space gc` conflicts |
| `Space gi` / `Space gp` | GitHub issues / PRs (octo — needs `gh auth`) |
| `]h` / `[h` | Next / prev changed hunk |
| `Space ghs` / `Space ghr` | Stage / reset hunk · `Space ghb` blame line |

Neogit: `s` stage, `u` unstage, `cc` commit, `P` push, `F` pull, `q` close.

### Debugging

`nvim-dap` with a UI. Adapters: js/ts, python (debugpy), go (delve), rust (codelldb).

| Key | Action |
|-----|--------|
| `Space db` | Toggle breakpoint |
| `Space dc` | Start / continue |
| `Space di` / `Space do` | Step into / over |
| `Space du` | Toggle the DAP UI (vars / stack / watches) |

### Testing

`neotest` with jest, vitest, python, and go adapters (auto-picked per project).

| Key | Action |
|-----|--------|
| `Space tt` | Run nearest test · `Space tf` run file |
| `Space ts` | Toggle summary panel · `Space to` open output |

### Database

`vim-dadbod` UI for Postgres / MySQL / SQLite.

- `Space Du` — toggle the Database UI
- In DBUI: `A` add a connection (`postgres://user:pass@host/db`), `Enter` expand tables,
  write SQL in a buffer, `C-c C-c` to run.

### REST client

`kulala` runs `.http` files. Create `api.http`:

```
GET https://api.github.com/repos/neovim/neovim
Accept: application/json
```

- `Space rs` send request under cursor · `Space ra` send all · `Space rn`/`Space rp` next/prev.

### Markdown + inline images

Three layers:

1. **Inline styling** (`render-markdown.nvim`, automatic) — headings, checkboxes, boxed
   code, drawn tables, right in the buffer.
2. **Inline images** (`snacks.image`) — real images render in the editor, **local and
   remote/linked URLs**. Works because the terminal speaks the Kitty graphics protocol
   (Ghostty/Kitty/WezTerm) + ImageMagick + tmux passthrough.
3. **Browser preview** (`Space mp`) — live preview with synced scroll, Mermaid diagrams,
   and math.

### AI: Claude Code in the editor

Native Claude Code integration via `claudecode.nvim` — runs the `claude` CLI in a split,
wired to your editor. **Uses your normal Claude login; no API key/token.**

| Key | Action |
|-----|--------|
| `Space ac` | Toggle Claude (open/close the split) |
| `Space af` | Focus the Claude window |
| `Space as` | (visual) send selection · (in tree) add file to context |
| `Space ab` | Add current buffer to context |
| `Space aa` / `Space ad` | Accept / reject the proposed diff |
| `Space ar` / `Space aC` | Resume / continue a session |

Typical loop: **select code → `Space as` → ask → Claude proposes a diff → `Space aa` to
accept**. Pull files into context straight from the neo-tree with `Space as`.

There are **two AI surfaces**: `Space ac` (Claude inside the editor, with diff accept/reject)
and the tmux **`C-a` ai window** (a full-screen `claude` agent for sprawling multi-file work).
Files edited by either are auto-reloaded in Neovim when you switch back (tmux focus events).

### Sessions: remembering open files

`persistence.nvim` saves your open files + window layout **per directory** on exit.

| Key | Action |
|-----|--------|
| `Space qs` | Restore this folder's last session (open files + splits) |
| `Space ql` | Restore the very last session (any folder) |
| `Space qd` | Don't save the current session |

By default this is **manual** (press `Space qs` after opening a project). tmux-continuum
auto-restores the *window/pane layout* on a full reboot.

---

## Languages supported

Pre-wired LSP + formatter + debugger + test runner for:

- **TypeScript / JavaScript / Vue / web** — vtsls, vue_ls, tailwindcss, prismals, graphql,
  dockerls, yamlls, jsonls · prettier + eslint_d · jest/vitest
- **Python** — pyright · ruff + black · debugpy · neotest-python
- **Go** — gopls · gofmt · delve · neotest-go
- **Rust** — rust-analyzer · rustfmt · codelldb
- **Lua** — lua_ls · stylua

Add more via `:Mason` and a one-line entry in `nvim/lua/plugins/lsp.lua`.

---

## Customizing

- **Colorscheme:** `nvim/lua/plugins/colorscheme.lua` (currently tokyonight).
- **Re-enable the start dashboard:** set `dashboard = { enabled = true }` in
  `nvim/lua/plugins/snacks.lua` (note it conflicts with the auto-opened tree).
- **Tree width / behavior:** `nvim/lua/plugins/explorer.lua`.
- **`dev` detection/commands:** `bin/dev`.
- **Keymaps:** `nvim/lua/config/keymaps.lua`; tmux in `tmux/.tmux.conf`.

After editing tmux config: `C-a r` to reload. After editing nvim: restart or `:Lazy reload`.

---

## Troubleshooting

- **Icons are boxes** → your terminal isn't using a Nerd Font. Set one in terminal settings.
- **Inline images don't show** → fully restart tmux (`tmux kill-server`) so
  `allow-passthrough on` takes effect; confirm terminal supports Kitty graphics and that
  `magick` is installed.
- **AI won't respond** → run `claude` once in a terminal and log in.
- **LSP/formatter missing** → open `:Mason` and install it, or `:checkhealth`.
- **A plugin misbehaves after update** → `:Lazy` → `U` to update, or restore a pinned
  version from `nvim/lazy-lock.json`.
- **Browser markdown preview fails** → open a `.md` and run `:call mkdp#util#install()`.

---

Built as a from-scratch terminal IDE. See `docs/superpowers/` for the original design spec
and implementation plan.
