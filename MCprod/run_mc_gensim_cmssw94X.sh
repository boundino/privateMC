#!/bin/bash
# run_mc_gensim_cmssw94X.sh #
# ~CMSSW_9_4_13_patch1 #

source utility.shinc

igs=(9)

#####

gens=(
    Run2018PbPb502/Bplusana/python/Pythia8_BuToJpsiK_Bpt0p0                   # 0: B+
    Run2018PbPb502/Bsubsana/python/Pythia8_BsToJpsiPhi_Bpt0p0                 # 1: Bs
    Run2018PbPb502/Psi2Sana/python/Pythia8_Psi2SToJpsiPiPi_prompt_Psipt0p0    # 2: psi' prompt
    Run2018PbPb502/Psi2Sana/python/Pythia8_Psi2SToJpsiPiPi_nonprompt_Psipt0p0 # 3: psi' nonprompt
    Run2018PbPb502/X3872ana/python/Pythia8_X3872ToJpsiRho_prompt_Xpt0p0       # 4: Xrho prompt
    Run2018PbPb502/X3872ana/python/Pythia8_X3872ToJpsiRho_nonprompt_Xpt0p0    # 5: Xrho nonprompt
    Run2018PbPb502/X3872ana/python/Pythia8_X3872ToJpsiPiPi_prompt_Xpt0p0      # 6: Xpi  prompt
    Run2018PbPb502/Jpsi1Sana/python/Pythia8_JpsiToMuMu_nonprompt_Jpsipt0p0    # 7: jpsi nonprompt
    Run2018PbPb502/Bzeroana/python/Pythia8_BdToJpsiKstar_Bpt2p0               # 8: Bd
    Run2018PbPb502/Dzeroana/python/Pythia8_DzeroToKPi_prompt_Dpt0p0           # 9: D0
    Run2018PbPb502/Dzeroana/python/Pythia8_DzeroToKPi_nonprompt_Dpt0p0        # 10: D0
)
nevt=(
    40000 # 0
    40000 # 1
    2000  # 2
    2000  # 3
    10000 # 4 (pthat5:20000)
    5000  # 5 (pthat5:10000)
    10000 # 6 (pthat5:20000)
    100   # 7
    400000 # 8
    20000 # 9
    10000 # 10
)
tunes=CP5
pthatmin=0

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

# cmsDriver.py Configuration/GenProduction/python/HIN-RunIIpp5Spring18GS-00062-fragment.py --fileout file:HIN-RunIIpp5Spring18GS-00062.root --mc --eventcontent RAWSIM --datatier GEN-SIM --conditions 94X_mc2017_realistic_forppRef5TeV --beamspot Realistic5TeVppCollision2017 --step GEN,SIM --nThreads 2 --geometry DB:Extended --era Run2_2017_ppRef --python_filename HIN-RunIIpp5Spring18GS-00062_1_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(2194426)" -n 449504 || exit $? ; 

for ig in ${igs[@]}
do
    # genconfig=${gens[ig]}_BiasPthatMin${pthatmin}_Tune${tunes}_5020GeV.py
    genconfig=${gens[ig]}_Pthat${pthatmin}_Tune${tunes}_5020GeV.py
    config=$(end_sub_name $genconfig)_GEN_SIM_PU
    [[ $? -ne 0 ]] && { exit $? ; }

    echo -e "\e[32m-- $genconfig\e[0m"
    echo -e "\e[32m -- ${config}.py, file:rootfiles/${config}.root\e[0m"
    echo -e "\e[32m -- embed: no embed for pp"
    set -x
    cmsDriver.py $genconfig --fileout file:rootfiles/${config}.root --mc --eventcontent RAWSIM --datatier GEN-SIM \
        --conditions 94X_mc2017_realistic_forppRef5TeV --beamspot Realistic5TeVppCollision2017 --step GEN,SIM --nThreads 4 --geometry DB:Extended --era Run2_2017_ppRef \
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
