# Terminal IDE — LazyVim + tmux + Claude Code

**Date:** 2026-06-04
**Status:** Approved design, pending implementation plan
**Owner:** anuj@twinnlinks.com

## Goal

A fast, opinionated terminal IDE built on Neovim + tmux + Claude Code, version-controlled as
a dotfiles repo and installed via symlinks. It should deliver an IDE-grade experience
(LSP, completion, formatting, git, debugging, testing, database, REST, AI) for a polyglot
stack without the Electron weight of VS Code/Cursor, and bootstrap a full multi-window dev
session with a single `dev` command.

## Environment (verified 2026-06-04)

- Neovim **0.11.4**, tmux **3.5a** — both modern, no upgrade needed.
- **No existing `~/.config/nvim`** — clean install, nothing to back up.
- Present: `brew, git, node (v22), pnpm, go, cargo, python3, rustc, rg`.
- Missing, installed by `install.sh`: `lazygit`, `fd`.
- Claude Code CLI already in use (subscription auth available).

## Key decisions

| Decision | Choice | Rationale |
|---|---|---|
| Base | **LazyVim distro** | Professional IDE instantly; we own only the deltas |
| Config home | **Dotfiles repo + symlink** | Version-controlled, portable, pushable to GitHub |
| In-editor AI | **CodeCompanion → Claude Code (ACP)** | Reuses Claude subscription; **no API key** |
| Agent shell | **Claude Code in tmux `ai` pane** | Already installed; no extra plugin |
| Languages | **TS/JS+Vue+web, Python, Go, Rust** | Full polyglot stack |
| Extras | dadbod (DB), kulala (REST), render-markdown, octo (GitHub) | All requested |
| `dev` launcher | **Smart / auto-detect** | Picks commands per project type, skips N/A windows |
| Colorscheme | tokyonight (LazyVim default) | Swappable in one line |
| Explicitly excluded | Avante, 2nd completion engine, multiple file trees, theme zoo | YAGNI |

## Repository layout

```
neovim-setup/                    git repo (push to GitHub later)
├── install.sh                   idempotent: check deps, back up, symlink
├── README.md
├── docs/superpowers/specs/      this spec
├── nvim/                ──────►  ~/.config/nvim
│   ├── init.lua                 bootstraps LazyVim
│   ├── lua/config/
│   │   ├── options.lua          LazyVim option overrides
│   │   ├── keymaps.lua          custom keymaps (free namespaces only)
│   │   └── autocmds.lua         format-on-save guard, etc.
│   └── lua/plugins/
│       ├── ai.lua               CodeCompanion (claude_code ACP)
│       ├── editor.lua           oil, snacks, telescope, trouble, which-key
│       ├── coding.lua           treesitter extras, surround, autopairs, Comment
│       ├── lsp.lua              vtsls, vue_ls, pyright, gopls, rust-analyzer + web servers
│       ├── formatting.lua       conform: prettier/eslint_d/ruff/black/gofmt/rustfmt
│       ├── git.lua              gitsigns, neogit, diffview, git-conflict, octo
│       ├── dap.lua              nvim-dap + dap-ui + virtual-text (JS/TS, Python, Go, Rust)
│       ├── testing.lua          neotest + jest/vitest/python/go adapters
│       ├── database.lua         vim-dadbod + dadbod-ui + dadbod-completion
│       ├── rest.lua             kulala.nvim (.http client)
│       └── markdown.lua         render-markdown.nvim + mermaid preview
├── tmux/.tmux.conf      ──────►  ~/.tmux.conf
└── bin/dev              ──────►  ~/.local/bin/dev
```

LazyVim owns the core. Each `plugins/*.lua` is a small, single-purpose spec that can be
disabled or edited in isolation. This keeps any one file small enough to reason about whole.

## Components

### 1. install.sh
Idempotent bootstrap. Responsibilities:
- Verify Neovim ≥ 0.10 and tmux ≥ 3.4; warn otherwise.
- `brew install lazygit fd` if missing.
- Back up any existing `~/.config/nvim`, `~/.tmux.conf` to `*.bak.<n>` (none currently).
- Symlink `nvim/` → `~/.config/nvim`, `tmux/.tmux.conf` → `~/.tmux.conf`,
  `bin/dev` → `~/.local/bin/dev` (creating `~/.local/bin`).
- Clone tpm to `~/.tmux/plugins/tpm` if absent.
- Print next steps (open nvim for Mason install, `claude setup-token`, tmux `prefix + I`).

**Interface:** `./install.sh` from repo root. Safe to re-run.
**Depends on:** bash, git, brew, ln.

### 2. nvim/ (LazyVim + plugin deltas)
- `init.lua` bootstraps lazy.nvim and imports `lua/config` + `lua/plugins`.
- LSP via mason-lspconfig: `vtsls`, `vue_ls`, `pyright`, `gopls`, `rust-analyzer`,
  `tailwindcss`, `prismals`, `graphql`, `dockerls`, `yamlls`, `jsonls`, `lua_ls`.
- Formatting via conform.nvim: prettier/eslint_d (web), ruff+black (py), gofmt (go),
  rustfmt (rust), stylua (lua). Format-on-save, toggleable.
- DAP: vscode-js for Node/TS/Jest/Vitest, debugpy (Python), delve (Go), codelldb (Rust).
- neotest adapters: jest, vitest, python, go.
- All LSPs/formatters/DAPs auto-installed by Mason on first launch — no manual steps.

**Interface:** opening `nvim`. **Depends on:** Neovim 0.11.4, internet (first run), Mason.

### 3. AI layer
- **CodeCompanion** configured with `interactions.chat.adapter = "claude_code"` and the
  `claude_code` ACP adapter. Auth via `CLAUDE_CODE_OAUTH_TOKEN` (from `claude setup-token`)
  — **no metered `ANTHROPIC_API_KEY`**. Inline strategy uses the same adapter.
- Keymaps: `<leader>aa` chat toggle, `<leader>ac` actions, visual `<leader>ae` explain,
  visual `<leader>ar` refactor.
- **Agent shell:** the tmux `ai` window simply runs `claude`.

**Interface:** `<leader>a*` in nvim; `claude` in the ai pane.
**Depends on:** Claude Code CLI + a one-time `claude setup-token`.
**Caveat:** ACP adapter is newer than the native Anthropic one; swapping adapters is a
one-block config change if it misbehaves.

### 4. tmux/.tmux.conf
- Prefix `C-a`, mouse on, 50k scrollback, base-index 1, renumber-windows on, status top.
- vim-style splits (`|` `-`) and pane nav (`h/j/k/l`), resize (`H/J/K/L`), `r` reload.
- Plugins via tpm: tmux-sensible, tmux-resurrect, tmux-continuum (auto save/restore).

**Interface:** `~/.tmux.conf`. **Depends on:** tmux 3.5a, tpm.

### 5. bin/dev (smart launcher)
`dev` → tmux session named after `basename $PWD`. Detects project type and builds windows:
- **editor**: `nvim .` (always)
- **server**: dev command if detectable (`pnpm/npm/yarn dev`, else skip) — skipped when absent
- **tests**: test command if detectable (`pnpm test`, `go test ./...`, `cargo test`) — else skip
- **infra**: `docker compose ps` if a compose file exists, else a plain shell
- **ai**: `claude`
Re-running `dev` in the same repo **re-attaches** the existing session instead of duplicating.

Detection rules:
- `package.json` → read scripts; prefer `pnpm` if `pnpm-lock.yaml`, else `npm`/`yarn` by lockfile.
- `go.mod` → `go run ./...` / `go test ./...`.
- `Cargo.toml` → `cargo run` / `cargo test`.
- none of the above → editor + ai windows only.

**Interface:** `dev` from any directory. **Depends on:** tmux, the detected toolchain.

## Keymap namespaces

`<leader>` = space, on top of LazyVim defaults (we only bind keys LazyVim leaves free):
`f` find · `g` git · `a` AI · `t` test · `d` debug · `x` diagnostics · `r` rest · `D` database.

## Data flow

1. `dev` (shell) → spawns tmux session/windows → `nvim` in editor window.
2. nvim → lazy.nvim loads plugin specs lazily by event/key/ft → Mason ensures tools present.
3. LSP/formatters/DAP/neotest talk to language toolchains on disk.
4. CodeCompanion → ACP → Claude Code CLI → Claude (subscription auth).
5. tmux-resurrect/continuum persist session layout across reboots.

## Error handling

- `install.sh`: refuse to overwrite without backup; abort with clear message if deps unmet.
- Missing language toolchain: Mason installs what it can; LSPs for absent runtimes simply
  stay inactive (no crash).
- No `CLAUDE_CODE_OAUTH_TOKEN`: CodeCompanion loads but AI requests error with a clear
  prompt to run `claude setup-token`; rest of the IDE is unaffected.
- `dev` in a non-project dir: still opens editor + ai windows.

## Testing / verification

- `nvim --headless "+Lazy! sync" +qa` — plugin specs resolve and install cleanly.
- `nvim --headless "+checkhealth" +qa` — no critical health errors.
- `tmux -f tmux/.tmux.conf new -d -s smoke` then kill — config parses.
- Manual: `dev` in a pnpm repo opens the expected windows; `dev` in an empty dir opens
  editor + ai only; re-running re-attaches.
- `<leader>aa` opens a CodeCompanion chat that reaches Claude after `claude setup-token`.

## Out of scope (YAGNI)

Avante; a second completion engine; permanent sidebar file tree (oil + telescope only);
multiple colorschemes; Jira/Confluence MCP (can add later via CodeCompanion MCP config).

## Open follow-ups (post-MVP)

- Push the repo to GitHub.
- Optional: wire MCP servers (GitHub, Postgres) into CodeCompanion.
- Optional: per-project `.dev` override file for custom launcher commands.
