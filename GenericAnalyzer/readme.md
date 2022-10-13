# GenericAnalyzer
This package is to display the particle chain (mother or daughter) of a type of particles in one event. The input file should be GEN-SIM format. This can be used to verify the MC gen configuration file.

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

## Printout example
The printout (daughter chain of D0 as an example) is like:
```
626 => -421 (2, 0) .. 0.958926, -0.970612π, -1.08027
    ├── 866 => 223 (2, 0) .. 0.910187, 0.888054π, -0.224349
    │   ├── 867 => 111 (2, 0) .. 0.754172, -0.9994π, -0.463156
    │   │   ├── 868 => 22 (1, 0) .. 0.591392, 0.975233π, -0.404624
    │   │   └── 869 => 22 (1, 0) .. 0.171255, -0.910753π, -0.634243
    │   └── 870 => 22 (1, 0) .. 0.330551, 0.598139π, 0.455989
    └── 871 => 130 (1, 0) .. 0.414292, -0.577887π, -1.65422

694 => 421 (2, 0) .. 4.62474, -0.0253075π, 0.884575
    ├── 864 => -321 (1, 0) .. 4.27438, -0.0514176π, 0.741717
    └── 865 => 211 (1, 0) .. 0.505656, 0.218232π, 1.58089

[No.] => [pdgId] ([status], [collision id]) .. [pt], [phi], [eta]
```
