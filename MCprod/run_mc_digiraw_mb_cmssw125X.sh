#!/bin/bash
# run_mc_digiraw_embedded_cmssw125X.sh #
# ~CMSSW_12_5_2_patch1 #

input=file:MinBias_Hydjet_Drum5F_PbPb_5360GeV_GEN_SIM.root
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

output=$config

echo -e "\e[32m -- ${config}.py\e[0m"
echo -e "\e[32m -- $input, ${output}.root\e[0m"
set -x
cmsDriver.py step2 -s DIGI:pdigi_hi_nogen,L1,DIGI2RAW,HLT:@fake2 --mc \
    --conditions 125X_mcRun3_2022_realistic_HI_v7 --datatier GEN-SIM-DIGI-RAW-HLTDEBUG --eventcontent FEVTDEBUGHLT --era Run3_pp_on_PbPb \
    --pileup HiMixNoPU \
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

