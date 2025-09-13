#!/usr/bin/env zsh

source ~/.dotfiles/zsh/env.zsh

# [2] Setup function path
    fpath=( ~/.dotfiles/zsh/functions "${fpath[@]}" )
    autoload -Uz git_current_branch c ddg

# [3] Load other configs
for config in ~/.dotfiles/zsh/*.zsh; do
  [[ "$config" == *"env.zsh" ]] && continue
  [[ "$config" == *"alias.zsh" ]] && continue
  [[ "$config" == *".zprofile" ]] && continue
  [[ "$config" == *".zshrc" ]] && continue
  source "$config"
done

# [4] Load aliases LAST
source ~/.dotfiles/zsh/alias.zsh
