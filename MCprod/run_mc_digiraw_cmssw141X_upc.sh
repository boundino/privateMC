#!/bin/bash

set -x
cmsDriver.py digiraw --pileup HiMixNoPU --era Run3_2024_UPC \
             --step DIGI,L1,DIGI2RAW,HLT:HIon --geometry DB:Extended \
             --conditions 141X_mcRun3_2024_realistic_HI_v14 \
             --datatier GEN-SIM-DIGI-RAW --eventcontent RAWSIM \
             --nThreads 4 \
             -n -1 --no_exec --mc || exit $? ;
set +x

