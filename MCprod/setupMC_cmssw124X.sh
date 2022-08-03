#!/bin/bash

cmsrel CMSSW_12_4_0
cd CMSSW_12_4_0/src/
cmsenv

git cms-addpkg GeneratorInterface/ExternalDecays
git clone https://github.com/boundino/HFAnaGenFrags.git
ln -s HFAnaGenFrags/Run2018PbPb502 .

git clone https://github.com/boundino/privateMC.git
# ln -s privateMC/MCprod/GenericAnalyzer .
# cp privateMC/MCprod/GenericAnalyzer/test/demoanalyzer_cfg.py .

cp privateMC/MCprod/run_mc_gensim_cmssw124X.sh .
ln -s privateMC/MCprod/utility.shinc .

scram b -j4

# Set up grid >>>
echo $0
which grid-proxy-info
echo $SCRAM_ARCH
voms-proxy-init --voms cms --valid 168:00
voms-proxy-info --all
# <<<

