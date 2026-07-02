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

### Not in stow

**iTerm2** settings live in `setup/iterm2/`.
iTerm2 reads the folder on launch and writes back on quit, so git picks up changes with no extra steps.

**VSCode** config dir is `~/Library/Application Support/Code/User/`
- symlinks `setup/vscode/settings.json` into the config dir
- installs every extension listed in `setup/vscode/extensions.txt`

After installing/removing extensions, run `make code-refresh` and commit.

## Set up a new MacBook

```sh
git clone https://github.com/f-ionescu/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./setup/install.sh
```

`install.sh` is idempotent (safe to re-run) and will:

1. Install Xcode Command Line Tools (for `git`), Homebrew, and everything in `setup/Brewfile`
2. Symlink every package into `$HOME` with `stow`
3. Install Oh My Zsh + the `zsh-autosuggestions` / `zsh-syntax-highlighting` plugins after stow
4. Install the tmux (tpm), vim (vim-plug), and neovim (lazy.nvim) plugins
5. Point iTerm2 at the versioned prefs folder
6. Link VSCode settings and install its extensions

## After the install

Three quick things on every fresh machine:

1. **Restart the terminal** — open a new tab (or `exec zsh`) so the new shell, `$PATH`, and Powerlevel10k prompt load. Quit and reopen iTerm2 ⌘Q
2. **Check the font**
   If the prompt or status bars show boxes/▯ instead of icons, pick any installed Nerd Fonts
3. **Grant app permissions**
   System Settings → Privacy & Security:
    - Accessibility
    - Screen Recording

### If something didn't stick

`install.sh` warns but keeps going, so any failures land here:

| Symptom | Fix |
|---------|-----|
| tmux status bar not themed | inside tmux: `Ctrl-a + I` |
| vim has no statusline | in vim: `:PlugInstall` |
| nvim plugins missing | in nvim: `:Lazy sync` |

### Optional

Switch the remote to ssh to push changes:
https is only there for the keyles first clone
add an ssh key to github, then:

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
