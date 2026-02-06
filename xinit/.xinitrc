#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then







    xrdb -merge $sysresources

fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then







    xrdb -merge "$userresources"

fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

#wallpaper
#feh --bg-scale ~/hub/pictures/wall.jpg
xsetroot -solid '#000000'

#cursor
xsetroot -cursor_name left_ptr &
unclutter -idle 1 &

#load resources
xrdb -load ~/.config/urxvt/.Xdefaults
export TERMINAL='urxvtc'
#set monitor
xrandr --output eDP-1 --mode 1920x1080


#never sleep 
xset s off
xset -dpms
xset s noblank               

# synca PRIMARY -> CLIPBOARD 
while true; do clipnotify; xsel -o | xsel --clipboard -i; done &

clipmenud &

# start urxvtd
urxvtd -q -o -f

#start wm
exec herbstluftwm
