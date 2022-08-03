#!/bin/bash
# run_mc_digiraw_embedded_cmssw124X.sh #
# ~CMSSW_12_4_0 #

input=file:Pythia8_DzeroToKPi_nonprompt_Dpt0p0_Pthat0_TuneCP5_5020GeV_py_GEN_SIM.root
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

echo -e "\e[32m-- ${config}.py\e[0m"
echo -e "\e[32m -- $input, ${output}.root\e[0m"
echo -e "\e[32m -- embed: $embed"
set -x

cmsDriver.py step2 -s DIGI:pdigi_hi_nogen,L1,DIGI2RAW,HLT:@fake2 \
    --conditions auto:phase1_2022_realistic_hi --datatier GEN-SIM-DIGI-RAW-HLTDEBUG --eventcontent FEVTDEBUGHLT --era Run3_pp_on_PbPb \
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

