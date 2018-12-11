#!/bin/bash 
MAXTHREADSPERCORE=12
param=$1

if [[ $EUID -ne 0 ]]; then
    echo "Please run as root"
    exit
fi

#set -x

nsockets=`grep "^physical id" /proc/cpuinfo | sort | uniq | wc -l`
ncorepersocket=`grep "^core id" /proc/cpuinfo | sort  | uniq | wc -l`
nthreads=`egrep "processor|physical id|cpu cores" /proc/cpuinfo | awk '{if( $1 == "processor" ) n=n+1; if($1=="physical" && a!=$4) a=$4; if( $1 == "cpu" ) c=$4} END {a=a+1;nt=n/(a*c);print nt}'`

if [ $nthreads -eq 1 ]; then nthreads=$MAXTHREADSPERCORE; fi

first_thread=$(( nsockets * ncorepersocket ))
last_thread=$(( first_thread * nthreads - 1 ))

# check for actual cpu entries to define last thread
for n in `seq $last_thread -1 $first_thread`; do
    if [ -d /sys/devices/system/cpu/cpu$n ]; then
        last_thread=$n;
        break
    fi
done



case $param in 
        "enable") 
                echo "Enabling Cores $first_thread to $last_thread" 
                for n in `seq $first_thread $last_thread`; do echo 1 > /sys/devices/system/cpu/cpu$n/online ;done
        ;; 
        "disable")
                echo "Disabling HyperThreading"
                for n in `seq $first_thread $last_thread`; do echo 0 > /sys/devices/system/cpu/cpu$n/online ;done
        ;;
        *)
                echo "Usage: $0 <disable|enable>"
                exit 1
        ;;
esac


