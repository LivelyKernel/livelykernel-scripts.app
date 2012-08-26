#!/bin/sh

#  copy-git.sh
#  livelykernel-scripts
#
#  Created by Robert Krahn on 8/26/12.
#  Copyright (c) 2012 LivelyKernel. All rights reserved.

#######
# git #
#######
# build with
# git_osx_installer/build-for-lk-app.sh
CpMac -r ${SRCROOT}/git_osx_installer/git ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/git

########
# node #
########
# build with
# export CC=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
# export CXX=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++
# ./configure --prefix=$PWD/node-build; make; make install
CpMac -r ${SRCROOT}/node/node-build ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/node
sed -e 's:^#.*:#!/usr/bin/env node:' ${SRCROOT}/node/node-build/lib/node_modules/npm/bin/npm-cli.js > ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/node/lib/node_modules/npm/bin/npm-cli.js

########################
# livelykernel-scripts #
########################
CpMac -r ${SRCROOT}/lk-scripts ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/node/lib/node_modules/livelykernel-scripts
# ln -sF ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/node/lib/node_modules/livelykernel-scripts ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/livelykernel-scripts
