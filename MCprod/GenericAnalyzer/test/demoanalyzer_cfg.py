import FWCore.ParameterSet.Config as cms
process = cms.Process("Demo")
process.load("FWCore.MessageService.MessageLogger_cfi")

process.genParticlePlusGEANT = cms.EDProducer("GenPlusSimParticleProducer",
        src           = cms.InputTag("g4SimHits"), # use "famosSimHits" for FAMOS
        setStatus     = cms.int32(8),             # set status = 8 for GEANT GPs
        filter        = cms.vstring("pt > 0.0"),  # just for testing (optional)
	    genParticles   = cms.InputTag("genParticles") # original genParticle list
#	    genParticles   = cms.InputTag("hiGenParticles") # original genParticle list
)

process.demo = cms.EDAnalyzer('GenericAnalyzer',

    GenLabel        = cms.InputTag('genParticles'),
    MuonLabel       = cms.InputTag('muons'),
    TrackLabel      = cms.InputTag('hiGeneralTracks'),
    JetLabel      = cms.InputTag('ak3HiGenJets'),

	doHepMC = cms.untracked.bool(False),
	doGenParticle = cms.untracked.bool(True),
	doGenJet = cms.untracked.bool(False),
	doRecoTrk = cms.untracked.bool(False),
#	doRecoTrk = cms.untracked.bool(True),
	doRecoMuon = cms.untracked.bool(False)
#	doRecoMuon = cms.untracked.bool(True)
)

process.gp = cms.Path(process.genParticlePlusGEANT)
process.p = cms.Path(process.demo)
process.schedule = cms.Schedule(process.p)

##
import FWCore.ParameterSet.VarParsing as VarParsing
ivars = VarParsing.VarParsing('analysis')

ivars.maxEvents = -1
ivars.outputFile='results.root'
ivars.inputFiles='file:/afs/cern.ch/work/w/wangj/privateMC/CMSSW_10_3_1_patch2/src/Pythia8_X3872ToJpsiPiPi_prompt_Xpt0p0_Pthat5_TuneCUEP8M1_5020GeV_py_GEN_SIM_PU.root'
ivars.parseArguments()# get and parse the command line arguments

process.source = cms.Source("PoolSource",
    fileNames = cms.untracked.vstring(ivars.inputFiles)
)
process.maxEvents = cms.untracked.PSet(
    input = cms.untracked.int32(ivars.maxEvents)
)
process.TFileService = cms.Service("TFileService",
    fileName = cms.string(ivars.outputFile)
)
