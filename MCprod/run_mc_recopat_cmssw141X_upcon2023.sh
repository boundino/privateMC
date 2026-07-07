set -x
cmsDriver.py recoupc2023 --era Run3_2023_UPC \
             --step RAW2DIGI,L1Reco,RECO,PAT --conditions 141X_mcRun3_2023_realistic_HI_v11 \
             --datatier MINIAODSIM --eventcontent MINIAODSIM \
             --nThreads 4 \
             -n -1 --no_exec --mc || exit $? ;

set +x

