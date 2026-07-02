# dotfiles

Personal macOS configuration, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

The repo is cloned to `~/dotfiles`. The stow packages live at the root (so they
link straight into `$HOME`); all provisioning tooling lives under `setup/`.

```
~/dotfiles/
├── git/  nvim/  tmux/  vim/  zsh/   ← stow packages (the dotfiles)
└── setup/
    ├── install.sh                  ← new-machine bootstrap
    ├── Brewfile                    ← brew formulae + casks (`brew bundle`)
    ├── Makefile                    ← convenience targets
    ├── iterm2/                     ← iTerm2 prefs (custom-folder)
    └── vscode/                     ← VSCode settings + extension list
```

Each package mirrors `$HOME`:

| Package | Contents |
|---------|----------|
| `git`   | `.gitconfig` (identity uses GitHub's noreply address, safe to commit) |
| `nvim`  | `.config/nvim` (lazy.nvim + lualine/bufferline statusline) |
| `tmux`  | `.tmux.conf` |
| `vim`   | `.vimrc`, `.vim/` |
| `zsh`   | `.zshrc`, `.zprofile`, `.zsh_aliases`, `.p10k.zsh` |

### Plugins

Plugins are **not** committed — the repo tracks only each tool's plugin list,
and `install.sh` triggers all three installers:

| Tool | Plugin list | Installer | Installs to |
|------|-------------|-----------|-------------|
| tmux | `@plugin` lines in `.tmux.conf` | [tpm](https://github.com/tmux-plugins/tpm) | `~/.tmux/plugins/` |
| vim  | `Plug` lines in `.vimrc` | vim-plug (committed) | `vim/.vim/plugged/` (git-ignored) |
| nvim | `lazy-lock.json` (pinned versions) | lazy.nvim (bootstraps itself) | `~/.local/share/nvim/lazy/` |

tmux plugins (catppuccin, cpu, battery) can also be managed from inside tmux:
`<prefix> + I` install, `<prefix> + U` update, `<prefix> + alt + u` remove unlisted.

### iTerm2 and VSCode (not stow packages)

**iTerm2** — settings live in `setup/iterm2/`, loaded via *Load settings from a
custom folder or URL* (`install.sh` sets this up). iTerm2 reads the folder on
launch and writes back on quit, so git picks up changes with no extra steps.

**VSCode** — its config dir (`~/Library/Application Support/Code/User/`) isn't
under `$HOME`'s dotfiles, so `install.sh` handles it directly:

- symlinks `setup/vscode/settings.json` into the config dir
- installs every extension listed in `setup/vscode/extensions.txt`

After installing/removing extensions, run `make code-refresh` and commit.

## Set up a new MacBook

```sh
git clone https://github.com/f-ionescu/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./setup/install.sh
```

`install.sh` is idempotent (safe to re-run) and will:

1. Install Xcode Command Line Tools (for `git`), Homebrew, and everything in
   `setup/Brewfile` — cloning this repo to `~/dotfiles` first if it isn't there
2. Symlink every package into `$HOME` with `stow`
3. Install Oh My Zsh + the `zsh-autosuggestions` / `zsh-syntax-highlighting`
   plugins (after stow, so the installer keeps the repo's `.zshrc`)
4. Install the tmux (tpm), vim (vim-plug), and neovim (lazy.nvim) plugins
5. Point iTerm2 at the versioned prefs folder; link VSCode settings and install
   its extensions
6. Set `zsh` as the default shell

## Manual steps after install

1. **Restart the terminal** — open a new tab (or `exec zsh`) so the new shell,
   `$PATH`, and Powerlevel10k prompt load. **Quit and reopen iTerm2** (⌘Q, not
   just the window): it only reads the custom prefs folder on launch.

2. **Nerd Font.** iTerm2 uses **`CodeNewRomanNFM`**. The Brewfile installs
   several Nerd Fonts to choose from (Code New Roman, CaskaydiaCove, Hasklug,
   Meslo LG); if the prompt or status bars show boxes/▯ instead of icons, pick
   one in iTerm2 → Settings → Profiles → Text → Font.

3. **Grant app permissions** (System Settings → Privacy & Security), required on
   first launch: **rcmd** and **Maccy** → *Accessibility*; **Shottr** → *Screen
   Recording*. Enable "Open at Login" for Maccy / rcmd if you want them always
   running.

4. **If plugins didn't install** (`install.sh` warns but keeps going): in tmux
   press `Ctrl-a + I` (the prefix is `Ctrl-a`; reload the config with
   `Ctrl-a + r`), in vim run `:PlugInstall`, in nvim run `:Lazy sync`.

5. **If the default shell wasn't set** (`chsh` was skipped, e.g. at the password
   prompt): `chsh -s "$(which zsh)"` and re-login.

6. **(Optional) Switch the git remote to SSH.** The repo is cloned over HTTPS so
   a keyless machine can bootstrap; to push, add an SSH key to GitHub and:
   ```sh
   git -C ~/dotfiles remote set-url origin git@github.com:f-ionescu/dotfiles.git
   ```

## Day-to-day

Run from the `setup/` directory:

```sh
cd ~/dotfiles/setup
make help          # list targets
make stow          # re-link packages after adding files
make brew          # install/update packages from the Brewfile
make brew-refresh  # regenerate the Brewfile from this machine — review & commit
make code-refresh  # refresh the VSCode extensions list — review & commit
make unstow        # remove all symlinks
```
