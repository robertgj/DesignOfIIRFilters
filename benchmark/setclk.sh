#!/bin/bash
# Disable CPU frequency scaling:
for c in `seq 0 7` ; do
  echo "4500000">/sys/devices/system/cpu/cpu$c/cpufreq/scaling_min_freq ;
  echo "performance">/sys/devices/system/cpu/cpu$c/cpufreq/scaling_governor ;
done ; 
