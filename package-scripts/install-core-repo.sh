#!/usr/bin/env bash --login

##########
# run it #
##########

resource_dir=/Applications/livelykernel-scripts.app/Contents/Resources
lkscripts_dir=$resource_dir/livelykernel-scripts
workspace_dir=$lkscripts_dir/workspace
corerepo_dest=$workspace_dir/lk
tmp_location=$DSTROOT # /tmp/livelykernel-scripts.app.core-repo

echo "Installing $INSTALL_PKG_SESSION_ID..."
echo "tmp_location: $tmp_location"

# remove old
if [[ -d $corerepo_dest ]]; then
    echo "core repo already esists at $corerepo_dest. Leaving it there..."
else
    # install new
    if [[ -d $lkscripts_dir ]]; then
        mkdir -p $workspace_dir
        mv $tmp_location $corerepo_dest
    else
        echo "no $lkscripts_dir exist. Won't install core repo"
        rm -rfd $tmp_location
    fi
fi

echo "Installing $INSTALL_PKG_SESSION_ID done"
