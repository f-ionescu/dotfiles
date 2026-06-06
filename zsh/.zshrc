# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting z aws kube-ps1)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
source ~/powerlevel10k/powerlevel10k.zsh-theme
source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Enable Powerline
if [ -f /usr/share/powerline/bindings/bash/powerline.sh ]; then
source /usr/share/powerline/bindings/bash/powerline.sh
fi

# Enable Kube-PS1
source /opt/homebrew/opt/kube-ps1/share/kube-ps1.sh
PROMPT='$(kube-ps1)'$PROMPT

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Display fzf in a smaller box
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Enable key timeout for vi-mode
export KEYTIMEOUT=1

#Store only successfully completed commands to history
zshaddhistory() { whence ${${(z)1}[1]} >| /dev/null || return 1 }

#Ignore zsh_history duplicates
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY

# For Powerline
export PATH=$PATH:$HOME/Library/Python/3.9/bin

# Source files
source $HOME/.zsh_aliases

# Valeo Tunnel
proxy-on() {
  export HTTP_PROXY=socks5://127.0.0.1:7900
  export HTTPS_PROXY=$HTTP_PROXY
  printf "PROXY:\033[32mON\033[0m\n"
}

proxy-off() {
  unset HTTP_PROXY
  unset HTTPS_PROXY
  printf "PROXY:\033[31mOFF\033[0m\n"
}

# Returns colored status for tunnel
tunnel_status() {
  local label=TUN
  if command -v nc >/dev/null 2>&1 && nc -z -w1 127.0.0.1 7900 >/dev/null 2>&1; then
    # port is open
    echo "%F{green}$label%f"
  elif command -v networksetup >/dev/null 2>&1; then
    # port closed but DNS non-empty
    local svc=$(tunnel-network-service)
    local dns=$(networksetup -getdnsservers "$svc" 2>&1)
    if [[ $dns != *"There aren"* ]]; then
      echo "%F{yellow}$label%f"
    else
      echo "%F{red}$label%f"
    fi
  else
    # neither
    echo "%F{red}$label%f"
  fi
}

# Returns colored status for proxy
proxy_status() {
  local label=PRX
  if [[ -n $HTTP_PROXY || -n $HTTPS_PROXY ]]; then
    echo "%F{green}$label%f"
  else
    echo "%F{red}$label%f"
  fi
}

alias tn1="tunnel-on"
alias tn0="tunnel-off"
alias tunnel-restart="tunnel-off; tunnel-on"
alias px0="proxy-off"
alias px1="proxy-on"

tunnel_restart_extra() {
  if env | grep -q "PROXY"; then
    PROXY_WAS_ON=true
    echo "Proxy ENV was true, will be set to true again after restart"
    proxy-off
  else
    PROXY_WAS_ON=false
    echo "Proxy ENV was false, will be left as false"
  fi

  tunnel-restart

  if [ "$PROXY_WAS_ON" = true ]; then
    echo "Restoring proxy settings..."
    px1
  else
    echo "Proxy will remain OFF."
  fi
}
alias tnr="tunnel_restart_extra"


# Jump between words
bindkey "\e[1;3D" backward-word
bindkey "\e[1;3C" forward-word
bindkey "^[[1;9D" beginning-of-line
bindkey "^[[1;9C" end-of-line
export PATH="$HOME/.local/bin:$PATH"

# Export KUBECONFIG
kcfg() {
  local kubeconfig_dir=~/work/kubeconfig

  export KUBECONFIG
  KUBECONFIG="$kubeconfig_dir/$(ls "$kubeconfig_dir" | fzf --prompt="KUBECONFIG> " --height=25 --border)"
  [[ -z "$KUBECONFIG" ]] && echo "No KUBECONFIG selected." && return 1
  echo "KUBECONFIG set to: $KUBECONFIG"
}

# Auto ls when changing directories
#chpwd() {
#  if [[ -o interactive ]]; then
#    ls -lh --color=auto
#  fi
#}
