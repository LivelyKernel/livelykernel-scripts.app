#!/bin/sh

#  prepare-dependencies.sh
#  livelykernel-scripts
#
#  Created by Robert Krahn on 8/26/12.
#  Copyright (c) 2012 LivelyKernel. All rights reserved.

mkdir -p dependencies/
rm -rfd dependencies/*

echo ""
echo "#######"
echo "# git #"
echo "#######"
pushd $PWD
    cd git_osx_installer
    ./build-for-lk-app.sh
    mv git ../dependencies/git
popd

echo ""
echo "########"
echo "# node #"
echo "########"
pushd $PWD
    cd node;
    export CC=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
    export CXX=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++
    ./configure --prefix=$PWD/node-build; make; make install
    # patch npm script so it uses the env node and not the fixed
    sed -i "" -e 's:^#.*:#!/usr/bin/env node:' node-build/lib/node_modules/npm/bin/npm-cli.js
    mv node-build ../dependencies/node
popd

echo ""
echo "########################"
echo "# livelykernel-scripts #"
echo "########################"
pushd $PWD
    cd lk-scripts
    # npm install
    CpMac -r . ../dependencies/livelykernel-scripts
    cd ../dependencies/livelykernel-scripts
    rm -rfd workspace
    lkrepo=`lk scripts-dir`/workspace/lk
    if [[ -d $lkrepo ]]; then
        mkdir -p workspace/
        cp -r $lkrepo workspace/
    else
        echo "Could not find existing lk workspace"
    fi
    if [[ -n $WEBWERKSTATT ]]; then
        mkdir -p workspace/lk
        cp -r $WEBWERKSTATT/PartsBin workspace/lk/
    else
        echo "Could not find existing PartsBin or Parts"
    fi
popd
