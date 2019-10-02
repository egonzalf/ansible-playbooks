#!/bin/bash
param=$1

if [[ $EUID -ne 0 ]]; then
    echo "Please run as root"
    exit
fi

_REALUSER_=$(logname)

#set -x

case $param in 
        "enable") 
                echo "Enabling automatic NUMA balancing"
                echo 1 > /proc/sys/kernel/numa_balancing
        ;; 
        "disable")
                echo "Disabling automatic NUMA balancing"
                echo 0 > /proc/sys/kernel/numa_balancing
        ;;
        *)
                echo "Usage: $0 <disable|enable>"
                exit 1
        ;;
esac


wall "****** Attention: user '${_REALUSER_}' has ${param}d automatic NUMA balancing ******"

