
// system include files
#include <memory>
#include <vector>

// user include files
#include "FWCore/Framework/interface/Frameworkfwd.h"
#include "FWCore/Framework/interface/EDAnalyzer.h"
#include "FWCore/Framework/interface/ConsumesCollector.h"

#include "FWCore/Framework/interface/Event.h"
#include "FWCore/Framework/interface/MakerMacros.h"

#include "FWCore/ParameterSet/interface/ParameterSet.h"

#include "CommonTools/UtilAlgos/interface/TFileService.h"
#include "FWCore/ServiceRegistry/interface/Service.h"

#include "DataFormats/HeavyIonEvent/interface/Centrality.h"
#include "DataFormats/HeavyIonEvent/interface/EvtPlane.h"
#include "DataFormats/VertexReco/interface/Vertex.h"

#include "SimDataFormats/HiGenData/interface/GenHIEvent.h"
#include "SimDataFormats/GeneratorProducts/interface/HepMCProduct.h"
#include "SimDataFormats/GeneratorProducts/interface/GenEventInfoProduct.h"
#include "SimDataFormats/GeneratorProducts/interface/LHEEventProduct.h"
#include "SimDataFormats/PileupSummaryInfo/interface/PileupSummaryInfo.h"

#include <HepMC/PdfInfo.h>

#include "TTree.h"

//
// class declaration
//

class GenEvtAnalyzer : public edm::EDAnalyzer {
public:
  explicit GenEvtAnalyzer(const edm::ParameterSet&);
  ~GenEvtAnalyzer();

  static void fillDescriptions(edm::ConfigurationDescriptions& descriptions);


private:
  virtual void beginJob() override;
  virtual void analyze(const edm::Event&, const edm::EventSetup&) override;
  virtual void endJob() override ;

  // ----------member data ---------------------------

  edm::EDGetTokenT<edm::GenHIEvent> HiMCTag_;
  edm::EDGetTokenT<std::vector<PileupSummaryInfo>> puInfoToken_;
  edm::EDGetTokenT<GenEventInfoProduct> genInfoToken_;
  edm::EDGetTokenT<reco::GenParticleCollection> genLabel_;
  bool doHiMC_;
  
  edm::Service<TFileService> fs_;

  TTree* thi_;

  float fNpart;
  float fNcoll;
  float fNhard;
  float fPhi0;
  float fb;

  int fNcharged;
  int fNchargedMR;
  float fMeanPt;
  float fMeanPtMR;
  float fEtMR;
  int fNchargedPtCut;
  int fNchargedPtCutMR;

  int proc_id;
  float pthat;
  float weight;
  float alphaQCD;
  float alphaQED;
  float qScale;
  int   nMEPartons;
  int   nMEPartonsFiltered;
  std::pair<int, int> pdfID;
  std::pair<float, float> pdfX;
  std::pair<float, float> pdfXpdf;
  std::vector<int> npus;
  std::vector<float> tnpus;

  unsigned long long event;
  unsigned int run;
  unsigned int lumi;

  TTree* tgen_;
  std::vector<int> pdgId;
  std::vector<float> mass;
  std::vector<float> pt;
  std::vector<int> mo;
  std::vector<int> da1;
  std::vector<int> da2;
  std::vector<int> da3;
  std::vector<int> da4;

};

//
// constants, enums and typedefs
//

//
// static data member definitions
//

//
// constructors and destructor
//
GenEvtAnalyzer::GenEvtAnalyzer(const edm::ParameterSet& iConfig) :
  HiMCTag_(consumes<edm::GenHIEvent>(iConfig.getParameter<edm::InputTag>("HiMC"))),
  puInfoToken_(consumes<std::vector<PileupSummaryInfo>>(edm::InputTag("addPileupInfo"))),
  genInfoToken_(consumes<GenEventInfoProduct>(edm::InputTag("generator"))),
  genLabel_(consumes<reco::GenParticleCollection>(iConfig.getParameter<edm::InputTag>("GenLabel"))),
  doHiMC_(iConfig.getParameter<bool> ("doHiMC"))
{

}

GenEvtAnalyzer::~GenEvtAnalyzer()
{

  // do anything here that needs to be done at desctruction time
  // (e.g. close files, deallocate resources etc.)

}


//
// member functions
//

// ------------ method called for each event  ------------
void
GenEvtAnalyzer::analyze(const edm::Event& iEvent, const edm::EventSetup& iSetup)
{

  //cleanup previous event
  npus.clear();
  tnpus.clear();
  
  pdgId.clear();
  mass.clear();
  pt.clear();
  mo.clear();
  da1.clear();
  da2.clear();
  da3.clear();
  da4.clear();

  using namespace edm;

  // Run info
  event = iEvent.id().event();
  run = iEvent.id().run();
  lumi = iEvent.id().luminosityBlock();

  if(doHiMC_)
    {
      edm::Handle<edm::GenHIEvent> mchievt;
      if(iEvent.getByToken(HiMCTag_, mchievt)) 
        {
          fb = mchievt->b();
          fNpart = mchievt->Npart();
          fNcoll = mchievt->Ncoll();
          fNhard = mchievt->Nhard();
          fPhi0 = mchievt->evtPlane();
          fNcharged = mchievt->Ncharged();
          fNchargedMR = mchievt->NchargedMR();
          fMeanPt = mchievt->MeanPt();
          fMeanPtMR = mchievt->MeanPtMR();
          fEtMR = mchievt->EtMR();
          fNchargedPtCut = mchievt->NchargedPtCut();
          fNchargedPtCutMR = mchievt->NchargedPtCutMR();
        }
    }
  
  edm::Handle<GenEventInfoProduct> genInfo;
  if(iEvent.getByToken(genInfoToken_, genInfo)) 
    {
      proc_id = genInfo->signalProcessID();
      if (genInfo->hasBinningValues())
        pthat = genInfo->binningValues()[0];
      weight = genInfo->weight();
      nMEPartons = genInfo->nMEPartons();
      nMEPartonsFiltered = genInfo->nMEPartonsFiltered();
      alphaQCD = genInfo->alphaQCD();
      alphaQED = genInfo->alphaQED();
      qScale = genInfo->qScale();

      if (genInfo->hasPDF()) 
        {
          pdfID = genInfo->pdf()->id;
          pdfX.first = genInfo->pdf()->x.first;
          pdfX.second = genInfo->pdf()->x.second;
          pdfXpdf.first = genInfo->pdf()->xPDF.first;
          pdfXpdf.second = genInfo->pdf()->xPDF.second;
        }
    }

  // MC PILEUP INFORMATION
  edm::Handle<std::vector<PileupSummaryInfo>> puInfos;
  if (iEvent.getByToken(puInfoToken_, puInfos)) 
    {
      for (const auto& pu: *puInfos) 
        {
          npus.push_back(pu.getPU_NumInteractions());
          tnpus.push_back(pu.getTrueNumInteractions());
        }
    }

  edm::Handle<reco::GenParticleCollection> parts;
  iEvent.getByToken(genLabel_, parts);
  for(unsigned int i = 0; i < parts->size(); ++i)
    {
      const reco::GenParticle& p = (*parts)[i];
      pdgId.push_back(p.pdgId());
      mass.push_back(p.mass());
      pt.push_back(p.pt());
    }

  tgen_->Fill();
  thi_->Fill();
}


// ------------ method called once each job just before starting event loop  ------------
void
GenEvtAnalyzer::beginJob()
{
  thi_ = fs_->make<TTree>("hi", "");

  fNpart = -1;
  fNcoll = -1;
  fNhard = -1;
  fPhi0 = -1;
  fb = -1;
  fNcharged = -1;
  fNchargedMR = -1;
  fMeanPt = -1;
  fMeanPtMR = -1;

  fEtMR = -1;
  fNchargedPtCut = -1;
  fNchargedPtCutMR = -1;

  proc_id =   -1;
  pthat   =   -1.;
  weight  =   -1.;
  alphaQCD =  -1.;
  alphaQED =  -1.;
  qScale   =  -1.;
  //  npu      =   1;

  // Run info
  thi_->Branch("run",&run,"run/i");
  thi_->Branch("evt",&event,"evt/l");
  thi_->Branch("lumi",&lumi,"lumi/i");

  //Event observables
  if (doHiMC_) {
    thi_->Branch("Npart",&fNpart,"Npart/F");
    thi_->Branch("Ncoll",&fNcoll,"Ncoll/F");
    thi_->Branch("Nhard",&fNhard,"Nhard/F");
    thi_->Branch("phi0",&fPhi0,"NPhi0/F");
    thi_->Branch("b",&fb,"b/F");
    thi_->Branch("Ncharged",&fNcharged,"Ncharged/I");
    thi_->Branch("NchargedMR",&fNchargedMR,"NchargedMR/I");
    thi_->Branch("MeanPt",&fMeanPt,"MeanPt/F");
    thi_->Branch("MeanPtMR",&fMeanPtMR,"MeanPtMR/F");
    thi_->Branch("EtMR",&fEtMR,"EtMR/F");
    thi_->Branch("NchargedPtCut",&fNchargedPtCut,"NchargedPtCut/I");
    thi_->Branch("NchargedPtCutMR",&fNchargedPtCutMR,"NchargedPtCutMR/I");
  }
  thi_->Branch("ProcessID",&proc_id,"ProcessID/I");
  thi_->Branch("pthat",&pthat,"pthat/F");
  thi_->Branch("weight",&weight,"weight/F");
  thi_->Branch("alphaQCD",&alphaQCD,"alphaQCD/F");
  thi_->Branch("alphaQED",&alphaQED,"alphaQED/F");
  thi_->Branch("qScale",&qScale,"qScale/F");
  thi_->Branch("nMEPartons",&nMEPartons,"nMEPartons/I");
  thi_->Branch("nMEPartonsFiltered",&nMEPartonsFiltered,"nMEPartonsFiltered/I");
  thi_->Branch("pdfID",&pdfID);
  thi_->Branch("pdfX",&pdfX);
  thi_->Branch("pdfXpdf",&pdfXpdf);
  // thi_->Branch("ttbar_w",&ttbar_w);
  thi_->Branch("npus",&npus);
  thi_->Branch("tnpus",&tnpus);

  tgen_ = fs_->make<TTree>("genp", "");
  tgen_->Branch("pdgId", &pdgId);
  tgen_->Branch("mass", &mass);
  tgen_->Branch("pt", &pt);
}

// ------------ method called once each job just after ending the event loop  ------------
void
GenEvtAnalyzer::endJob()
{
}

// ------------ method fills 'descriptions' with the allowed parameters for the module  ------------
void
GenEvtAnalyzer::fillDescriptions(edm::ConfigurationDescriptions& descriptions) {
  //The following says we do not know what parameters are allowed so do no validation
  // Please change this to state exactly what you do use, even if it is no parameters
  edm::ParameterSetDescription desc;
  desc.setUnknown();
  descriptions.addDefault(desc);
}

//define this as a plug-in
DEFINE_FWK_MODULE(GenEvtAnalyzer);
