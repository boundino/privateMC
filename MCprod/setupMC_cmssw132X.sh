#!/bin/bash

cmsrel CMSSW_13_2_1
cd CMSSW_13_2_1/src/
cmsenv

git cms-addpkg GeneratorInterface/ExternalDecays
git clone git@github.com-work:boundino/HFAnaGenFrags.git
ln -s HFAnaGenFrags/Run2018PbPb502 .

git clone https://github.com/boundino/privateMC.git
ln -s privateMC/MCprod/GenericAnalyzer .
cp privateMC/MCprod/GenericAnalyzer/test/demoanalyzer_cfg.py .

ln -s privateMC/MCprod/run_mc_gensim_mb_cmssw132X.sh .
ln -s privateMC/MCprod/utility.shinc .

scram b -j4

# Set up grid >>>
echo $0
which grid-proxy-info
echo $SCRAM_ARCH
voms-proxy-init --voms cms --valid 168:00
voms-proxy-info --all
# <<<

