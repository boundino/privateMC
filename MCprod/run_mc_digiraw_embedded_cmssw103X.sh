#!/bin/bash
# run_mc_digiraw_embedded_cmssw103X.sh #
# ~CMSSW_10_3_3_patch1 #

input=file:/afs/cern.ch/work/w/wangj/privateMC/CMSSW_10_3_2/src/Pythia8_X3872ToJpsiRho_prompt_Xpt0p0_Pthat15_TuneCP5_5020GeV_Hydjet_Drum5F_GEN_SIM_PU.root
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

# embed=''
embed='--pileup HiMix --pileup_input dbs:/MinBias_Hydjet_Drum5F_2018_5p02TeV/HINPbPbAutumn18GS-103X_upgrade2018_realistic_HI_v11-v1/GEN-SIM'
output=$config

echo -e "\e[32m-- ${config}.py\e[0m"
echo -e "\e[32m -- $input, ${output}.root\e[0m"
echo -e "\e[32m -- embed: $embed"
set -x

# https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_setup/HIN-HINPbPbAutumn18DR-00097
# cmsDriver.py step1 --filein "dbs:/BsToJpsiPhi_pThat-10_TuneCP5_HydjetDrumMB_5p02TeV_Pythia8/HINPbPbAutumn18GSHIMix-103X_upgrade2018_realistic_HI_v11-v1/GEN-SIM" --fileout file:HIN-HINPbPbAutumn18DR-00097_step1.root --pileup_input "dbs:/MinBias_Hydjet_Drum5F_2018_5p02TeV/HINPbPbAutumn18GS-103X_upgrade2018_realistic_HI_v11-v1/GEN-SIM" --mc --eventcontent RAWSIM --pileup HiMix --datatier GEN-SIM-RAW --conditions 103X_upgrade2018_realistic_HI_v11 --step DIGI:pdigi_hi_nogen,L1,DIGI2RAW,HLT:HIon --nThreads 8 --geometry DB:Extended --era Run2_2018_pp_on_AA --python_filename HIN-HINPbPbAutumn18DR-00097_1_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n 128 || exit $? ; 

cmsDriver.py step1 --mc $embed --eventcontent RAWSIM --datatier GEN-SIM-RAW \
    --conditions 103X_upgrade2018_realistic_HI_v11 \
    --step DIGI:pdigi_hi_nogen,L1,DIGI2RAW,HLT:HIon --geometry DB:Extended --era Run2_2018_pp_on_AA --no_exec \
    --filein $input --fileout file:${output}.root --nThreads 1 \
    --python_filename ${config}.py --no_exec -n 1000 || exit $? ;

echo '
process.Timing = cms.Service("Timing",
                             summaryOnly = cms.untracked.bool(True),
                             # useJobReport = cms.untracked.bool(True)
)' >> ${config}.py
set +x

[[ $RUN -eq 1 ]] &&  { 
    cmsRun -e -j logs/${config}.xml ${config}.py 2>&1 | tee logs/${config}.log ; 
}

