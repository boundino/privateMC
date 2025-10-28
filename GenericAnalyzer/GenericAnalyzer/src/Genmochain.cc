#include <memory>
#include <iostream>

#include "FWCore/MessageLogger/interface/MessageLogger.h"
#include "FWCore/ServiceRegistry/interface/Service.h"
// #include "CommonTools/UtilAlgos/interface/TFileService.h"

#include "FWCore/Framework/interface/Frameworkfwd.h"
#include "FWCore/Framework/interface/one/EDAnalyzer.h"
#include "FWCore/Framework/interface/Event.h"
#include "FWCore/Framework/interface/MakerMacros.h"
#include "FWCore/ParameterSet/interface/ParameterSet.h"

#include "SimDataFormats/GeneratorProducts/interface/HepMCProduct.h" 
#include "DataFormats/HepMCCandidate/interface/GenParticle.h"
// #include "DataFormats/JetReco/interface/GenJet.h"

class Genmochain : public edm::one::EDAnalyzer<edm::one::WatchRuns> {
public:
  explicit Genmochain(const edm::ParameterSet&);
  ~Genmochain();
  static void fillDescriptions(edm::ConfigurationDescriptions& descriptions);

private:
  virtual void beginJob() ;
  virtual void analyze(const edm::Event&, const edm::EventSetup&);
  virtual void endJob() ;
  virtual void beginRun(edm::Run const&, edm::EventSetup const&);
  virtual void endRun(edm::Run const&, edm::EventSetup const&);
  virtual void beginLuminosityBlock(edm::LuminosityBlock const&, edm::EventSetup const&);
  virtual void endLuminosityBlock(edm::LuminosityBlock const&, edm::EventSetup const&);

  const reco::Candidate* ffirst;
  std::vector<bool> flastll;
  void printline(const reco::Candidate* me);
  void printline(const reco::GenParticle* me);
  void drawline(int layer, bool lastornot, std::vector<bool> lastll);
  void printmo(const reco::Candidate* me);
  void showmo(const reco::Candidate* me, int layer, std::vector<bool> lastll);
  void showda(const reco::Candidate* me, int layer, std::vector<bool> lastll);

  std::map<const reco::Candidate*, unsigned int> lut_index;
  std::map<const reco::Candidate*, int> lut_collisionId;

  edm::EDGetTokenT< reco::GenParticleCollection > genLabel_;
  int pdgId_;
  int collisionId_;
  int status_;
  int motherOrdaughter_;
  int maxlayer_;
};

Genmochain::Genmochain(const edm::ParameterSet& iConfig)
{
  genLabel_ = consumes< reco::GenParticleCollection >(iConfig.getParameter<edm::InputTag>("GenLabel"));
  pdgId_ = iConfig.getParameter<int>("pdgId");
  collisionId_ = iConfig.getParameter<int>("collisionId");
  status_ = iConfig.getParameter<int>("status");
  maxlayer_ = iConfig.getParameter<int>("maxlayer");
  motherOrdaughter_ = iConfig.getParameter<int>("motherOrdaughter");

  ffirst = 0;
}

Genmochain::~Genmochain()
{
}

// ------------ method called for each event  ------------
void
Genmochain::analyze(const edm::Event& iEvent, const edm::EventSetup& iSetup)
{
  using namespace std;
  using namespace edm;

  lut_index.clear();
  lut_collisionId.clear();
  edm::Handle<reco::GenParticleCollection> parts;
  iEvent.getByToken(genLabel_, parts);

  if(parts->size() <= 0) return;
  ffirst = &((*parts)[0]);
  for(unsigned int i = 0; i < parts->size(); ++i)
    {
      const reco::GenParticle& p = (*parts)[i];
      const reco::Candidate* ref_p = &p;
      lut_index[ref_p] = i;
      lut_collisionId[ref_p] = p.collisionId();
    }
  for(unsigned int i = 0; i < parts->size(); ++i)
    {
      const reco::GenParticle& p = (*parts)[i];
      if(p.collisionId() != 0 && collisionId_ == 0) continue;
      if(p.collisionId() == 0 && collisionId_ > 0) continue;
      const reco::Candidate* ref_p = &p;
      int pdg = p.pdgId();
      int status = p.status();

      if(pdgId_ > 0 && abs(pdg) != pdgId_) continue;
      if(status_ > 0 && status != status_) continue;
      printmo(ref_p);
    }

#ifdef THIS_IS_AN_EVENT_EXAMPLE
  Handle<ExampleData> pIn;
  iEvent.getByLabel("example",pIn);
#endif
   
#ifdef THIS_IS_AN_EVENTSETUP_EXAMPLE
  ESHandle<SetupData> pSetup;
  iSetup.get<SetupRecord>().get(pSetup);
#endif
}


// ------------ method called once each job just before starting event loop  ------------
void 
Genmochain::beginJob()
{
}

// ------------ method called once each job just after ending the event loop  ------------
void 
Genmochain::endJob() 
{
  std::cout<<"\e[32m"<<"[No.]"<<"\e[0m \e[2m=>\e[0m \e[1m"<<"[pdgId]"<<"\e[0m \e[33m("<<"[status]"<<", "<<"[collision id]"<<")\e[0m \e[34m.. "<<"[pt]"<<", "<<"[phi]"<<", "<<"[eta]"<<"\e[0m"<<std::endl;
}

// ------------ method called when starting to processes a run  ------------
void 
Genmochain::beginRun(edm::Run const&, edm::EventSetup const&)
{
}

// ------------ method called when ending the processing of a run  ------------
void 
Genmochain::endRun(edm::Run const&, edm::EventSetup const&)
{
}

// ------------ method called when starting to processes a luminosity block  ------------
void 
Genmochain::beginLuminosityBlock(edm::LuminosityBlock const&, edm::EventSetup const&)
{
}

// ------------ method called when ending the processing of a luminosity block  ------------
void 
Genmochain::endLuminosityBlock(edm::LuminosityBlock const&, edm::EventSetup const&)
{
}

// ------------ method fills 'descriptions' with the allowed parameters for the module  ------------
void
Genmochain::fillDescriptions(edm::ConfigurationDescriptions& descriptions) {
  //The following says we do not know what parameters are allowed so do no validation
  // Please change this to state exactly what you do use, even if it is no parameters
  edm::ParameterSetDescription desc;
  desc.setUnknown();
  descriptions.addDefault(desc);
}

void
Genmochain::printline(const reco::Candidate* me)
{
  // std::cout<<"\e[32m"<<int(me-ffirst)<<"\e[0m \e[2m=>\e[0m \e[1m"<<me->pdgId()<<"\e[0m \e[33m("<<me->status()<<")\e[0m \e[34m.. "<<me->pt()<<", "<<me->phi()/M_PI<<"\e[0m"<<std::endl;
  std::cout<<"\e[32m"<<lut_index[me]<<"\e[0m \e[2m=>\e[0m \e[1m"<<me->pdgId()<<"\e[0m \e[33m("<<me->status()<<", "<<lut_collisionId[me]<<")\e[0m \e[34m.. "<<me->pt()<<", "<<me->phi()/M_PI<<"\u03C0, "<<me->eta()<<"\e[0m"<<std::endl;
}

void
Genmochain::drawline(int layer, bool lastornot, std::vector<bool> lastll)
{
  for(int i=0; i<layer; i++)
    {
      std::cout<<(lastll[i]?"    ":"\u2502   ");
    }
  std::cout<<(lastornot?"\u2514":"\u251C")<<"\u2500\u2500 ";
}

void
Genmochain::printmo(const reco::Candidate* me)
{
  flastll.clear();
  flastll.push_back(true);

  printline(me);
  if(motherOrdaughter_ == 0) showmo(me, 1, flastll);
  else if(motherOrdaughter_ == 1) showda(me, 1, flastll);
  std::cout<<std::endl;
}

void
Genmochain::showmo(const reco::Candidate* me, int layer, std::vector<bool> lastll)
{
  int nmo = me->numberOfMothers();
  if(nmo <= 0) return;
  if(maxlayer_ >= 0 && layer > maxlayer_) return;

  for(int i=0; i<nmo; i++)
    {
      const reco::Candidate* imo = me->mother(i);
      drawline(layer, i==(nmo-1), lastll);
      printline(imo);
      std::vector<bool> lastmo(lastll); lastmo.push_back(i==(nmo-1));
      showmo(imo, layer+1, lastmo);
    }
}

void
Genmochain::showda(const reco::Candidate* me, int layer, std::vector<bool> lastll)
{
  int nda = me->numberOfDaughters();
  if(nda <= 0) return;
  if(maxlayer_ >= 0 && layer > maxlayer_) return;

  for(int i=0; i<nda; i++)
    {
      const reco::Candidate* ida = me->daughter(i);
      drawline(layer, i==(nda-1), lastll);
      printline(ida);
      std::vector<bool> lastda(lastll); lastda.push_back(i==(nda-1));
      showda(ida, layer+1, lastda);
    }
}

//define this as a plug-in
DEFINE_FWK_MODULE(Genmochain);
