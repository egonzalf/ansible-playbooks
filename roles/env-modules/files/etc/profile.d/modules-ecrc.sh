export ECRC_DISTRO=${ECRC_DISTRO:-ub16}
export ECRC_ARCH=${ECRC_ARCH:-x86_64-linux-gnu}
export ECRC_APPS_ROOT=/opt/ecrc
export MODULEPATH="$ECRC_APPS_ROOT/modules/compilers:$MODULEPATH"
export MODULEPATH="$ECRC_APPS_ROOT/modules/libs:$MODULEPATH"
export MODULEPATH="$ECRC_APPS_ROOT/modules/applications:$MODULEPATH"
export MODULEPATH="$ECRC_APPS_ROOT/modules/sets:$MODULEPATH"
