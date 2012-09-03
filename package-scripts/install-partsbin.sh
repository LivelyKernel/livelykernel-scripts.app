#!/usr/bin/env bash --login

##########
# run it #
##########

resource_dir=/Applications/livelykernel-scripts.app/Contents/Resources
lkscripts_dir=$resource_dir/livelykernel-scripts
workspace_dir=$lkscripts_dir/workspace
partsbin_dest=$workspace_dir/PartsBin
tmp_location=$DSTROOT # /tmp/livelykernel-scripts.app.PartsBin

echo "Installing $INSTALL_PKG_SESSION_ID..."
echo "tmp_location: $tmp_location"

if [[ -d partsbin_dest ]]; then
    echo "PartsBin already esists at $partsbin_dest. Leaving it there..."
else
    if [[ -d $lkscripts_dir ]]; then
        mkdir -p $workspace_dir
        mv $tmp_location $partsbin_dest
        if [[ -d $workspace_dir/lk ]]; then
            ln -s $partsbin_dest $workspace_dir/lk/PartsBin
        fi
    else
        echo "no $lkscripts_dir exist. Won't install PartsBin"
        rm -rfd $tmp_location
    fi
fi

echo "Installing $INSTALL_PKG_SESSION_ID done"
