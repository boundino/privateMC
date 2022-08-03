#!/bin/bash
# run_mc_gensim_embedded_cmssw124X.sh #
# ~CMSSW_12_4_0 #

source utility.shinc

gens=(
    # Run2018PbPb502/Dzeroana/python/Pythia8_DzeroToKPi_prompt_Dpt0p0,500           # D0 prompt
    Run2018PbPb502/Dzeroana/python/Pythia8_DzeroToKPi_nonprompt_Dpt0p0,10000        # D0 nonprompt
)
pthats=(5) # pthats

##
RUN=
for i in $@
do
    [[ $i != --* ]] && continue
    [[ $i == --run ]] && { RUN=1 ; }
done
[[ $RUN -ne 1 ]] && { echo "$0 [--run]" ; }

##
mkdir -p logs

for gen in ${gens[@]}
do
    IFS=',' ; genconf=($gen) ; unset IFS ;
    name=${genconf[0]}
    nevt=${genconf[1]}

    for pthat in ${pthats[@]}
    do
        genconfig=${name}_Pthat${pthat}_TuneCP5_5020GeV.py
        config=$(end_sub_name $genconfig)_GEN_SIM
        [[ $? -ne 0 ]] && { exit $? ; }

        echo -e "\e[32m-- $genconfig\e[0m"
        echo -e "\e[32m -- ${config}.py, file:rootfiles/${config}.root\e[0m"
        echo -e "\e[32m -- embed: $embed"
        set -x
        cmsDriver.py $genconfig --mc --eventcontent RAWSIM --datatier GEN-SIM \
            --conditions auto:phase1_2022_realistic_hi --beamspot Run3RoundOptics25ns13TeVLowSigmaZ \
            --step GEN,SIM --nThreads 4 --scenario HeavyIons --geometry DB:Extended --era Run3_pp_on_PbPb \
            --python_filename ${config}.py --no_exec -n ${nevt} || exit $? ;

        echo '
process.Timing = cms.Service("Timing",
                             summaryOnly = cms.untracked.bool(True),
                             # useJobReport = cms.untracked.bool(True)
)
process.MessageLogger.cerr.FwkReport.reportEvery = 1000
' >> ${config}.py
        
        [[ $RUN -eq 1 ]] &&  { cmsRun -e -j logs/${config}.xml ${config}.py 2>&1 | tee logs/${config}.log ; }
        set +x

        [[ $RUN -eq 1 ]] || continue

        echo ${nevt} events were ran >> logs/${config}.log
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
done

