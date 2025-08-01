#!/bin/bash
# run_mc_gensim_embedded_cmssw103X.sh #
# ~CMSSW_10_3_2 #

source utility.shinc

igs=(8) # gens (channel)
ips=(0) # pthats, all: ({0..5})

#####

##
its=(1) # fixed CP5 Tune

##

gens=(
    Run2018PbPb502/Bplusana/python/Pythia8_BuToJpsiK_Bpt0p0                   # 0: B+
    Run2018PbPb502/Bsubsana/python/Pythia8_BsToJpsiPhi_Bpt5p0                 # 1: Bs
    Run2018PbPb502/Psi2Sana/python/Pythia8_Psi2SToJpsiPiPi_prompt_Psipt0p0    # 2: psi' prompt
    Run2018PbPb502/Psi2Sana/python/Pythia8_Psi2SToJpsiPiPi_nonprompt_Psipt0p0 # 3: psi' nonprompt
    Run2018PbPb502/X3872ana/python/Pythia8_X3872ToJpsiRho_prompt_Xpt0p0       # 4: Xrho prompt
    Run2018PbPb502/X3872ana/python/Pythia8_X3872ToJpsiRho_nonprompt_Xpt0p0    # 5: Xrho nonprompt
    Run2018PbPb502/X3872ana/python/Pythia8_X3872ToJpsiPiPi_prompt_Xpt0p0      # 6: Xpi  prompt
    Run2018PbPb502/Jpsi1Sana/python/Pythia8_JpsiToMuMu_nonprompt_Jpsipt0p0    # 7: jpsi nonprompt
    Run2018PbPb502/Dzeroana/python/Pythia8_DzeroToKPi_prompt_Dpt0p0           # 8: D0 prompt
    Run2018PbPb502/Dzeroana/python/Pythia8_DzeroToKPi_nonprompt_Dpt0p0        # 9: D0 prompt
)
nevt=(
    50000 # 0
    50000 # 1
    2000  # 2
    2000  # 3
    10000 # 4 (pthat5:20000)
    5000  # 5 (pthat5:10000)
    10000 # 6 (pthat5:20000)
    100   # 7
    500   # 8
    500   # 9
)
pthats=(0 5 10 15 30 50) # {0..5}
tunes=(CUEP8M1 CP5)

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

# embed=''
embed='--pileup HiMixGEN --pileup_input dbs:/MinBias_Hydjet_Drum5F_2018_5p02TeV/HINPbPbAutumn18GS-103X_upgrade2018_realistic_HI_v11-v1/GEN-SIM'

for ig in ${igs[@]}
do
    for ip in ${ips[@]}
    do
        for it in ${its[@]}
        do
            genconfig=${gens[ig]}_Pthat${pthats[ip]}_Tune${tunes[it]}_5020GeV.py
            config=$(end_sub_name $genconfig)_Hydjet_Drum5F_GEN_SIM_PU
            [[ $? -ne 0 ]] && { exit $? ; }

            echo -e "\e[32m-- $genconfig\e[0m"
            echo -e "\e[32m -- ${config}.py, file:rootfiles/${config}.root\e[0m"
            echo -e "\e[32m -- embed: $embed"
            set -x
            cmsDriver.py $genconfig --mc $embed --eventcontent RAWSIM --datatier GEN-SIM \
                --conditions 103X_upgrade2018_realistic_HI_v11 --beamspot MatchHI \
                --step GEN,SIM --scenario HeavyIons --geometry DB:Extended --era Run2_2018_pp_on_AA --no_exec \
                --fileout file:${config}.root --step GEN,SIM --nThreads 8 \
                --customise Configuration/DataProcessing/Utils.addMonitoring \
                --python_filename ${config}.py --no_exec -n ${nevt[ig]} || exit $? ;

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
    done
done

