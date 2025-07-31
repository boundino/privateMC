#!/bin/bash

FRAG=$1
NEVT=${2:-1}
MODBS=1

config=${FRAG##*/}
config=${config%%.*}
[[ $MODBS -eq 1 ]] && {
    echo -e "\e[32m[ Realistic BS ]\e[0m" ;
    config=${config}_realisticBS ; }

set -x
cmsDriver.py $1 --mc --eventcontent RAWSIM --datatier GEN-SIM \
             --conditions 150X_mcRun3_2025_forOO_realistic_v7 --beamspot Nominal2025OOCollision \
             --step GEN,SIM --scenario HeavyIons --geometry DB:Extended --era Run3_2025_OXY \
             --python_filename ${config}.py --fileout ${config}.root --no_exec -n ${NEVT} || exit $? ;
set +x
# --nThreads 4

[[ $MODBS -eq 1 ]] && {
    set -x
    echo '
process.VtxSmeared = cms.EDProducer("BetafuncEvtVtxGenerator",
    Alpha = cms.double(0.0),
    BetaStar = cms.double(50),
    Emittance = cms.double(7.176e-8),
    Phi = cms.double(0.0),
    SigmaZ = cms.double(5.2929),
    TimeOffset = cms.double(0.0),
    X0 = cms.double(0.0158483),
    Y0 = cms.double(-0.00652439),
    Z0 = cms.double(0.557563),
    readDB = cms.bool(False),
    src = cms.InputTag("generator","unsmeared")
)
' >> ${config}.py
    set +x
}

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
