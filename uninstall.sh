#!/usr/bin/env bash

lk_app=/Applications/livelykernel-scripts.app

# 1)
echo "removing paths.d entries `ls /etc/paths.d/livelykernel-scripts*`"
sudo rm /etc/paths.d/livelykernel-scripts*

# 2)
lk_app_dir="$lk_app/Contents/Resources/livelykernel-scripts"
home_link=$HOME/node_modules/livelykernel-scripts
if [[ $lk_app_dir = `readlink $home_link` ]]; then
    echo "removing link: $home_link"
    rm $home_link
fi

# 3)
if [[ -d $lk_app ]]; then
    echo "removing $lk_app"
    rm -rfd $lk_app
fi
