#!/usr/bin/env bash

lk_app=/Applications/livelykernel-scripts.app
lk_app_data_dir=~/Library/Application\ Support/livelykernel-scripts-macos

# 1)
echo "removing paths.d entries `ls /etc/paths.d/livelykernel-scripts*`"
sudo rm /etc/paths.d/livelykernel-scripts*

# 2)
lk_app_dir=$lk_app/Contents/Resources/livelykernel-scripts
home_link=$HOME/node_modules/livelykernel-scripts
if [ "$lk_app_dir" = "`readlink $home_link`" ]; then
    echo "removing link: $home_link"
    rm "$home_link"
fi

# 3)
if [ -d "$lk_app" ]; then
    echo "removing $lk_app"
    rm -rfd "$lk_app"
fi

# 4)
if [ -d "$lk_app_data_dir" ]; then
    echo "removing $lk_app_data_dir"
    rm -rd "$lk_app_data_dir"
fi
