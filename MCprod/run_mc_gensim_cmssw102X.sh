#!/bin/bash
# run_mc_gensim_cmssw102X.sh #
# ~CMSSW_10_2_6 #

source utility.shinc

igs=(0)

#####

gens=(
    Run2018pp13/python/Pythia8_LcTopkpi_Lcpt4p0 # 0: Lc non-resonance
)
nevt=(
    10000 # 0
)
tunes=CP5
pthatmin=1

##
RUN=
for i in $@
do
    [[ $i != --* ]] && continue
    [[ $i == --run ]] && { RUN=1 ; }
done
[[ $RUN -ne 1 ]] && { echo "$0 [--run]" ; }

##
mkdir -p logs rootfiles

# https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_setup/HIN-RunIILowPUAutumn18GS-00002
# cmsDriver.py Configuration/GenProduction/python/HIN-RunIILowPUAutumn18GS-00002-fragment.py --fileout file:HIN-RunIILowPUAutumn18GS-00002.root --mc --eventcontent RAWSIM --datatier GEN-SIM --conditions 102X_upgrade2018_realistic_v11 --beamspot Realistic25ns13TeVEarly2018Collision --step GEN,SIM --geometry DB:Extended --era Run2_2018 --python_filename HIN-RunIILowPUAutumn18GS-00002_1_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n 23160 || exit $? ; 

for ig in ${igs[@]}
do
    genconfig=${gens[ig]}_BiasPthatMin${pthatmin}_Tune${tunes}_13TeV.py
    config=$(end_sub_name $genconfig)_GEN_SIM_PU
    [[ $? -ne 0 ]] && { exit $? ; }

    echo -e "\e[32m-- $genconfig\e[0m"
    echo -e "\e[32m -- ${config}.py, file:rootfiles/${config}.root\e[0m"
    echo -e "\e[32m -- embed: no embed for pp"
    set -x
    cmsDriver.py $genconfig --fileout file:rootfiles/${config}.root --mc --eventcontent RAWSIM --datatier GEN-SIM \
        --conditions 102X_upgrade2018_realistic_v11 --beamspot Realistic25ns13TeVEarly2018Collision --step GEN,SIM --nThreads 4 --geometry DB:Extended --era Run2_2018 \
        --python_filename ${config}.py --no_exec --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(2194426)" -n ${nevt[ig]} || exit $? ; 

    echo '
process.Timing = cms.Service("Timing",
                             summaryOnly = cms.untracked.bool(True),
                             # useJobReport = cms.untracked.bool(True)
)' >> ${config}.py

    [[ $RUN -eq 1 ]] &&  { cmsRun -e -j logs/${config}.xml ${config}.py 2>&1 | tee logs/${config}.log ; }
    set +x

    [[ $RUN -eq 1 ]] || continue
    echo ${nevt[ig]} events were ran >> logs/${config}.log
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
done
