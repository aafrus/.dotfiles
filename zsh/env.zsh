# --------------------------------------------
# Environment Variables
# --------------------------------------------

# Core
export EDITOR='nvim'
export VISUAL='nvim'
export TERM='xterm-256color'
export TERMINAL='urxvtc'

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# PATH
if [[ -d "$HOME/.local/bin" && ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Git
export GITFLOW_MAIN_BRANCH=main
export GITFLOW_DEVELOP_BRANCH=develop
