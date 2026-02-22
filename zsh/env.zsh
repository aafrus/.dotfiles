# --------------------------------------------
# Environment Variables
# --------------------------------------------

# Core
export EDITOR='nvim'
export VISUAL='nvim'
export TERM='xterm-256color'
export TERMINAL='wezterm'

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# PATH
if [[ -d "$HOME/.local/bin" && ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# SSH Agent
export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
if ! ssh-add -l &>/dev/null; then
    rm -f "$SSH_AUTH_SOCK"
    ssh-agent -a "$SSH_AUTH_SOCK" > /dev/null 2>&1
    for _key in "$HOME/.ssh/keys/personal" "$HOME/.ssh/keys/homelab"; do
        [[ -f "$_key" ]] && ssh-add "$_key" 2>/dev/null || true
    done
    unset _key
fi

# Proton Pass CLI
export PROTON_PASS_KEY_PROVIDER=env
if [[ -f "$HOME/.config/local/proton-pass-key" ]]; then
    export PROTON_PASS_ENCRYPTION_KEY=$(cat "$HOME/.config/local/proton-pass-key")
fi

# Git
export GITFLOW_MAIN_BRANCH=main
export GITFLOW_DEVELOP_BRANCH=develop
