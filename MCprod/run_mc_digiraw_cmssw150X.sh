#!/bin/bash

set -x
cmsDriver.py digiraw --mc --eventcontent RAWSIM --datatier GEN-SIM-DIGI-RAW \
             --conditions 150X_mcRun3_2025_forOO_realistic_v7 \
             --step DIGI:pdigi_hi,L1,DIGI2RAW,HLT:@fake2 --geometry DB:Extended --era Run3_2025_OXY \
             --customise_commands "process.HcalTPGCoderULUT.FG_HF_thresholds = [16, 19]\n process.RAWSIMoutput.outputCommands.extend(['keep *_mix_MergedTrackTruth_*', 'keep *Link*_simSiPixelDigis__*', 'keep *Link*_simSiStripDigis__*'])" \
             --nThreads 4 \
             --no_exec -n -1 || exit $? ;

set +x

