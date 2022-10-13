# GenericAnalyzer
This package is to display the particle chain (Mother or daughter) of a type of particles in one event. The input file should be GEN-SIM format. This can be used to verify the MC gen configuration file.

## How to run
```
# in CMSSW_X_X_X/src/
git clone git@github.com:boundino/privateMC.git
ln -s privateMC/GenericAnalyzer .
scram b -j4
cp GenericAnalyzer/test/demochain_cfg.py .
cmsRun demochain_cfg.py inputFiles=file:your_input_file.root firstEvent=0 # will show the first event
``` 

## Options
* `pdgId = cms.int32(421)`: Display the chain of which particle species. E.g. 421 here is D0 meson
* `collisionId = cms.int32(0)`: Whether to display PYTHIA only (0) or all processes (-1)
* `motherOrdaughter = cms.int32(1)`: Whether to display mother (0) or daughter (1) chain

