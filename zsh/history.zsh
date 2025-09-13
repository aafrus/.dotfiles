# --------------------------------------------
# History Configuration
# --------------------------------------------

# History file location
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=100000               # Max size in memory
SAVEHIST=100000               # Max size in history file

# History options
setopt EXTENDED_HISTORY       # Save timestamp and duration
setopt SHARE_HISTORY          # Share history between sessions
setopt HIST_IGNORE_ALL_DUPS   # Skip duplicates
setopt HIST_IGNORE_SPACE      # Skip commands starting with space
setopt INC_APPEND_HISTORY     # Append immediately, not on exit