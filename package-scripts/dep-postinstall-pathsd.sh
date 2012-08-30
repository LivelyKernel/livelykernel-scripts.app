#!/usr/bin/env bash --login

######################################################################################################
# This script is called after the installer has copied the git, node, and                            #
# livelykernel-scripts packages. It tests wheter the git, node, or lk commands                       #
# are defined (using `which`). If they one is not, then:                                             #
# 1) the according package is copied into the livelykernel-scripts.app resource dir                  #
# 2) for the subdir bin/ of that dir a new file is created in the /etc/paths.d folder to extend PATH #
#                                                                                                    #
# This allows to install node/git/lk so that users can script on the command                         #
# line and our app can use those commands without having to touch system files                       #
# (except for paths.d)                                                                               #
######################################################################################################


###########
# helpers #
###########

function install() {
    tmp_location=$1; install_location=$2
    # move the package to its new home
    echo "installing $tmp_location to $install_location"
    mv $tmp_location $install_location
}

function remove() {
    echo "Removing $1"
    rm -rfd $1
}

function add_to_pathsd() {
    pathdcontent=$1; pathdfile=$2
    echo "putting $pathdcontent into /etc/paths.d/$pathdfile"
    [[ -n $pathdfile ]] && echo $pathdcontent | sudo tee /etc/paths.d/$pathdfile
}

##########
# run it #
##########

resource_dir=/Applications/livelykernel-scripts.app/Contents/Resources
tmp_location=$DSTROOT # like /tmp/livelykernel-scripts

echo "Installing $INSTALL_PKG_SESSION_ID..."
echo "tmp_location: $tmp_location"

case $INSTALL_PKG_SESSION_ID in
    *git.pkg)
        cmd_name=git;
        package_resource_dir=$resource_dir/$cmd_name;;
    *node.pkg)
        cmd_name=node;
        package_resource_dir=$resource_dir/$cmd_name;;
    *livelykernel-scripts.pkg)
        cmd_name=lk;
        package_resource_dir=$resource_dir/livelykernel-scripts;;
    *)
        echo "unknown INSTALL_PKG_SESSION_ID: $INSTALL_PKG_SESSION_ID";
        exit 1;;
esac

which_cmd=`which $cmd_name`
if [[ -z $which_cmd ]]; then
    install $tmp_location $package_resource_dir
    add_to_pathsd "$package_resource_dir/bin" "livelykernel-scripts-$cmd_name"
else
    remove $tmp_location
fi

# also symlink /Applications/livelykernel-scripts.app/Contents/Resources/livelykernel-scripts
# -> ~/node_modules/livelykernel-scripts
if [[ $cmd_name = "lk" ]] && [[ -d $package_resource_dir ]]; then
    echo "symlinking $HOME/node_modules/livelykernel-scripts -> $package_resource_dir"
    ln -sF $package_resource_dir $HOME/node_modules/livelykernel-scripts
fi

echo "Installing $INSTALL_PKG_SESSION_ID done"
