#!/usr/bin/env zsh

source ~/.dotfiles/zsh/env.zsh

# [2] Setup function path and autoload all functions within it
fpath=( ~/.dotfiles/zsh/functions "${fpath[@]}" )

# Automatically find all function files and tell autoload about them
for func_file in ~/.dotfiles/zsh/functions/*(N); do
  autoload -Uz ${func_file:t}
done
unset func_file

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

. "$HOME/.cargo/env"