#!/usr/bin/env zsh
# ---[ Auto-start X11 ]----------------------------------
[[ -z $DISPLAY && -z $WAYLAND_DISPLAY && $XDG_VTNR -eq 1 ]] && exec sway

