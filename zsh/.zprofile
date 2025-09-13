#!/usr/bin/env zsh
# ---[ Auto-start X11 ]----------------------------------
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && startx

