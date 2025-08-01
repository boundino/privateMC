#!/bin/bash

FRAG=$1
NEVT=${2:-20}

config=${FRAG##*/}
config=${config%%.*}

set -x
cmsDriver.py $FRAG --eventcontent RAWSIM --datatier GEN-SIM \
             --conditions 150X_mcRun3_2025_forOO_realistic_v8 --beamspot DBrealistic \
             --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(500)" \
             --step GEN,SIM --scenario HeavyIons --geometry DB:Extended --era Run3_2025_OXY \
             --python_filename ${config}.py --fileout ${config}.root -n ${NEVT} --no_exec --mc || exit $? ;
set +x
# --nThreads 4

echo '
process.Timing = cms.Service("Timing",
                             summaryOnly = cms.untracked.bool(True),
                             # useJobReport = cms.untracked.bool(True)
)

process.MessageLogger.cerr.FwkReport.reportEvery = 10
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
