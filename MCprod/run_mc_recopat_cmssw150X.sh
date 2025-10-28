set -x
cmsDriver.py reco --mc --eventcontent MINIAODSIM --datatier MINIAODSIM \
             --conditions 150X_mcRun3_2025_forOO_realistic_v8 \
             --geometry DB:Extended \
             --step RAW2DIGI,L1Reco,RECO,PAT --era Run3_2025_OXY \
             --nThreads 4 \
             --customise_commands "process.MINIAODSIMoutput.outputCommands.extend(['keep *_mix_MergedTrackTruth_*', 'keep *Link*_simSiPixelDigis__*', 'keep *Link*_simSiStripDigis__*', 'keep *_generalTracks__*', 'keep *_hiConformalPixelTracks__*', 'keep *_siPixelClusters__*', 'keep *_siStripClusters__*', 'keep *_towerMaker_*_*'])" \
             --no_exec -n -1 || exit $? ;

set +x

