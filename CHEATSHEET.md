# Cheatsheet — Terminal IDE (LazyVim + tmux + Claude Code)

Leader = **`Space`**. tmux prefix = **`Ctrl-a`** (written `C-a`).
Press `Space` and *pause* in Neovim → which-key shows everything live. This file is the map.

---

## 0. The mental model

```
tmux  = your windows (editor / server / tests / infra / ai)   → C-a + key
nvim  = your editor inside the "editor" window                → Space + key
oil   = edit the filesystem like a buffer                      → -
claude= the AI agent, its own tmux window                      → C-a 3 (or 5)
```

Launch everything from any repo: **`dev`** → attach later: **`tmux attach -t <repo>`**

---

## 1. tmux  (prefix `C-a`, then…)

| Key | Action |
|-----|--------|
| `C-a 1`..`5` | Jump to window by number (editor/server/tests/infra/ai) |
| `C-a n` / `C-a p` | Next / previous window |
| `C-a d` | **Detach** (session keeps running in background) |
| `C-a Q` | **Quit/kill the whole session** (asks y/n) |
| `C-a X` | Kill just the current window (asks y/n) |
| `C-a c` | New window |
| `C-a ,` | Rename window |
| `C-a \|` | Split pane vertical (in cwd) |
| `C-a -` | Split pane horizontal (in cwd) |
| `C-a h/j/k/l` | Move between panes (vim-style) |
| `C-a H/J/K/L` | Resize pane (repeatable) |
| `C-a z` | Zoom pane fullscreen (toggle) |
| `C-a [` | Copy/scroll mode (then vim keys; `q` to exit) |
| `C-a r` | Reload tmux config |
| `C-a I` | Install tmux plugins (one-time, capital i) |
| `C-a x` | Kill current pane |
| `C-a &` | Kill current window |

Mouse is **on** — you can click windows/panes and scroll. From the shell: `tmux ls` (list), `tmux kill-session -t <name>`.

---

## 2. Neovim — core moves

| Key | Action |
|-----|--------|
| `Space` (pause) | which-key menu (your safety net) |
| `:w` `:q` `:wq` `:qa` | write / quit / write+quit / quit all |
| `Space w` | window commands (`Space wv` split, `Space wd` close) |
| `C-h/j/k/l` | move between splits |
| `Shift-h` / `Shift-l` | previous / next buffer (tab) |
| `Space bd` | close buffer · `Space bb` last buffer |
| `Space ,` | switch buffer (picker) |
| `Space l` | Lazy (plugin manager) · `Space cm` Mason (LSP installer) |
| `Space qq` | quit all · `Space qs` restore session |
| `gcc` | comment line · `gc` (visual) comment selection |
| `u` / `C-r` | undo / redo · `.` repeat last change |
| `/text` `n` `N` | search / next / prev |

**Modes:** `i` insert · `v` visual · `V` visual-line · `Esc` back to normal · `:` command.

---

## 3. Files & search

| Key | Action |
|-----|--------|
| `Space Space` or `Space ff` | **Find files** (fuzzy) |
| `Space fr` | Recent files |
| `Space /` or `Space sg` | **Grep** project (live search text) |
| `Space ,` | Open buffers |
| `Space e` | **Toggle the neo-tree sidebar** (collapse/expand) |
| `Space fc` | Open your nvim config |

### neo-tree sidebar (auto-opens on startup, `Space e` toggles)
| Key | Action |
|-----|--------|
| `Space e` | Show/hide the tree |
| `Enter` / `o` | Open file (in the editor to the right) |
| `h` / `l` | Collapse / expand folder |
| `a` `d` `r` | Add / delete / rename (file ops) |
| `H` | Toggle hidden/dotfiles |
| `s` / `S` | Open in vertical / horizontal split |
| `P` | Toggle preview of the highlighted file |
| `?` | Show all neo-tree keys |

### oil (the `-` file manager)
| Key | Action |
|-----|--------|
| `-` | Open parent dir as an editable buffer |
| `Enter` | Open file / go into dir |
| `_` | Go to cwd |
| edit + `:w` | **Apply** changes (create/rename/delete files like text!) |
| `g.` | Toggle hidden files |
| `q` | Close oil |

> In a picker: type to filter, `C-n`/`C-p` or arrows to move, `Enter` open, `C-v` open in vsplit, `Esc` cancel.

---

## 4. Code intelligence (LSP)

| Key | Action |
|-----|--------|
| `gd` | Go to definition · `gD` declaration |
| `gr` | References · `gI` implementation · `gy` type definition |
| `K` | Hover docs (press again to enter the float) |
| `Space ca` | **Code action** (quick fix, import, etc.) |
| `Space cr` | Rename symbol (project-wide) |
| `Space cf` | **Format** buffer (also auto on save) |
| `Space cd` | Line diagnostics (the error under cursor) |
| `]d` / `[d` | Next / previous diagnostic |
| `]e` / `[e` | Next / previous **error** |
| `C-Space` | Trigger completion (in insert mode) · `Tab` accept |

---

## 5. Diagnostics & lists — Trouble (`Space x`)

| Key | Action |
|-----|--------|
| `Space xx` | All diagnostics (project) |
| `Space xX` | Buffer diagnostics only |
| `Space xr` | LSP references list |
| `Space xq` | Quickfix list |

Inside Trouble: `Enter` jump, `q` close.

---

## 6. Git (`Space g`)

| Key | Action |
|-----|--------|
| `Space gg` | **Neogit** (stage/commit/push UI) |
| `Space gd` | **Diffview** (side-by-side diff of working tree) |
| `Space gh` | File history (this file's commits) |
| `Space gc` | Git conflicts → quickfix |
| `Space gi` | GitHub issues (octo, needs `gh auth`) |
| `Space gp` | GitHub PRs (octo) |
| `]h` / `[h` | Next / prev changed hunk (gitsigns) |
| `Space ghs` / `Space ghr` | Stage / reset hunk |
| `Space ghb` | Blame line |

**Neogit basics:** `s` stage · `u` unstage · `c c` commit (write msg, `C-c C-c` to confirm) · `P` push · `F` pull · `q` close.
**Diffview:** `Tab`/`S-Tab` next/prev file · `Space gd` then `:DiffviewClose`.

---

## 7. Testing — neotest (`Space t`)

| Key | Action |
|-----|--------|
| `Space tt` | Run **nearest** test |
| `Space tf` | Run all tests in **file** |
| `Space ts` | Toggle test summary panel |
| `Space to` | Open test output |

(Adapters: jest, vitest, python, go — auto-picks per project.)

---

## 8. Debugging — nvim-dap (`Space d`)

| Key | Action |
|-----|--------|
| `Space db` | Toggle breakpoint |
| `Space dc` | Start / continue |
| `Space di` | Step into · `Space do` step over |
| `Space du` | Toggle the DAP UI (variables/stack/watches) |

(Adapters: js/ts, python, go (delve), rust (codelldb).)

---

## 9. AI — Claude Code in Neovim (`Space a`)  +  Claude agent pane

Native Claude Code integration (`claudecode.nvim`) — runs the `claude` CLI in a
split, wired to your editor. Uses your normal Claude login (**no token/API key**).

| Key | Action |
|-----|--------|
| `Space ac` | **Toggle Claude** (open/close the split) |
| `Space af` | Focus the Claude window |
| `Space as` | (visual) **Send selection** to Claude · (in tree) add file |
| `Space ab` | Add current **buffer** to Claude's context |
| `Space aa` | **Accept** the proposed diff |
| `Space ad` | **Reject** the proposed diff |
| `Space ar` | Resume a previous Claude session |
| `Space aC` | Continue the last Claude session |

Typical loop: select code → `Space as` → ask Claude → it proposes a diff → `Space aa` to accept / `Space ad` to reject. Add files to context from the neo-tree with `Space as`.

**Claude agent pane (repo-wide):** `C-a 3` (tmux) → a full-screen `claude`. Also no token — uses your login.

> Two surfaces: `Space ac` = Claude *inside* the editor with diff accept/reject. `C-a 3` = full agent for sprawling multi-file work.

---

## 10. Database — dadbod (`Space D`)

| Key | Action |
|-----|--------|
| `Space Du` | Toggle Database UI |

In DBUI: `Space Du` to open → `A` add connection (paste a URL like `postgres://user:pass@host/db`) → expand tables with `Enter` → write SQL in a `.sql` buffer → `Space S` (or `C-c C-c` in a query buffer) to execute.

---

## 11. REST client — kulala (`.http` files, `Space r`)

| Key | Action |
|-----|--------|
| `Space rs` | Send request under cursor |
| `Space ra` | Send all requests in file |
| `Space rn` / `Space rp` | Next / previous request |

Make a file `api.http`, write:
```
GET https://api.github.com/repos/neovim/neovim
Accept: application/json
```
then `Space rs`.

---

## 12. Markdown (`Space m`)

| Key | Action |
|-----|--------|
| `Space mp` | Toggle browser preview (renders Mermaid diagrams) |

(render-markdown also styles markdown inline as you edit.)

---

## 13. Daily flow — the 10-second version

```
cd ~/project   →  dev            # spin up the whole session
C-a 1          →  edit in nvim
Space Space    →  jump to a file
gd / K         →  navigate / read code
Space ca       →  fix / import
Space cf       →  format (auto on save anyway)
Space tt       →  run the test you're on
Space gg       →  stage & commit
C-a 3          →  hand a big task to the claude agent
C-a d          →  detach, go to lunch, dev to come back
```

---

## When you forget a key
- **Neovim:** press `Space` and wait — the menu shows the way. Or `Space sk` to search all keymaps.
- **tmux:** `C-a ?` lists every binding.
- This file: `Space ff` → `CHEATSHEET.md`.
