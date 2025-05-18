set -x
cmsDriver.py miniaod --mc --eventcontent MINIAODSIM --datatier MINIAODSIM \
             --conditions 141X_mcRun3_2024_realistic_HI_v13 \
             --geometry DB:Extended \
             --step PAT --era Run3_2025_OXY \
             --no_exec -n -1 || exit $? ;

set +x

