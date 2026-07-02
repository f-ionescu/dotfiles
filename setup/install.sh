#!/usr/bin/env bash
#
# install.sh - bootstrap a fresh macOS machine from this dotfiles repo.
#
# Safe to re-run (idempotent): it skips anything already installed/linked.
#
# Usage:
#   git clone https://github.com/f-ionescu/dotfiles.git ~/dotfiles
#   cd ~/dotfiles && ./setup/install.sh
#
# Or one-liner on a brand new machine (installs git via Xcode CLT first):
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/f-ionescu/dotfiles/main/setup/install.sh)"

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
REPO_URL="https://github.com/f-ionescu/dotfiles.git"
STOW_PACKAGES=(git nvim tmux vim zsh)
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Oh My Zsh custom plugins referenced by zsh/.zshrc (plugins=(...)).
# Format: "name|repo_url"
OMZ_PLUGINS=(
  "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions"
  "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting"
)

# ----- pretty logging --------------------------------------------------------
info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m  +\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  !\033[0m %s\n' "$*"; }

# ----- 1. Xcode Command Line Tools (provides git) ----------------------------
install_xcode_clt() {
  if xcode-select -p >/dev/null 2>&1; then
    ok "Xcode Command Line Tools already installed"
    return
  fi
  info "Installing Xcode Command Line Tools (a dialog will appear)..."
  xcode-select --install || true
  until xcode-select -p >/dev/null 2>&1; do
    sleep 5
  done
  ok "Xcode Command Line Tools installed"
}

# ----- 2. Homebrew -----------------------------------------------------------
install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    ok "Homebrew already installed"
  else
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # Make brew available in this shell (Apple Silicon path).
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

# ----- 3. Clone (or update) the dotfiles repo --------------------------------
clone_dotfiles() {
  if [[ -d "$DOTFILES_DIR/.git" ]]; then
    ok "dotfiles repo present at $DOTFILES_DIR"
  else
    info "Cloning dotfiles into $DOTFILES_DIR..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
  fi
}

# ----- 4. Install everything from the Brewfile -------------------------------
brew_bundle() {
  info "Installing packages from Brewfile..."
  brew bundle --file="$DOTFILES_DIR/setup/Brewfile"
  ok "brew bundle complete"
}

# ----- 6. Oh My Zsh + custom plugins -----------------------------------------
# Must run AFTER stow: with no ~/.zshrc present, the OMZ installer creates one
# from its template (KEEP_ZSHRC=yes only preserves an existing file), and that
# real file would then make `stow zsh` fail with a conflict.
install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    ok "Oh My Zsh already installed"
  else
    info "Installing Oh My Zsh..."
    # --unattended: don't change shell or start zsh; we handle that ourselves.
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  for entry in "${OMZ_PLUGINS[@]}"; do
    local name="${entry%%|*}" url="${entry##*|}"
    local dest="$ZSH_CUSTOM/plugins/$name"
    if [[ -d "$dest" ]]; then
      ok "omz plugin $name present"
    else
      info "Cloning omz plugin $name..."
      git clone --depth=1 "$url" "$dest"
    fi
  done
}

# ----- 5. Symlink dotfiles with GNU Stow -------------------------------------
stow_dotfiles() {
  info "Stowing dotfiles -> \$HOME..."
  cd "$DOTFILES_DIR"
  for pkg in "${STOW_PACKAGES[@]}"; do
    stow --restow --target="$HOME" "$pkg"
    ok "stowed $pkg"
  done
}

# ----- 7. Install tmux plugin manager (tpm) ----------------------------------
# https://github.com/tmux-plugins/tpm
install_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"
  if [[ -f "$tpm_dir/tpm" ]]; then
    ok "tpm already installed"
  else
    info "Installing tmux plugin manager (tpm)..."
    mkdir -p "$(dirname "$tpm_dir")"
    # A fresh dotfiles clone may leave an empty tpm/ dir; remove it if empty
    # so the clone lands cleanly.
    [[ -d "$tpm_dir" && -z "$(ls -A "$tpm_dir" 2>/dev/null)" ]] && rmdir "$tpm_dir"
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  fi
  # Install the plugins declared in ~/.tmux.conf (catppuccin, cpu, battery...).
  info "Installing tmux plugins via tpm..."
  "$tpm_dir/bin/install_plugins" \
    || warn "tpm install failed - open tmux and press <prefix> + I to retry"
}

# ----- 8. Install vim plugins (vim-plug ships in the repo; just :PlugInstall) -
install_vim_plugins() {
  if ! command -v vim >/dev/null 2>&1; then
    warn "vim not found - skipping plugin install"
    return
  fi
  info "Installing vim plugins (airline, fzf, ...) via vim-plug..."
  vim -E -s +PlugInstall +qall </dev/null >/dev/null 2>&1 \
    || warn "vim :PlugInstall reported issues - open vim and run :PlugInstall"
  ok "vim plugins installed"

  if command -v nvim >/dev/null 2>&1; then
    info "Installing neovim plugins (lazy.nvim bootstraps itself)..."
    nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 \
      || warn "nvim plugin sync reported issues - open nvim and run :Lazy sync"
    ok "neovim plugins installed"
  fi
}

# ----- 9. Point iTerm2 at the versioned prefs folder -------------------------
configure_iterm2() {
  local prefs_dir="$DOTFILES_DIR/setup/iterm2"
  if [[ ! -f "$prefs_dir/com.googlecode.iterm2.plist" ]]; then
    warn "No iTerm2 prefs in repo - skipping"
    return
  fi
  info "Pointing iTerm2 at $prefs_dir..."
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$prefs_dir"
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
  ok "iTerm2 will load prefs from the repo on next launch"
}

# ----- 10. VSCode: symlink settings + install extensions ---------------------
configure_vscode() {
  local src="$DOTFILES_DIR/setup/vscode"
  local userdir="$HOME/Library/Application Support/Code/User"
  [[ -d "$src" ]] || { warn "No VSCode config in repo - skipping"; return; }

  mkdir -p "$userdir"
  # Symlink settings/keybindings, backing up any pre-existing real file once.
  local f
  for f in settings.json keybindings.json; do
    [[ -f "$src/$f" ]] || continue
    if [[ -e "$userdir/$f" && ! -L "$userdir/$f" ]]; then
      mv "$userdir/$f" "$userdir/$f.bak"
      warn "backed up existing VSCode $f to $f.bak"
    fi
    ln -sfn "$src/$f" "$userdir/$f"
    ok "linked VSCode $f"
  done

  # Resolve the code CLI (on PATH after the brew cask install, else app bundle).
  local code=""
  if command -v code >/dev/null 2>&1; then
    code="code"
  elif [[ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
    code="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
  fi
  if [[ -z "$code" ]]; then
    warn "code CLI not found - skipping extensions (in VSCode run: Shell Command: Install 'code' command in PATH)"
    return
  fi
  if [[ -f "$src/extensions.txt" ]]; then
    info "Installing VSCode extensions (vscode-icons, ...)..."
    local ext
    while read -r ext; do
      [[ -z "$ext" || "$ext" == \#* ]] && continue
      "$code" --install-extension "$ext" --force >/dev/null 2>&1 \
        && ok "ext $ext" || warn "ext $ext failed"
    done < "$src/extensions.txt"
  fi
}

main() {
  install_xcode_clt
  install_homebrew
  clone_dotfiles
  brew_bundle
  stow_dotfiles
  install_oh_my_zsh
  install_tpm
  install_vim_plugins
  configure_iterm2
  configure_vscode

  printf '\n'
  ok "Done! Open a new terminal (or run: exec zsh) to load your setup."
  warn "Run 'p10k configure' only if you want to redo the prompt."
}

main "$@"
