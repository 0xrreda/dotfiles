# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"


# Add in StarShip
eval "$(starship init zsh)"

# Shell integrations
# eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found
zinit snippet OMZP::docker

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Keybindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='eza --long --icons'
alias c='clear'
alias lzg='lazygit'
alias lzd='go run $HOME/www/lazydocker/main.go'
alias pf="fzf --preview 'bat --style=numbers --color=always {}'"
alias n='nvim'


kitty-reload() {
    kill -SIGUSR1 $(pidof kitty)
}

kitty-transparency() {
    echo "Do you want to enable transparent background? (y/n, default: n): "
    read -r transparency

    transparency="${transparency:-n}"

    if [[ "$transparency" =~ ^[Yy]$ ]]; then
        kitten @ set-background-opacity 0.9
    else
        kitten @ set-background-opacity 1
    fi
}

function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(bat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

grun() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: grun <file1[.c]> [file2[.c] ...]"
    return 1
  fi

  local sources=()
  for arg in "$@"; do
    [[ "$arg" != *.c ]] && arg="${arg}.c"
    if [[ ! -f "$arg" ]]; then
      echo "File not found: $arg"
      return 1
    fi
    sources+=("$arg")
  done

  local first_base="${sources[1]##*/}"
  first_base="${first_base%.c}"
  local output="out/${first_base}"

  mkdir -p out
  gcc "${sources[@]}" -o "$output" && "$output"
}

# bun completions
[ -s "/home/reda/.bun/_bun" ] && source "/home/reda/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="/home/reda/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH="/home/reda/.config/herd-lite/bin:$PATH"
export PHP_INI_SCAN_DIR="/home/reda/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"

export PATH="$HOME/.local/bin:$PATH"

