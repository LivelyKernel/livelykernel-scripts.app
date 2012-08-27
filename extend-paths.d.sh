#!/usr/bin/env bash

if [[ "$INSTALL_PKG_SESSION_ID" =~ ".*git.pkg" ]]; then
    pathdcontent="/Applications/"
    pathdfile="livelykernel-scripts-git"
elif [[ "$INSTALL_PKG_SESSION_ID" =~ ".*node.pkg" ]]; then
    echo 2
    pathdfile="livelykernel-scripts-node"
elif [[ "$INSTALL_PKG_SESSION_ID" =~ ".*livelykernel-scripts.pkg" ]]; then
    pathdcontent="$HOME/node_modules/livelykernel-scripts/bin"
    pathdfile="livelykernel-scripts"
fi

echo "in $0" >> ~/packagetest.log
env >> ~/packagetest.log

echo "pathdcontent: $pathdcontent" >> ~/packagetest.log
echo "pathdfile: $pathdfile" >> ~/packagetest.log

# echo "writing to /etc/paths.d..." >> ~/packagetest.log
# echo "/test/foo" > /etc/paths.d/package-test
# echo "...done" >> ~/packagetest.log
# echo "" >> ~/packagetest.log
