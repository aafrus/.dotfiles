# --------------------------------------------
# Completion System Configuration
# --------------------------------------------

# Initialize completion system
autoload -Uz compinit && compinit

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

# FZF-tab previews
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

#kubectl completion
source <(kubectl completion zsh)

#minikube completion
source <(minikube completion zsh)

#no emoji
export MINIKUBE_IN_STYLE=false
