# ░▀▀█░█▀▀░█░█░░
# ░▄▀░░▀▀█░█▀█░░
# ░▀▀▀░▀▀▀░▀░▀░░

# set hostname
HOSTNAME=$(hostname -s)

# load configs
for config (~/.config/zsh/*.zsh) source $config

setopt auto_cd

export PATH=$PATH:/home/ns/bin:/home/ns/.local/bin

source ~/.config/zsh/meridian.zsh
