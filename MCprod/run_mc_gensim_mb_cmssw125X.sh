#!/bin/bash
# run_mc_gensim_embedded_cmssw125X.sh #
# ~CMSSW_12_5_2_patch1 #

source utility.shinc

BS=Nominal2022PbPbCollision
GT=125X_mcRun3_2022_realistic_HI_v7
Z0=0.136013
# SigmaZ=5.0

#
gens=(
    Run2022PbPb536/MinBias/python/MinBias_Hydjet_Drum5F_PbPb_5360GeV,8
    Run2022PbPb536/MinBias/python/MinBias_AMPT_NoStringMelting_PbPb_5360GeV,8
    Run2022PbPb536/MinBias/python/MinBias_AMPT_StringMelting_PbPb_5360GeV,8
    Run2022PbPb536/MinBias/python/MinBias_EposLHC_ReggeGribovParton_PbPb_5360GeV,8
)

##
RUN=0
ONLY_RUN=0
for i in $@
do
    [[ $i != --* ]] && continue
    [[ $i == --onlyrun ]] && { ONLY_RUN=1 ; RUN=1 ; }
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

    genconfig=${name}.py
    config=$(end_sub_name $name)_GEN_SIM
    output=file:${config}.root

    [[ $? -ne 0 ]] && { exit $? ; }

    echo -e "\e[32m -- $genconfig\e[0m"
    echo -e "\e[32m -- ${config}.py, $output\e[0m"
    set -x
    [[ $ONLY_RUN -eq 1 ]] || {
        cmsDriver.py $genconfig --mc -s GEN,SIM --eventcontent RAWSIM --datatier GEN-SIM \
            --conditions $GT --beamspot $BS --era Run3_pp_on_PbPb --geometry DB:Extended \
            --python_filename ${config}.py --fileout $output --no_exec -n ${nevt} --nThreads 4 || exit $? ;

        echo '
process.'$BS'VtxSmearingParameters.Z0 = cms.double('$Z0')
# process.'$BS'VtxSmearingParameters.SigmaZ = cms.double('$SigmaZ')
process.VtxSmeared.Z0 = cms.double('$Z0')
# process.VtxSmeared.SigmaZ = cms.double('$SigmaZ')

process.Timing = cms.Service("Timing",
                             summaryOnly = cms.untracked.bool(True),
                             # useJobReport = cms.untracked.bool(True)
)' >> ${config}.py
    }

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

