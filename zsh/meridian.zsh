# Meridian 
# TTY colors

if [ "$TERM" = "linux" ]; then
    echo -en "\e]P01e1e1e" # black
    echo -en "\e]P8585858" # darkgrey
    echo -en "\e]P19c353e" # darkred
    echo -en "\e]P9b44c4f" # red
    echo -en "\e]P27c6f5e" # darkgreen
    echo -en "\e]PA9e9e9e" # green
    echo -en "\e]P3d1b57d" # yellow
    echo -en "\e]PBe2c28f" # light yellow/orange
    echo -en "\e]P43a3a3a" # darkblue
    echo -en "\e]PC6a8c9a" # blue
    echo -en "\e]P59c353e" # darkmagenta
    echo -en "\e]PDb44c4f" # magenta
    echo -en "\e]P65e6b6b" # darkcyan
    echo -en "\e]PE7a8a8a" # cyan
    echo -en "\e]P7d0d0d0" # lightgrey
    echo -en "\e]PFf5f5f5" # white
    clear # for background artifacting
fi
