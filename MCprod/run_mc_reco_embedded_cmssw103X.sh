#!/bin/bash
# run_mc_gensim_embedded_cmssw103X.sh #
# ~CMSSW_10_3_3_patch1 #

input=file:step1_digi.root
config=step2_reco

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

# https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_setup/HIN-HINPbPbAutumn18DR-00097
# cmsDriver.py step2 --filein file:HIN-HINPbPbAutumn18DR-00097_step1.root --fileout file:HIN-HINPbPbAutumn18DR-00097.root --mc --eventcontent AODSIM --runUnscheduled --datatier AODSIM --conditions 103X_upgrade2018_realistic_HI_v11 --step RAW2DIGI,L1Reco,RECO --nThreads 8 --era Run2_2018_pp_on_AA --python_filename HIN-HINPbPbAutumn18DR-00097_2_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n 128 || exit $? ; 

cmsDriver.py step2 --mc --eventcontent AODSIM --runUnscheduled --datatier AODSIM \
    --conditions 103X_upgrade2018_realistic_HI_v11 \
    --step RAW2DIGI,L1Reco,RECO --geometry DB:Extended --era Run2_2018_pp_on_AA --no_exec \
    --filein $input --fileout file:${output}.root --nThreads 4 \
    --python_filename ${config}.py --no_exec -n -1 || exit $? ;

echo '
process.Timing = cms.Service("Timing",
                             summaryOnly = cms.untracked.bool(True),
                             # useJobReport = cms.untracked.bool(True)
)' >> ${config}.py
set +x

[[ $RUN -eq 1 ]] &&  { 
    cmsRun -e -j logs/${config}.xml ${config}.py 2>&1 | tee logs/${config}.log ; 
}

