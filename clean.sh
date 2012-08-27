#!/usr/bin/env bash

sudo rm -rd Build/ DerivedData/

pushd $PWD
    cd git_osx_installer
    git clean -fd
    sudo rm -rd git_build/
popd

pushd $PWD
    cd node
    make clean
    git clean -fd
popd
