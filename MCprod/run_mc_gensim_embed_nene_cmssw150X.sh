#!/bin/bash

FRAG=$1
NEVT=${2:-1}

config=${FRAG##*/}
config=${config%%.*}

set -x
cmsDriver.py $FRAG --pileup HiMixGEN --scenario HeavyIons \
             --era Run3_2025_OXY --beamspot MatchHI --step GEN,SIM \
             --geometry DB:Extended --conditions 150X_mcRun3_2025_forOO_realistic_v8 \
             --datatier GEN-SIM --eventcontent RAWSIM \
             --python_filename ${config}.py --fileout ${config}.root -n ${NEVT} \
             --pileup_input "dbs:/MinBias_Hijing_NeNe_5362GeV/wangj-GENSIM_250731_15011_Realistic_v8-022e8f21bdf6dc68bae0a2bb0c289cbd/USER instance=prod/phys03" \
             --no_exec --mc || exit $? ;
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
