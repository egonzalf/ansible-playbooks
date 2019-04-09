#######################
# Environment modules delivered by Spack
export SPACK_SW_ROOT=/sw
export SPACK_APPS_ROOT=$SPACK_SW_ROOT/workstations/apps
export SPACK_MODULES_ROOT=$SPACK_SW_ROOT/workstations/modules
export SPACK_ROOT=$SPACK_SW_ROOT/spack
alias en_spack="source \$SPACK_SW_ROOT/spack/share/spack/setup-env.sh"

export KAUST_APPS_ROOT=/opt/share
#export KAUST_MODULES_ROOT=$SPACK_SW_ROOT/workstations/modules-old
export KAUST_MODULES_ROOT=$KAUST_APPS_ROOT/modules


MODULEPATH=~/local/modulefiles:$MODULEPATH
MODULEPATH=$MODULEPATH:$SPACK_MODULES_ROOT/linux-ubuntu16.04-x86_64:$KAUST_MODULES_ROOT/applications:$KAUST_MODULES_ROOT/libs:$KAUST_MODULES_ROOT/compilers:$KAUST_MODULES_ROOT/sets
export MODULEPATH
