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
popd

echo ""
echo "################"
echo "# lk core repo #"
echo "################"
pushd $PWD
    lkrepo=`lk scripts-dir`/workspace/lk
    lkrepo_in_deps=dependencies/lk-core-repo
    if [[ -d $lkrepo ]]; then
        echo "Copying lk core repo from $lkrepo to $lkrepo_in_deps"
        cp -r $lkrepo $lkrepo_in_deps
        rm -rfd $lkrepo_in_deps/PartsBin
        echo "setting up git in $lkrepo_in_deps"
        cd $lkrepo_in_deps
        git remote rm origin
        git remote add -t master -m master -f origin git://github.com/rksm/LivelyKernel.git
        git branch --set-upstream master origin/master
        git pull --rebase
    else
        echo "Could not find existing lk workspace"
    fi
popd

echo ""
echo "############"
echo "# PartsBin #"
echo "############"
partsbindir_in_deps=dependencies/PartsBin
if [[ -n $WEBWERKSTATT ]]; then
    echo "Copying PartsBin from $WEBWERKSTATT/PartsBin to $partsbindir_in_deps"
    cp -r $WEBWERKSTATT/PartsBin $partsbindir_in_deps
else
    echo "Could not find existing PartsBin"
fi
