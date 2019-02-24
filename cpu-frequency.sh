#!/bin/bash

##### This script will change the CPU FREQUENCY GOVERNOR
##### and the TurboBoost setting.
##### acpi-cpufreq driver is expected (not intel_pstate)



NPROCS=`cat /proc/cpuinfo | grep "core id" | wc -l`
NPROCS=$(($NPROCS - 1))

GOVERNOR="performance"
CHANGETURBOBOOST=""
CHANGEGOVERNOR=""
_REALUSER_=$(logname)

print_usage() {
    echo "usage: $0 [--enable-turbo|--disable-turbo|--performance|--ondemand]"
}

if [ ! -n "$1" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
    print_usage
    exit 0;
fi

if [[ $EUID -ne 0 ]]; then
    echo "Please run as root"
    exit
fi

broadcast="****** Attention: user '${_REALUSER_}' has set:\n"

GOVERNOR=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`

while [ -n "$1"  ]
do
    case "$1" in
        --enable-turbo)
            CHANGETURBOBOOST="yes"
            TURBOBOOST=1
            shift
            ;;
        --disable-turbo)
            CHANGETURBOBOOST="yes"
            TURBOBOOST=0
            shift
            ;;
        --ondemand)
            if grep -q "ondemand" /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors; then
                CHANGEGOVERNOR="yes"
                GOVERNOR="ondemand"
            elif grep -q "powersave" /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors; then
                # most likely, intel_pstate is the driver, not acpi-cpufreq
                echo "Governor 'ondemand' not available. Choosing 'powersave' instead."
                CHANGEGOVERNOR="yes"
                GOVERNOR="powersave"
            else
                echo "Governor 'ondemand' not available. Frequency governor will NOT be changed"
            fi
            shift
            ;;
        --performance)
            CHANGEGOVERNOR="yes"
            GOVERNOR="performance"
            shift
            ;;
        *)
            exit
            ;;
    esac
done

if [ "$CHANGEGOVERNOR" = "yes" ]; then
    echo "Setting Frequency governor : $GOVERNOR"
    for i in `seq 0 1 ${NPROCS}`; do echo "$GOVERNOR" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor; done
    broadcast="${broadcast} - Frequency governor: ${GOVERNOR}\n"
fi

if [ "$CHANGETURBOBOOST" = "yes" ]; then
    echo "TurboBoost mode: $TURBOBOOST"
    if [ -f /sys/devices/system/cpu/cpufreq/boost ]; then
        echo $TURBOBOOST > /sys/devices/system/cpu/cpufreq/boost
    else # assuming intel_pstate / it uses a no_turbo value (the inverse)
        tmp=$((1-TURBOBOOST))
        echo $tmp > /sys/devices/system/cpu/intel_pstate/no_turbo
    fi
    broadcast="${broadcast} - Turbo boost: ${TURBOBOOST} \n"
fi

cpupower frequency-info



echo -e "$broadcast" | wall


