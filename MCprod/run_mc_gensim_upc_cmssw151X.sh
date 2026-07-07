#!/bin/bash

FRAG=$1
NEVT=${2:-10000}

config=${FRAG##*/}
config=${config%%.*}
config=${config}

# cmsDriver.py Configuration/GenProduction/python/HIN-HINPbPbWinter25GS-00002-fragment.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --conditions 151X_mcRun3_2025_realistic_HI_v5 --beamspot DBrealistic --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(100)" --step GEN,SIM --scenario HeavyIons --geometry DB:Extended --era Run3_pp_on_PbPb_2025 --python_filename HIN-HINPbPbWinter25GS-00002_1_cfg.py --fileout file:HIN-HINPbPbWinter25GS-00002.root --number 100 --number_out 100 --no_exec --mc || exit $? ;

set -x
cmsDriver.py $FRAG --scenario HeavyIons \
             --era Run3_2025_UPC --beamspot DBrealistic --step GEN,SIM \
             --geometry DB:Extended --conditions 151X_mcRun3_2025_realistic_HI_v5 \
             --datatier GEN-SIM --eventcontent RAWSIM \
             --python_filename ${config}.py --fileout ${config}.root --number $NEVT \
             --no_exec --mc || exit $? ;
set +x
# --nThreads 4
# --pileup_input "dbs:/MinBias_NeNe_5p36TeV_hijing/HINOOSpring25GS-150X_mcRun3_2025_forOO_realistic_v8-v3/GEN-SIM" \

echo '
process.Timing = cms.Service("Timing",
                             summaryOnly = cms.untracked.bool(True),
                             # useJobReport = cms.untracked.bool(True)
)

process.MessageLogger.cerr.FwkReport.reportEvery = 100
' >> ${config}.py


RUN=0
for i in $@
do
    [[ $i != --* ]] && continue
    [[ $i == --run ]] && { RUN=1 ; }
done

[[ $RUN -eq 1 ]] && {
    . run.sh ${config}.py
}
