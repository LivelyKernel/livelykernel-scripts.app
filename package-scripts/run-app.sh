#!/usr/bin/env bash --login

# important to not be in install directory, jsDAV throws some error when in
# "wrong" environment
export TMPDIR=
cd $HOME
open /Applications/livelykernel-scripts.app
