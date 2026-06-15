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

# cross-platform package install: brew (macOS) / apt / dnf / pacman (Linux).
# pkg names differ per manager, so map them. $1 = the command we probe for.
pkg_install() {
  local cmd="$1"
  local brew_pkg="$2" apt_pkg="$3" dnf_pkg="$4" pac_pkg="$5"
  if   command -v brew   >/dev/null 2>&1; then info "Installing $cmd via brew";   brew install "$brew_pkg"
  elif command -v apt-get>/dev/null 2>&1; then info "Installing $cmd via apt";    sudo apt-get install -y "$apt_pkg"
  elif command -v dnf    >/dev/null 2>&1; then info "Installing $cmd via dnf";    sudo dnf install -y "$dnf_pkg"
  elif command -v pacman >/dev/null 2>&1; then info "Installing $cmd via pacman"; sudo pacman -S --noconfirm "$pac_pkg"
  else warn "$cmd missing and no known package manager — install it manually"; fi
}

# tool        cmd         brew         apt          dnf          pacman
ensure_tool() {  # $1=cmd, rest=pkg names
  command -v "$1" >/dev/null 2>&1 || pkg_install "$@"
}
ensure_tool lazygit  lazygit     lazygit      lazygit      lazygit
ensure_tool fd       fd          fd-find      fd-find      fd
ensure_tool rg       ripgrep     ripgrep      ripgrep      ripgrep
# imagemagick powers inline image rendering (snacks.image); 'magick' is the binary
command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1 || \
  pkg_install imagemagick imagemagick imagemagick ImageMagick imagemagick

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
  1. Open `nvim` once — Mason will install LSPs/formatters/debuggers/linters.
  2. Run `claude` once and log in — the in-editor AI uses this login (no API key).
  3. In tmux, press  C-a  then  I  to install tmux plugins.
  4. Ensure your terminal uses a Nerd Font (for icons).
  5. From any project directory, run:  dev
NEXT
