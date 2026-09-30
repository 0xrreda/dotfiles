# ─── Environment ──────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"

# ─── bat ──────────────────────────────────────────────────────
export BAT_THEME="ansi"                                   # uses your Kitty OldWorld colors
export MANPAGER="sh -c 'col -bx | bat -l man -p'"         # colored man pages
export MANROFFOPT="-c"

# ─── Zinit ────────────────────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# ─── Keymap + options ─────────────────────────────────────────
bindkey -e
setopt auto_cd interactive_comments no_beep

# ─── History ──────────────────────────────────────────────────
HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history
setopt append_history share_history
setopt hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_find_no_dups hist_reduce_blanks

# ─── Completions (before compinit) ────────────────────────────
zinit ice depth=1; zinit light zsh-users/zsh-completions
zinit snippet OMZP::git
zinit snippet OMZP::command-not-found

# ─── Compinit ─────────────────────────────────────────────────
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
zinit cdreplay -q

# ─── Completion styling ───────────────────────────────────────
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-flags \
  --color=bg+:#27272a,bg:#161617,fg:#c9c7cd,fg+:#c9c7cd,hl:#ea83a5,hl+:#ea83a5 \
  --color=info:#e6b99d,prompt:#aca1cf,pointer:#9ca2cf,marker:#90b99f,header:#85b5ba
zstyle ':fzf-tab:complete:cd:*'         fzf-preview 'eza -1 --color=always --icons=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons=always $realpath'
zstyle ':fzf-tab:complete:(cat|bat|nvim|n|vim|less):*' fzf-preview \
  '[[ -d $realpath ]] && eza -1 --color=always --icons=always $realpath || bat --color=always --style=numbers --line-range=:200 $realpath'

# ─── fzf (BEFORE fzf-tab, so fzf-tab owns Tab) ───────────────
source <(fzf --zsh)
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border \
--color=bg+:#27272a,bg:#161617,fg:#c9c7cd,fg+:#c9c7cd,hl:#ea83a5,hl+:#ea83a5 \
--color=info:#e6b99d,prompt:#aca1cf,pointer:#9ca2cf,marker:#90b99f,spinner:#85b5ba,header:#85b5ba,border:#353539"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons=always {}'"

# ─── fzf-tab (after compinit + fzf, before widget plugins) ───
zinit ice depth=1; zinit light Aloxaf/fzf-tab

# ─── Suggestions + highlighting (syntax-highlighting LAST) ───
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#57575f"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
zinit ice depth=1; zinit light zsh-users/zsh-autosuggestions
zinit ice depth=1; zinit light zsh-users/zsh-syntax-highlighting

# ─── Keybindings ──────────────────────────────────────────────
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[[A' history-search-backward   # Up arrow
bindkey '^[OA' history-search-backward   # Up arrow (app mode)
bindkey '^[[B' history-search-forward    # Down arrow
bindkey '^[OB' history-search-forward    # Down arrow (app mode)
bindkey '^ ' autosuggest-accept          # Ctrl+Space

# ─── Aliases ──────────────────────────────────────────────────
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

alias c='clear'
alias n='nvim'
alias cat='bat --paging=never'
alias ls='eza --icons -la'
alias lt='eza -l --icons --tree --level=2'
alias lzg='lazygit'

# ─── Prompt + zoxide (zoxide LAST) ───────────────────────────
eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"
