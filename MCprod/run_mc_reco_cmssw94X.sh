#!/bin/bash
# run_mc_reco_cmssw94X.sh #
# ~CMSSW_9_4_11 #

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

# https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_setup/HIN-RunIIpp5Spring18DR-00089
# cmsDriver.py step2 --filein file:HIN-RunIIpp5Spring18DR-00089_step1.root --fileout file:HIN-RunIIpp5Spring18DR-00089.root --mc --eventcontent AODSIM --datatier AODSIM --conditions 94X_mc2017_realistic_forppRef5TeV_v1 --step RAW2DIGI,L1Reco,RECO,RECOSIM,EI --nThreads 8 --geometry DB:Extended --era Run2_2017_ppRef --python_filename HIN-RunIIpp5Spring18DR-00089_2_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n 1168 || exit $? ;

cmsDriver.py step2 --mc --eventcontent AODSIM --datatier AODSIM \
    --conditions 94X_mc2017_realistic_forppRef5TeV_v1 \
    --step RAW2DIGI,L1Reco,RECO,RECOSIM,EI --geometry DB:Extended --era Run2_2017_ppRef --no_exec \
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

