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
