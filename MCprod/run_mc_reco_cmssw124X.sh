#!/bin/bash
# run_mc_reco_embedded_cmssw124X.sh #
# ~CMSSW_12_4_0 #

input=file:step2_digiraw.root
config=step3_aod

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

cmsDriver.py step3 -s RAW2DIGI,L1Reco,RECO \
    --conditions auto:phase1_2022_realistic_hi --datatier GEN-SIM-RECO --eventcontent AODSIM --era Run3_pp_on_PbPb \
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

