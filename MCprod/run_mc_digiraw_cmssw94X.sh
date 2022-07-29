#!/bin/bash
# run_mc_digiraw_cmssw94X.sh #
# ~CMSSW_9_4_11 #

input=file:../../CMSSW_9_4_13_patch1/src/rootfiles/Pythia8_BdToJpsiKstar_Bpt2p0_BiasPthatMin5_TuneCP5_5020GeV_GEN_SIM_PU.root
config=step1_digi

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

embed='--pileup_input dbs:/MinBias_TuneCUETP8M1_2017_5p02TeV-pythia8/RunIIpp5Spring18GS-94X_mc2017_realistic_v10For2017G_v3-v2/GEN-SIM --pileup E7TeV_AVE_2_BX2808'
output=$config

echo -e "\e[32m-- ${config}.py\e[0m"
echo -e "\e[32m -- $input, ${output}.root\e[0m"
echo -e "\e[32m -- embed: $embed"
set -x

# https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_setup/HIN-RunIIpp5Spring18DR-00089
# cmsDriver.py step1 --filein "dbs:/BuToJpsiKp_pThat-5_TuneCP5_5p02TeV_Pythia8/RunIIpp5Spring18GS-94X_mc2017_realistic_forppRef5TeV-v1/GEN-SIM" --fileout file:HIN-RunIIpp5Spring18DR-00089_step1.root --pileup_input "dbs:/MinBias_TuneCUETP8M1_2017_5p02TeV-pythia8/RunIIpp5Spring18GS-94X_mc2017_realistic_v10For2017G_v3-v2/GEN-SIM" --mc --eventcontent RAWSIM --pileup E7TeV_AVE_2_BX2808 --datatier GEN-SIM-RAW --conditions 94X_mc2017_realistic_forppRef5TeV_v1 --beamspot Realistic5TeVppCollision2017 --step DIGI,L1,DIGI2RAW,HLT:PRef --nThreads 8 --geometry DB:Extended --era Run2_2017_ppRef --python_filename HIN-RunIIpp5Spring18DR-00089_1_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n 1168 || exit $? ; 
set -x
cmsDriver.py step1 --mc $embed --eventcontent RAWSIM --datatier GEN-SIM-RAW \
    --conditions 94X_mc2017_realistic_forppRef5TeV_v1 --beamspot Realistic5TeVppCollision2017 \
    --step DIGI,L1,DIGI2RAW,HLT:PRef --geometry DB:Extended --era Run2_2017_ppRef --no_exec \
    --filein $input --fileout file:${output}.root --nThreads 4 \
    --python_filename ${config}.py --no_exec -n -1 || exit $? ;
set +x
echo '
process.Timing = cms.Service("Timing",
                             summaryOnly = cms.untracked.bool(True),
                             # useJobReport = cms.untracked.bool(True)
)' >> ${config}.py
set +x

[[ $RUN -eq 1 ]] &&  { 
    cmsRun -e -j logs/${config}.xml ${config}.py 2>&1 | tee logs/${config}.log ; 
}

