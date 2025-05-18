#!/bin/bash

FRAG=$1
NEVT=${2:-1}

config=${FRAG##*/}
config=${config%%.*}

set -x
cmsDriver.py $1 --mc --eventcontent RAWSIM --datatier GEN-SIM \
             --conditions 141X_mcRun3_2024_realistic_HI_v13 --beamspot DBrealistic \
             --step GEN,SIM --scenario HeavyIons --geometry DB:Extended --era Run3_2025_OXY \
             --python_filename ${config}.py --fileout ${config}.root --no_exec -n ${NEVT} || exit $? ;
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
