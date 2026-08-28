#!/usr/bin/env bash
# ============================================================================
# AwesomeVim installer
#
# One command install:
#   curl -fsSL https://raw.githubusercontent.com/PythonHacker24/awesomevim/main/install.sh | bash
#
# What it does:
#   1. checks base requirements (git, nvim, a C compiler)
#   2. clones the config into ~/.config/nvim (backs up any existing config)
#   3. bootstraps packer.nvim and installs all plugins headlessly
#   4. installs treesitter parsers
#   5. installs the pi coding agent CLI if npm is available
# ============================================================================

set -euo pipefail

REPO_URL="https://github.com/PythonHacker24/awesomevim.git"
NVIM_DIR="$HOME/.config/nvim"
UNDO_DIR="$HOME/.undodir"
PACKER_DIR="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"

info()  { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
ok()    { printf '\033[1;32m ok\033[0m %s\n' "$1"; }
fail()  { printf '\033[1;31mfail\033[0m %s\n' "$1"; exit 1; }

# ----------------------------------------------------------------- requirements
info "Checking requirements"

command -v git >/dev/null 2>&1 || fail "git is required"
ok "git"

command -v nvim >/dev/null 2>&1 || fail "neovim is required (0.10 or later)"
NVIM_VERSION=$(nvim --version | head -1 | sed 's/^NVIM v//')
ok "neovim $NVIM_VERSION"

if command -v gcc >/dev/null 2>&1 || command -v clang >/dev/null 2>&1 || command -v cc >/dev/null 2>&1; then
    ok "C compiler (for treesitter parsers)"
else
    fail "no C compiler found, install gcc or clang"
fi

# ----------------------------------------------------------------------- config
info "Installing config"

mkdir -p "$UNDO_DIR"
ok "undo directory: $UNDO_DIR"

if [ -d "$NVIM_DIR/.git" ] && git -C "$NVIM_DIR" remote get-url origin 2>/dev/null | grep -q "awesomevim"; then
    ok "config already present at $NVIM_DIR, pulling latest"
    git -C "$NVIM_DIR" pull --ff-only || true
else
    if [ -d "$NVIM_DIR" ]; then
        BACKUP="$NVIM_DIR.backup.$(date +%Y%m%d%H%M%S)"
        info "Existing config found, backing up to $BACKUP"
        mv "$NVIM_DIR" "$BACKUP"
    fi
    git clone --depth 1 "$REPO_URL" "$NVIM_DIR"
    ok "cloned into $NVIM_DIR"
fi

# ----------------------------------------------------------------------- packer
info "Bootstrapping packer.nvim"

if [ ! -d "$PACKER_DIR" ]; then
    git clone --depth 1 https://github.com/wbthomason/packer.nvim "$PACKER_DIR"
fi
ok "packer.nvim"

info "Installing plugins (headless, this can take a minute)"
nvim --headless \
    -c "lua require('core.packer')" \
    -c "autocmd User PackerComplete quitall" \
    -c "PackerSync" || fail "plugin installation failed"
ok "plugins installed"

info "Compiling plugin loader"
nvim --headless \
    -c "lua require('core.packer')" \
    -c "autocmd User PackerCompileDone quitall" \
    -c "PackerCompile" >/dev/null 2>&1 || true
ok "packer compiled"

# ------------------------------------------------------------------- treesitter
info "Installing treesitter parsers"
nvim --headless \
    "+TSInstallSync markdown markdown_inline lua vim vimdoc query bash json" \
    +qa >/dev/null 2>&1 || true
ok "treesitter parsers"

# --------------------------------------------------------------------------- pi
info "Checking pi coding agent"
if command -v pi >/dev/null 2>&1; then
    ok "pi $(pi --version 2>/dev/null || echo installed)"
elif command -v npm >/dev/null 2>&1; then
    info "Installing pi CLI (npm install -g @earendil-works/pi-coding-agent)"
    npm install -g @earendil-works/pi-coding-agent \
        && ok "pi installed" \
        || info "pi install failed, install manually: npm install -g @earendil-works/pi-coding-agent"
else
    info "npm not found. To use the agent sidebar, install Node.js and run:"
    info "  npm install -g @earendil-works/pi-coding-agent"
fi

echo
ok "AwesomeVim installed. Start it with: nvim"
info "Agent sidebar: <Space>aa   Find files: <Space><Space>   Terminal: Ctrl-\\"
