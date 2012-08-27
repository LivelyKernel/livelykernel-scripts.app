#!/usr/bin/env bash

if [[ $INSTALL_PKG_SESSION_ID == *git.pkg ]]; then
    pathdcontent=$DSTROOT/bin # /Applications/livelykernel-scripts.app/Contents/Resources/git
    pathdfile="livelykernel-scripts-git"
elif [[ $INSTALL_PKG_SESSION_ID == *node.pkg ]]; then
    pathdcontent=$DSTROOT/bin
    pathdfile="livelykernel-scripts-node"
elif [[ $INSTALL_PKG_SESSION_ID == *livelykernel-scripts.pkg ]]; then
    appdir=$DSTROOT # /Applications/livelykernel-scripts.app/Contents/Resources/livelykernel-scripts
    userdir=$HOME/node_modules/livelykernel-scripts
    mkdir -p $HOME/node_modules
    ln -sF $appdir $userdir
    pathdcontent=$userdir/bin
    pathdfile="livelykernel-scripts"
fi

# extending PATH
[[ -n $pathdfile ]] && echo $pathdcontent > /etc/paths.d/$pathdfile

