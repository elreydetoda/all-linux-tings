#!/bin/sh

xrandr --auto

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

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# used for making battery life extend more
xset +dpms
xset dpms 0 0 300
sudo powertop --auto-tune &

# used for background pictures...as you can see...
feh --randomize --bg-fill /home/$USER/pictures/backgroud-pics/*

# used for ensuring the user knows the batter is close to dying
/home/$USER/scripts/lowbat.sh &

# enable logging to go to a var dir for i3wm
exec i3 -V >> /var/log/i3wm/i3log-$(date +'%F-%k:%M:%S') 2>&1
