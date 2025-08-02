set -x
cmsDriver.py reco --mc --era Run3_2025_OXY \
             --step RAW2DIGI,L1Reco,RECO \
             --datatier AODSIM --eventcontent AODSIM \
             --conditions 150X_mcRun3_2025_forOO_realistic_v8 \
             --customise_commands "process.AODSIMoutput.outputCommands.extend(['keep *_mix_MergedTrackTruth_*', 'keep *Link*_simSiPixelDigis__*', 'keep *Link*_simSiStripDigis__*', 'keep *_generalTracks__*', 'keep *_hiConformalPixelTracks__*', 'keep *_siPixelClusters__*', 'keep *_siStripClusters__*'])" \
             --nThreads 4 \
             --no_exec -n -1 || exit $? ;
set +x

