#!/bin/bash

# 2025 small system

cmsrel CMSSW_15_0_8
cd CMSSW_15_0_8/src/
cmsenv

# git cms-addpkg GeneratorInterface/ExternalDecays
set -x
MYHOST=github.com-work
if grep -q -E "^Host\s+$MYHOST$" ~/.ssh/config 2>/dev/null; then
    git clone git@github.com-work:boundino/HFAnaGenFrags.git    
    git clone git@github.com-work:boundino/privateMC.git
else
    git clone https://github.com/boundino/HFAnaGenFrags.git # use this if you don't use git ssh
    git clone https://github.com/boundino/privateMC.git
fi
set +x

ln -s HFAnaGenFrags/Run2025OO536 .
ln -s privateMC/MCprod/GenericAnalyzer .
cp privateMC/MCprod/GenericAnalyzer/test/demoanalyzer_cfg.py .

ln -s privateMC/MCprod/run_mc_gensim_cmssw150X.sh gensim.sh

scram b -j4

# Set up grid >>>
# which grid-proxy-info
# echo $SCRAM_ARCH
# voms-proxy-init --voms cms --valid 168:00
# voms-proxy-info --all
# <<<

