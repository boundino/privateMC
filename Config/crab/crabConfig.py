#

from CRABClient.UserUtilities import config
config = config()
config.General.transferOutputs = True
config.General.requestName = 'GENSIM_250526_EposLHC_ReggeGribovParton_OO_5362GeV'
config.General.workArea = 'crab_projects'
config.JobType.psetName = 'MinBias_EposLHC_ReggeGribovParton_OO_5362GeV.py'
# config.JobType.inputFiles = ['starlight_double_diffraction_el8_amd64_gcc12_CMSSW_15_0_0_pre2_tarball.tgz']
config.JobType.pluginName = 'PrivateMC'
config.JobType.maxMemoryMB = 2500
config.JobType.pyCfgParams = ['noprint']
# config.JobType.numCores = 4
config.JobType.allowUndistributedCMSSW = True

##
# config.Data.outputPrimaryDataset = 'Starlight_DoubleDiffraction_NoTuneCP5_OO_5362GeV'
config.Data.outputPrimaryDataset = 'MinBias_EposLHC_ReggeGribovParton_b015_OO_5362GeV'
config.Data.unitsPerJob = 500 ## 
NJOBS = 200 ## total number of jobs !
config.Data.totalUnits = config.Data.unitsPerJob * NJOBS
config.Data.splitting = 'EventBased'
config.Data.publication = True
config.Data.outputDatasetTag = 'GENSIM_250526_1506p1_Nominal2025OOCollision'

##
# config.Site.storageSite = 'T2_US_MIT'
config.Site.storageSite = 'T2_US_Vanderbilt'
# config.Site.blacklist = ['T2_US_Nebraska','T2_US_UCSD','T2_US_Wisconsin','T3_US_Rutgers','T3_BG_UNI_SOFIA','T3_IT_Perugia']
# config.Site.blacklist = ['T2_CH_CERN']
# config.Site.ignoreGlobalBlacklist = True
config.section_("Debug")
config.Debug.extraJDL = ['+CMS_ALLOW_OVERFLOW=False']
