
// system include files
#include <memory>
#include <vector>
#include <map>

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

#include "TTree.h"

//
// class declaration
//

class RecoGenAnalyzer : public edm::EDAnalyzer {
public:
  explicit RecoGenAnalyzer(const edm::ParameterSet&);
  ~RecoGenAnalyzer();

  static void fillDescriptions(edm::ConfigurationDescriptions& descriptions);


private:
  virtual void beginJob() override;
  virtual void analyze(const edm::Event&, const edm::EventSetup&) override;
  virtual void endJob() override ;

  // ----------member data ---------------------------

  void push_mothers(const reco::Candidate* itref);
  void push_daughters(const reco::Candidate* itref);

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

  int proc_id;
  float pthat;
  float weight;
  float alphaQCD;
  float alphaQED;
  float qScale;

  unsigned long long event;
  unsigned int run;
  unsigned int lumi;

  TTree* tgen_;
  std::vector<int> pdgId;
  std::vector<float> status;
  std::vector<float> collisionId;
  std::vector<float> pt;
  std::vector<float> eta;
  std::vector<float> phi;
  std::vector<int> nmo;
  std::vector<int> mo1;
  std::vector<int> mo2;
  std::vector<int> mo3;
  std::vector<int> mo4;
  std::vector<int> mo1_pdgId;
  std::vector<int> mo2_pdgId;
  std::vector<int> mo3_pdgId;
  std::vector<int> mo4_pdgId;
  std::vector<int> mo1_status;
  std::vector<int> mo2_status;
  std::vector<int> mo3_status;
  std::vector<int> mo4_status;
  std::vector<int> nda;
  std::vector<int> da1;
  std::vector<int> da2;
  std::vector<int> da3;
  std::vector<int> da4;
  std::vector<int> da1_pdgId;
  std::vector<int> da2_pdgId;
  std::vector<int> da3_pdgId;
  std::vector<int> da4_pdgId;

  edm::Handle<reco::GenParticleCollection> gens;
  std::map<const reco::Candidate*, int> sel;

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
RecoGenAnalyzer::RecoGenAnalyzer(const edm::ParameterSet& iConfig) :
  HiMCTag_(consumes<edm::GenHIEvent>(iConfig.getParameter<edm::InputTag>("HiMC"))),
  puInfoToken_(consumes<std::vector<PileupSummaryInfo>>(edm::InputTag("addPileupInfo"))),
  genInfoToken_(consumes<GenEventInfoProduct>(edm::InputTag("generator"))),
  genLabel_(consumes<reco::GenParticleCollection>(iConfig.getParameter<edm::InputTag>("GenLabel"))),
  doHiMC_(iConfig.getParameter<bool> ("doHiMC"))
{

}

RecoGenAnalyzer::~RecoGenAnalyzer()
{

  // do anything here that needs to be done at desctruction time
  // (e.g. close files, deallocate resources etc.)

}


//
// member functions
//

// ------------ method called for each event  ------------
void
RecoGenAnalyzer::analyze(const edm::Event& iEvent, const edm::EventSetup& iSetup)
{

  //cleanup previous event
  pdgId.clear();
  status.clear();
  collisionId.clear();
  pt.clear();
  eta.clear();
  phi.clear();
  nmo.clear();
  mo1.clear();
  mo2.clear();
  mo3.clear();
  mo4.clear();
  mo1_pdgId.clear();
  mo2_pdgId.clear();
  mo3_pdgId.clear();
  mo4_pdgId.clear();
  mo1_status.clear();
  mo2_status.clear();
  mo3_status.clear();
  mo4_status.clear();
  nda.clear();
  da1.clear();
  da2.clear();
  da3.clear();
  da4.clear();
  da1_pdgId.clear();
  da2_pdgId.clear();
  da3_pdgId.clear();
  da4_pdgId.clear();

  sel.clear();

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
        }
    }
  
  edm::Handle<GenEventInfoProduct> genInfo;
  if(iEvent.getByToken(genInfoToken_, genInfo)) 
    {
      proc_id = genInfo->signalProcessID();
      if (genInfo->hasBinningValues())
        pthat = genInfo->binningValues()[0];
      weight = genInfo->weight();
      alphaQCD = genInfo->alphaQCD();
      alphaQED = genInfo->alphaQED();
      qScale = genInfo->qScale();
    }

  iEvent.getByToken(genLabel_, gens);
  std::map<const reco::Candidate*, int> lut;
  for(std::vector<reco::GenParticle>::const_iterator it_gen = gens->begin(); it_gen != gens->end(); it_gen++)
    {
      if(abs(it_gen->pdgId()) != 421) continue;
      const reco::Candidate* it_ref = &*it_gen;
      push_mothers(it_ref);
      push_daughters(it_ref);
    }

  int sel_index = 0;
  for(std::vector<reco::GenParticle>::const_iterator it_gen = gens->begin(); it_gen != gens->end(); it_gen++)
    {
      // reco::GenParticle _deRef = (*it_gen);
      const reco::Candidate* it_ref = &*it_gen;
      if(sel.find(it_ref) == sel.end()) continue;

      pdgId.push_back(it_gen->pdgId());
      status.push_back(it_gen->status());
      pt.push_back(it_gen->pt());
      eta.push_back(it_gen->eta());
      phi.push_back(it_gen->phi());
      collisionId.push_back(it_gen->collisionId());
      nmo.push_back(it_gen->numberOfMothers());
      nda.push_back(it_gen->numberOfDaughters());
      lut[it_ref] = sel_index;
      // lut[it_ref] = int(it_gen - gens.begin());
      mo1.push_back(-1);
      mo2.push_back(-1);
      mo3.push_back(-1);
      mo4.push_back(-1);
      mo1_pdgId.push_back(0);
      mo2_pdgId.push_back(0);
      mo3_pdgId.push_back(0);
      mo4_pdgId.push_back(0);
      mo1_status.push_back(0);
      mo2_status.push_back(0);
      mo3_status.push_back(0);
      mo4_status.push_back(0);
      da1.push_back(-1);
      da2.push_back(-1);
      da3.push_back(-1);
      da4.push_back(-1);
      da1_pdgId.push_back(0);
      da2_pdgId.push_back(0);
      da3_pdgId.push_back(0);
      da4_pdgId.push_back(0);

      sel_index++;
    }

  for(std::vector<reco::GenParticle>::const_iterator it_gen = gens->begin(); it_gen != gens->end(); it_gen++)
    {
      // int ii = int(it_gen - gens->begin());
      const reco::Candidate* it_ref = &*it_gen;
      if(sel.find(it_ref) == sel.end()) continue;
      int ii = lut[it_ref];

      int nmo = it_gen->numberOfMothers();
      for(int imo = 0; imo < nmo; imo++)
        {
          const reco::Candidate* rmo = it_gen->mother(imo);
          if(imo==0) { mo1[ii] = lut[rmo]; mo1_pdgId[ii] = rmo->pdgId(); mo1_status[ii] = rmo->status(); }
          if(imo==1) { mo2[ii] = lut[rmo]; mo2_pdgId[ii] = rmo->pdgId(); mo2_status[ii] = rmo->status(); }
          if(imo==2) { mo3[ii] = lut[rmo]; mo3_pdgId[ii] = rmo->pdgId(); mo3_status[ii] = rmo->status(); }
          if(imo==3) { mo4[ii] = lut[rmo]; mo4_pdgId[ii] = rmo->pdgId(); mo4_status[ii] = rmo->status(); }
          if(imo > 3 && rmo->pdgId() != 21) 
            {
              if(mo1_pdgId[ii] == 21) { mo1[ii] = lut[rmo]; mo1_pdgId[ii] = rmo->pdgId(); mo1_status[ii] = rmo->status(); }
              else if(mo2_pdgId[ii] == 21) { mo2[ii] = lut[rmo]; mo2_pdgId[ii] = rmo->pdgId(); mo2_status[ii] = rmo->status(); }
              else if(mo3_pdgId[ii] == 21) { mo3[ii] = lut[rmo]; mo3_pdgId[ii] = rmo->pdgId(); mo3_status[ii] = rmo->status(); }
              else if(mo4_pdgId[ii] == 21) { mo4[ii] = lut[rmo]; mo4_pdgId[ii] = rmo->pdgId(); mo4_status[ii] = rmo->status(); }
            }
        }

      int nda = it_gen->numberOfDaughters();
      for(int ida = 0; ida < nda; ida++)
        {
          const reco::Candidate* rda = it_gen->daughter(ida);
          if(ida==0) { da1[ii] = lut[rda]; da1_pdgId[ii] = rda->pdgId(); }
          if(ida==1) { da2[ii] = lut[rda]; da2_pdgId[ii] = rda->pdgId(); }
          if(ida==2) { da3[ii] = lut[rda]; da3_pdgId[ii] = rda->pdgId(); }
          if(ida==3) { da4[ii] = lut[rda]; da4_pdgId[ii] = rda->pdgId(); }
        }
    }

  tgen_->Fill();
  thi_->Fill();
}


void 
RecoGenAnalyzer::push_mothers(const reco::Candidate* itref)
{
  sel[itref] = 1; 
  int nmo = itref->numberOfMothers();
  for(int i=0; i<nmo; i++)
    { 
      push_mothers(itref->mother(i));
    }
}

void 
RecoGenAnalyzer::push_daughters(const reco::Candidate* itref)
{
  sel[itref] = 1; 
  int nmo = itref->numberOfDaughters();
  for(int i=0; i<nmo; i++)
    { 
      push_daughters(itref->daughter(i));
    }
}



// ------------ method called once each job just before starting event loop  ------------
void
RecoGenAnalyzer::beginJob()
{
  thi_ = fs_->make<TTree>("hi", "");

  fNpart = -1;
  fNcoll = -1;
  fNhard = -1;
  fPhi0 = -1;
  fb = -1;

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
  }
  thi_->Branch("ProcessID",&proc_id,"ProcessID/I");
  thi_->Branch("pthat",&pthat,"pthat/F");
  thi_->Branch("weight",&weight,"weight/F");
  thi_->Branch("alphaQCD",&alphaQCD,"alphaQCD/F");
  thi_->Branch("alphaQED",&alphaQED,"alphaQED/F");
  thi_->Branch("qScale",&qScale,"qScale/F");

  tgen_ = fs_->make<TTree>("genp", "");
  tgen_->Branch("pdgId", &pdgId);
  tgen_->Branch("status", &status);
  tgen_->Branch("collisionId", &collisionId);
  tgen_->Branch("pt", &pt);
  tgen_->Branch("eta", &eta);
  tgen_->Branch("phi", &phi);
  tgen_->Branch("nmo", &nmo);
  tgen_->Branch("mo1", &mo1);
  tgen_->Branch("mo2", &mo2);
  tgen_->Branch("mo3", &mo3);
  tgen_->Branch("mo4", &mo4);
  // tgen_->Branch("mo1_pdgId", &mo1_pdgId);
  // tgen_->Branch("mo2_pdgId", &mo2_pdgId);
  // tgen_->Branch("mo3_pdgId", &mo3_pdgId);
  // tgen_->Branch("mo4_pdgId", &mo4_pdgId);
  // tgen_->Branch("mo1_status", &mo1_status);
  // tgen_->Branch("mo2_status", &mo2_status);
  // tgen_->Branch("mo3_status", &mo3_status);
  // tgen_->Branch("mo4_status", &mo4_status);
  tgen_->Branch("nda", &nda);
  tgen_->Branch("da1", &da1);
  tgen_->Branch("da2", &da2);
  tgen_->Branch("da3", &da3);
  tgen_->Branch("da4", &da4);
  // tgen_->Branch("da1_pdgId", &da1_pdgId);
  // tgen_->Branch("da2_pdgId", &da2_pdgId);
  // tgen_->Branch("da3_pdgId", &da3_pdgId);
  // tgen_->Branch("da4_pdgId", &da4_pdgId);
}

// ------------ method called once each job just after ending the event loop  ------------
void
RecoGenAnalyzer::endJob()
{
}

// ------------ method fills 'descriptions' with the allowed parameters for the module  ------------
void
RecoGenAnalyzer::fillDescriptions(edm::ConfigurationDescriptions& descriptions) {
  //The following says we do not know what parameters are allowed so do no validation
  // Please change this to state exactly what you do use, even if it is no parameters
  edm::ParameterSetDescription desc;
  desc.setUnknown();
  descriptions.addDefault(desc);
}

//define this as a plug-in
DEFINE_FWK_MODULE(RecoGenAnalyzer);
