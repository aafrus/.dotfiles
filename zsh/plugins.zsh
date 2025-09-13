# --------------------------------------------
# Plugin Manager Configuration
# Uses Zinit to load plugins
# --------------------------------------------

# Initialize Zinit
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# --------------------------------------------
# Essential Plugins
# --------------------------------------------

# Syntax highlighting
zinit light zsh-users/zsh-syntax-highlighting

# Auto-suggestions
zinit light zsh-users/zsh-autosuggestions

# Better completion
zinit light zsh-users/zsh-completions

# FZF integration
zinit light Aloxaf/fzf-tab

# --------------------------------------------
# Oh My Zsh Snippets
# --------------------------------------------

#zinit snippet OMZP::git
zinit snippet OMZP::sudo

# --------------------------------------------
# Tools Initialization
# --------------------------------------------

# FZF shell integration (without bindings)
(( ${+commands[fzf]} )) && eval "$(fzf --zsh)"

# Zoxide initialization
(( ${+commands[zoxide]} )) && eval "$(zoxide init --cmd cd zsh)"

# Finalize Zinit
zinit compile --all &>/dev/null