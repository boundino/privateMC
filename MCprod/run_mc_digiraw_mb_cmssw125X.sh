#!/bin/bash
# run_mc_digiraw_embedded_cmssw125X.sh #
# ~CMSSW_12_5_5_patch1 #

OUTDIR="/eos/cms/store/group/phys_heavyions/wangj/tracklet2022/small"
input=file:$OUTDIR/SinglePiPt01_pythia8_GEN_SIM.root
config=step2_digiraw
# config=$OUTDIR/SinglePiPt01_pythia8_DIGI_RAW.root

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
cmsDriver.py step1 --mc --eventcontent RAWSIM --step DIGI:pdigi_hi_nogen,L1,DIGI2RAW,HLT:HIon \
             --pileup HiMixNoPU \
             --datatier GEN-SIM-RAW --conditions 125X_mcRun3_2022_realistic_HI_v13 --geometry DB:Extended --era Run3_pp_on_PbPb \
             --filein $input --fileout file:$OUTDIR/${output}.root --nThreads 4 \
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

