#!/bin/bash
# run_mc_digiraw_embedded_cmssw123X.sh #
# ~CMSSW_12_3_2 #

input=file:Pythia8_DzeroToKPi_prompt_Dpt0p0_Pthat15_TuneCP5_5020GeV_py_GEN_SIM_PU.root
config=step2_digiraw

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
embed='--pileup HiMix --pileup_input dbs:/MinBias_Hydjet_Drum5F_5p02TeV/Run3Winter22PbPbNoMixGS-122X_mcRun3_2021_realistic_HI_v10-v1/GEN-SIM'
output=$config

echo -e "\e[32m-- ${config}.py\e[0m"
echo -e "\e[32m -- $input, ${output}.root\e[0m"
echo -e "\e[32m -- embed: $embed"
set -x

cmsDriver.py step2 -s DIGI:pdigi_hi_nogen,L1,DIGI2RAW,HLT:@fake2 \
    --conditions auto:phase1_2021_realistic_hi --datatier GEN-SIM-DIGI-RAW-HLTDEBUG --eventcontent FEVTDEBUGHLT --era Run3_pp_on_PbPb \
    $embed --pileup_dasoption "--limit 0" \
    --filein $input --fileout file:${output}.root --nThreads 4 \
    --python_filename ${config}.py --no_exec -n -1 || exit $? ;

# cmsDriver.py step1 --mc $embed --eventcontent RAWSIM --datatier GEN-SIM-RAW \
#     --conditions 103X_upgrade2018_realistic_HI_v11 \
#     --step DIGI:pdigi_hi_nogen,L1,DIGI2RAW,HLT:HIon --geometry DB:Extended --era Run2_2018_pp_on_AA --no_exec \
#     --filein $input --fileout file:${output}.root --nThreads 1 \
#     --python_filename ${config}.py --no_exec -n 1000 || exit $? ;

echo '
process.Timing = cms.Service("Timing",
                             summaryOnly = cms.untracked.bool(True),
                             # useJobReport = cms.untracked.bool(True)
)' >> ${config}.py
set +x

[[ $RUN -eq 1 ]] &&  { 
    cmsRun -e -j logs/${config}.xml ${config}.py 2>&1 | tee logs/${config}.log ; 
}

