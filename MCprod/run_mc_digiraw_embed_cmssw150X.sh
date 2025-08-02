#!/bin/bash

set -x
cmsDriver.py digirawembed --mc --pileup HiMix --era Run3_2025_OXY \
             --step DIGI:pdigi_hi_nogen,L1,DIGI2RAW,HLT:PIon --geometry DB:Extended \
             --conditions 150X_mcRun3_2025_forOO_realistic_v8 \
             --customise_commands "process.RAWSIMoutput.outputCommands.extend(['keep *_mix_MergedTrackTruth_*', 'keep *Link*_simSiPixelDigis__*', 'keep *Link*_simSiStripDigis__*'])" \
             --datatier GEN-SIM-DIGI-RAW --eventcontent RAWSIM \
             --pileup_input "dbs:/MinBias_Hijing_NeNe_5362GeV/wangj-GENSIM_250731_15011_Realistic_v8-022e8f21bdf6dc68bae0a2bb0c289cbd/USER instance=prod/phys03" \
             --nThreads 4 \
             --no_exec -n -1 || exit $? ;
set +x

