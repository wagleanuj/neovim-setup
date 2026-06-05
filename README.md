# neovim-setup — Terminal IDE

LazyVim + tmux + Claude Code. Version-controlled dotfiles, installed via symlinks.

## Install

```bash
git clone <this-repo> ~/Documents/Projects/neovim-setup
cd ~/Documents/Projects/neovim-setup
./install.sh
```

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

## AI auth (one-time)

CodeCompanion uses your Claude subscription via the Claude Code CLI. Generate a token once:

```bash
claude setup-token
```

Then export it in your shell profile (`~/.zshrc`):

```bash
export CLAUDE_CODE_OAUTH_TOKEN="<token-from-setup-token>"
```

The tmux `ai` pane runs `claude` directly and uses your normal login — no token needed there.
