#!/bin/bash
# run_mc_reco_embedded_cmssw123X.sh #
# ~CMSSW_12_3_2 #

input=file:step2_digiraw.root
config=step3_reco

##
[[ $# -eq 0 ]] && { echo "$0 [--run]" ; }
RUN=
for i in $@
do
    [[ $i != --* ]] && continue
    [[ $i == --run ]] && { RUN=1 ; }
done

##
mkdir -p logs

output=$config

echo -e "\e[32m-- ${config}.py\e[0m"
echo -e "\e[32m -- $input, ${output}.root\e[0m"
set -x

cmsDriver.py step3 -s RAW2DIGI,L1Reco,RECO,PAT \
    --conditions auto:phase1_2021_realistic_hi  --datatier MINIAODSIM --eventcontent MINIAODSIM --era Run3_pp_on_PbPb \
    --filein $input --fileout file:${output}.root --nThreads 4 \
    --python_filename ${config}.py --no_exec -n -1 || exit $? ;

# cmsDriver.py step2 --mc --eventcontent AODSIM --runUnscheduled --datatier AODSIM \
#     --conditions 103X_upgrade2018_realistic_HI_v11 \
#     --step RAW2DIGI,L1Reco,RECO --geometry DB:Extended --era Run2_2018_pp_on_AA --no_exec \
#     --filein $input --fileout file:${output}.root --nThreads 4 \
#     --python_filename ${config}.py --no_exec -n -1 || exit $? ;

echo '
process.Timing = cms.Service("Timing",
                             summaryOnly = cms.untracked.bool(True),
                             # useJobReport = cms.untracked.bool(True)
)' >> ${config}.py
set +x

[[ $RUN -eq 1 ]] &&  { 
    cmsRun -e -j logs/${config}.xml ${config}.py 2>&1 | tee logs/${config}.log ; 
}

