# dotfiles — convenience targets (run from the repo root: `make <target>`)

DOTFILES := $(HOME)/dotfiles
SETUP    := $(DOTFILES)/setup
PACKAGES := git nvim tmux vim zsh

# stow operates on packages at the repo root, linking into $HOME
STOW := stow --dir=$(DOTFILES) --target=$(HOME)

CODE := $(shell command -v code 2>/dev/null || echo "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code")

.PHONY: help install brew stow unstow brew-refresh code-refresh

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-13s\033[0m %s\n", $$1, $$2}'

install: ## Full bootstrap on a new machine
	$(SETUP)/install.sh

brew: ## Install everything from the Brewfile
	brew bundle --file=$(SETUP)/Brewfile

stow: ## Symlink all packages into $HOME
	$(STOW) --restow $(PACKAGES)

unstow: ## Remove all symlinks from $HOME
	$(STOW) --delete $(PACKAGES)

brew-refresh: ## Regenerate the Brewfile from what's installed on this machine
	brew bundle dump --file=$(SETUP)/Brewfile --force
	@echo "Brewfile updated — review & commit."

code-refresh: ## Regenerate the VSCode extensions list from this machine
	"$(CODE)" --list-extensions > $(SETUP)/vscode/extensions.txt
	@echo "vscode/extensions.txt updated — review & commit."
