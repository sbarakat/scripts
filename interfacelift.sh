#!/bin/bash

#
# Author: Sami Barakat <sami@sbarakat.co.uk>
# Date: 26/09/2010
#
# Shell script to download the latest image, in 1080p, from interfacelift.com
# then sets the desktop background. Adding this script to /etc/cron.daily/ will
# give you a cool new wallpaper every day. Looks awesome on a huge telly.
#
#
# Still has a few issues...
#
# Run on network connection - does not work, but this is what I tried
#
# Add this to /etc/interfaces then pop the file into /etc/network/if-up.d/
#auto eth0
#iface eth0 inet dhcp
#post-up /etc/network/if-up.d/interfacelift.sh


# Get the pid of nautilus
nautilus_pid=$(pgrep -u $LOGNAME -n nautilus)

# If nautilus isn't running, just exit silently
if [ -z "$nautilus_pid" ]; then
  exit 0
fi

# Grab the DBUS_SESSION_BUS_ADDRESS variable from nautilus's environment
eval $(tr '\0' '\n' < /proc/$nautilus_pid/environ | grep '^DBUS_SESSION_BUS_ADDRESS=')

# Check that we actually found it
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
  echo "Failed to find bus address" >&2
  exit 1
fi

# export it so that child processes will inherit it
export DBUS_SESSION_BUS_ADDRESS


# get latest image
imgpath=`wget -qO- --user-agent="Firefox/3.8" "http://interfacelift.com/wallpaper_beta/downloads/date/hdtv/1080p/" | grep 'download.png' | sed 's/.*href="\([^"]*\)".*/\1/g' | head -n 1`;
img=`basename $imgpath`;

# download the image if its different than the current one
cd /tmp;
if [ ! -f "/tmp/$img" ]; then
  wget -q --user-agent="Firefox/3.8" "http://interfacelift.com/$imgpath";
  gconftool-2 -t string -s /desktop/gnome/background/picture_filename "/tmp/$img";
  #echo "su - media && gconftool-2 -t string -s /desktop/gnome/background/picture_filename '/tmp/$img'" | at now + 3 minutes
  #echo "su - media && gconftool-2 -t string -s /desktop/gnome/background/picture_filename '/tmp/$img'" > /home/media/echooin
fi
