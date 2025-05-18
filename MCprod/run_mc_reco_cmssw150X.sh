set -x
cmsDriver.py reco --mc --eventcontent AODSIM --datatier AODSIM \
             --conditions 141X_mcRun3_2024_realistic_HI_v13 \
             --geometry DB:Extended \
             --step RAW2DIGI,L1Reco,RECO,RECOSIM --era Run3_2025_OXY \
             --nThreads 4 \
             --customise_commands "process.AODSIMoutput.outputCommands.extend(['keep *_mix_MergedTrackTruth_*', 'keep *Link*_simSiPixelDigis__*', 'keep *Link*_simSiStripDigis__*', 'keep *_generalTracks__*', 'keep *_hiConformalPixelTracks__*', 'keep *_siPixelClusters__*', 'keep *_siStripClusters__*', 'keep *_towerMaker_*_*'])" \
             --no_exec -n -1 || exit $? ;

set +x

