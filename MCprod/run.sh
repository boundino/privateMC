#!/bin/bash

[[ $# -lt 1 ]] && { return 1 ; }

config=${1%%.*}

mkdir -p logs

cmsRun -e -j logs/${config}.xml ${config}.py 2>&1 | tee logs/${config}.log ; 

grep "TotalEvents" logs/${config}.xml >> logs/${config}.log
if [ $? -eq 0 ]; then
    grep "Timing-tstoragefile-write-totalMegabytes" logs/${config}.xml >> logs/${config}.log
    if [ $? -eq 0 ]; then
        events=$(grep "TotalEvents" logs/${config}.xml | tail -1 | sed "s/.*>\(.*\)<.*/\1/")
        size=$(grep "Timing-tstoragefile-write-totalMegabytes" logs/${config}.xml | sed "s/.* Value=\"\(.*\)\".*/\1/")
        if [ $events -gt 0 ]; then
            echo "McM Size/event: $(bc -l <<< "scale=4; $size*1024 / $events")" >> logs/${config}.log
        fi
    fi
fi
grep "EventThroughput" logs/${config}.xml >> logs/${config}.log
if [ $? -eq 0 ]; then
    var1=$(grep "EventThroughput" logs/${config}.xml | sed "s/.* Value=\"\(.*\)\".*/\1/")
    echo "McM time_event value: $(bc -l <<< "scale=4; 1/$var1")" >> logs/${config}.log
fi
echo CPU efficiency info: >> logs/${config}.log
grep "TotalJobCPU" logs/${config}.xml >> logs/${config}.log
grep "TotalJobTime" logs/${config}.xml >> logs/${config}.log
