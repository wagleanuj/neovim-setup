# Cheatsheet — Terminal IDE (LazyVim + tmux + Claude Code)

**Two leaders:** `Ctrl-a` (`C-a`) drives **tmux**; `Space` drives **Neovim**.
Notation: `C-a 1` = Ctrl+a, release, then `1`. `Space ff` = tap Space, then `f`, `f`.
**Forgot a key?** Neovim: press `Space` and pause. tmux: `C-a ?`.

---

## 0. Mental model

```
tmux   = your windows (editor / server / tests / infra / ai)   → C-a + key
nvim   = the editor, inside the "editor" window                → Space + key
neo-tree = the file sidebar (auto-opens)                       → Space e
oil    = edit the filesystem like a buffer                     → -
claude = AI: in-editor split (Space ac) OR full pane (C-a 5)
```

Launch a project: **`dev`** · re-attach later: **`tmux attach -t <repo>`**

---

## 1. tmux — windows, panes, sessions  (prefix `C-a`)

### Windows (tabs — see them in the bottom bar)
| Key | Action |
|-----|--------|
| `C-a 1`..`5` | Jump to window 1–5 (editor/server/tests/infra/ai) |
| `C-a n` / `C-a p` | Next / previous window |
| `C-a l` | Last window (toggle between two) |
| `C-a c` | New window · `C-a ,` rename · `C-a &` kill (default) |
| `C-a w` | Window picker (list) |
| `C-a C-j` | **Fuzzy session switcher** (tmux-fzf; needs `fzf`) |

### Panes (splits in a window)
| Key | Action |
|-----|--------|
| `C-a \|` | Split vertical (cwd) |
| `C-a -` | Split horizontal (cwd) |
| `C-a h/j/k/l` | Move between panes |
| `C-a H/J/K/L` | Resize pane (repeatable) |
| `C-a z` | Zoom pane fullscreen (toggle) |
| `C-a x` | Kill pane |

### Leave / quit / scroll
| Key | Action |
|-----|--------|
| `C-a d` | **Detach** (keeps running; resume with `dev`) |
| `C-a Q` | **Kill whole session** (asks y/n) |
| `C-a X` | Kill current window (asks y/n) |
| `C-a [` | Scroll/copy mode (vim keys; `y` copies to **system clipboard**, `q` exits) |
| `C-a r` | Reload tmux config · `C-a I` install plugins |

From a plain shell: `tmux ls` (list) · `tmux attach -t <name>` · `tmux kill-session -t <name>`.
Mouse is **on** — click windows/panes, scroll, drag borders.

---

## 2. Neovim — core

| Key | Action |
|-----|--------|
| `Space` (pause) | which-key menu |
| `:w` `:q` `:wq` `:qa` | write / quit / write+quit / quit all |
| `i` / `v` / `V` / `Esc` | insert / visual / visual-line / normal |
| `u` / `C-r` / `.` | undo / redo / repeat last change |
| `/text` `n` `N` | search / next / prev |
| `gcc` / `gc` (visual) | comment line / selection |
| `Shift-h` / `Shift-l` | previous / next buffer (tab) |
| `Space bd` | close buffer · `Space ,` buffer picker |
| `Space w` | window cmds (`wv` split, `wd` close) |
| `C-h/j/k/l` | move between splits **and tmux panes** (seamless, no prefix) |
| `Ctrl-w v` / `Ctrl-w s` | split right / below (always works) |
| `Ctrl-w =` / `Ctrl-w \|` | equalize / maximize width |
| `Space l` Lazy · `Space cm` Mason | plugin / tool managers |
| `Space qq` | quit all |

---

## 3. Files, search & explorers

| Key | Action |
|-----|--------|
| `Space Space` / `Space ff` | Find files (fuzzy) |
| `Space /` / `Space sg` | Grep the project |
| `Space sr` | **Search & replace across the project** (grug-far) |
| `Space sw` | Search & replace word under cursor |
| `Space fr` | Recent files · `Space fc` config |
| `Space ,` | Open buffers |
| `Space e` | Toggle the neo-tree sidebar |
| `-` | Open oil (filesystem as a buffer) |

grug-far panel: edit the **Search**/**Replace** fields at the top, results stream below;
`Enter` jumps to a match · `Space sr` again on a selection scopes to that range.

Picker keys: type to filter · `C-n`/`C-p` move · `Enter` open · `C-v` vsplit · `C-x` hsplit · `Esc` cancel.

### neo-tree sidebar (auto-opens; `Space e` toggles)
| Key | Action |
|-----|--------|
| `Enter` / `o` | Open file (to the right) |
| `h` / `l` | Collapse / expand folder |
| `a` `d` `r` `c` | Add / delete / rename / copy |
| `s` / `S` | Open in vertical / horizontal split |
| `H` | Toggle hidden files · `P` preview · `R` refresh |
| `?` | All neo-tree keys · `q` close |

### oil (`-`)
`Enter` open / enter dir · `-` go up · `_` cwd · edit names then `:w` to apply · `g.` hidden · `q` close.

---

## 4. Code intelligence (LSP)

| Key | Action |
|-----|--------|
| `gd` / `gD` | Definition / declaration |
| `gr` / `gI` / `gy` | References / implementation / type def |
| `K` | Hover docs (again to enter float) |
| `Space ca` | Code action (fix / import) |
| `Space cr` | Rename symbol (project-wide; **live preview** as you type) |
| `Space cd` | Line diagnostics |
| `]d` / `[d` | Next / prev diagnostic |
| `]e` / `[e` | Next / prev error |
| `C-Space` | Trigger completion · `Tab` accept · `C-e` cancel |
| `Space cl` | LSP info |
| `Space co` | **Outline** (symbols panel — aerial) |

Breadcrumbs (barbecue) show the symbol path in the winbar at the top of each window.
Servers: vtsls · vue · pyright · gopls · rust-analyzer · tailwind · prisma · graphql ·
docker · yaml · json · lua · **bash · terraform · taplo (TOML) · clangd (C/C++)**.

---

## 5. Formatting

| Key | Action |
|-----|--------|
| `:w` | **Auto-formats on save** (nothing to press) |
| `Space cf` | Format whole file |
| `v`/`V` then `Space cf` | Format **only the selection** |
| `Space uf` / `Space uF` | Toggle format-on-save (global / buffer) |

Formatters: prettier · ruff+black · gofmt · rustfmt · stylua (LSP fallback if missing).

---

## 6. Diagnostics — the Problems panel (Trouble, `Space x`)

| Key | Action |
|-----|--------|
| `Space xx` | **All diagnostics** (the "Problems" panel) |
| `Space xX` | Current-buffer diagnostics |
| `Space xq` | Quickfix · `Space xL` location list |
| `Space xr` | LSP references |
| `Space xt` | Todo/Fixme comments |

In the panel: `j/k` move · `Enter` jump · `Tab` fold group · `q` close.

Beyond LSP, **nvim-lint** adds file-type linters on save/read: shellcheck (sh/bash),
hadolint (Dockerfile), markdownlint (md), yamllint (yaml), golangci-lint (go).

---

## 7. Git (`Space g`)

| Key | Action |
|-----|--------|
| `Space gg` | **Neogit** (stage/commit/push) |
| `Space gd` | **Diffview** (working-tree diff) |
| `Space gh` | File history · `Space gc` conflicts → quickfix |
| `Space gi` / `Space gp` | GitHub issues / PRs (octo) |
| `]h` / `[h` | Next / prev changed hunk |
| `Space ghs` / `Space ghr` | Stage / reset hunk |
| `Space ghp` / `Space ghb` | Preview hunk / blame line |

Neogit: `s` stage · `u` unstage · `cc` commit (`C-c C-c` confirm) · `P` push · `F` pull · `q` close.
Diffview: `Tab`/`S-Tab` next/prev file · `:DiffviewClose`.

---

## 8. Debugging (`Space d` — nvim-dap)

| Key | Action |
|-----|--------|
| `Space db` | Toggle breakpoint |
| `Space dc` | Start / continue |
| `Space di` / `Space do` | Step into / step over |
| `Space dO` | Step out · `Space dt` terminate |
| `Space du` | Toggle DAP UI (vars/stack/watches/repl) |

Adapters: js/ts · python (debugpy) · go (delve) · rust (codelldb).

---

## 9. Testing (`Space t` — neotest)

| Key | Action |
|-----|--------|
| `Space tt` | Run nearest test |
| `Space tf` | Run all tests in file |
| `Space ts` | Toggle summary panel |
| `Space to` | Open output |

Adapters: jest · vitest · python · go (auto-picked per project).

---

## 10. Database (`Space D` — vim-dadbod)

| Key | Action |
|-----|--------|
| `Space Du` | Toggle Database UI |

In DBUI: `A` add connection (`postgres://user:pass@host/db`) · `Enter` expand · write SQL · `C-c C-c` run.

---

## 11. REST client (`.http` files, `Space r` — kulala)

| Key | Action |
|-----|--------|
| `Space rs` | Send request under cursor |
| `Space ra` | Send all requests in file |
| `Space rn` / `Space rp` | Next / previous request |

```
GET https://api.github.com/repos/neovim/neovim
Accept: application/json
```
then `Space rs`.

---

## 12. Markdown + images (`Space m`)

| Key | Action |
|-----|--------|
| (open any `.md`) | render-markdown styles it inline automatically |
| `![](path-or-url)` | image renders **inline** (local & remote) — Ghostty + snacks.image |
| `Space mp` | Toggle full **browser preview** (Mermaid, math, all images) |

---

## 13. AI — Claude Code (`Space a`) + agent pane

In-editor (`claudecode.nvim`) — uses your Claude login, **no token/API key**:

| Key | Action |
|-----|--------|
| `Space ac` | Toggle Claude (split) |
| `Space af` | Focus Claude window |
| `Space as` | (visual) send selection · (tree) add file |
| `Space ab` | Add current buffer to context |
| `Space aa` | **Accept** proposed diff |
| `Space ad` | **Reject** proposed diff |
| `Space ar` / `Space aC` | Resume / continue session |

Loop: select → `Space as` → ask → diff → `Space aa` accept / `Space ad` reject.
Full-screen agent: tmux **ai window** (`C-a 5`) runs `claude` for big multi-file jobs.

---

## 14. Sessions — remember open files (`Space q`)

| Key | Action |
|-----|--------|
| (bare `nvim`) | **Auto-restores** this folder's session on startup |
| `Space qs` | Manually restore this folder's last session (files + splits) |
| `Space ql` | Restore the very last session |
| `Space qd` | Don't save current session |

Saved automatically on quit, **per directory**, and now auto-loaded when you open a
bare `nvim` in that directory (a launch with a file arg or piped stdin won't restore).
tmux layout auto-restores on reboot.

---

## 15. Toggles (`Space u`)

| Key | Action |
|-----|--------|
| `Space uf` / `Space uF` | Format-on-save (global / buffer) |
| `Space us` | Spell · `Space uw` wrap · `Space ul` line numbers |
| `Space ud` | Diagnostics · `Space uh` inlay hints |
| `Space uz` | Zen mode |
| `Space uc` | Toggle **sticky context** (function pinned at top) |
| `Space uu` | Toggle **undotree** (persistent undo history) |

Hex/rgb/tailwind colors render as live swatches in code (nvim-colorizer).

---

## 16. Daily rhythm

```
cd ~/project → dev          spin up the session (tree + editor)
Space Space                 jump to a file
gd / K                      navigate / read
Space ca / Space cr         fix / rename
v → Space cf  (or :w)       format selection / whole file
Space xx                    check the Problems panel
Space tt                    run the test you're on
select → Space as → Space aa   ask Claude, accept its diff
Space gg                    stage & commit
C-a 5                       hand a big job to the claude agent
C-a d                       detach · `dev` to come back · Space qs restores files
```

---

## When you forget
- **Neovim:** `Space` and wait · `Space sk` search keymaps · `:checkhealth`
- **tmux:** `C-a ?` lists every binding
- **This file:** `Space ff` → `CHEATSHEET.md`
