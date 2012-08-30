#!/usr/bin/env bash --login

# important to not be in install directory, jsDAV throws some error when in
# "wrong" environment
export TMPDIR=
app=/Applications/livelykernel-scripts.app
cd $HOME
sudo chown -R $USER $app
open $app
