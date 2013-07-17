import FWCore.ParameterSet.Config as cms

process = cms.Process("Demo")

process.load("FWCore.MessageService.MessageLogger_cfi")
process.load("SimGeneral.HepPDTESSource.pythiapdt_cfi")

process.load("RecoLocalCalo.EcalRecAlgos.EcalSeverityLevelESProducer_cfi") # Alex added
process.load("ElectroWeakAnalysis.WENu.simpleEleIdSequence_cff") # Alex added

process.load("ZShape.ZFromData.ZFromDataElectrons_cfi")
process.load("Configuration.Geometry.GeometryIdeal_cff")
process.load("Configuration.StandardSequences.FrontierConditions_GlobalTag_cff")
process.load("Configuration.StandardSequences.Services_cff") # Alex added
process.load("Configuration.StandardSequences.MagneticField_cff")
process.load('RecoJets.JetProducers.kt4PFJets_cfi') # For isolation calculation


process.MessageLogger.cerr.FwkReport.reportEvery = 100


process.GlobalTag.globaltag = 'START53_V16::All' #this is supposed to be for MC


process.maxEvents = cms.untracked.PSet( 
        input = cms.untracked.int32(-1) 
)

process.source = cms.Source("PoolSource",
    # replace 'myfile.root' with the source file you want to use
    fileNames = cms.untracked.vstring( 'file:/local/cms/phedex/store/data/Run2012A/DoubleElectron/AOD/22Jan2013-v1/20000/CCB5BA42-8067-E211-B915-0026189438B1.root')
)

process.TFileService = cms.Service("TFileService",
    fileName = cms.string("test.root"),
)

process.kt6PFJets = process.kt4PFJets.clone( 
        rParam = 0.6, 
        doRhoFastjet = True 
        )
process.kt6PFJets.Rho_EtaMax = cms.double(2.5)
process.otherStuff = cms.Sequence( process.kt6PFJets )

process.hltPickTriggered = cms.EDFilter('TriggerResultsFilter',
        hltResults              = cms.InputTag('TriggerResults','','HLT'),   # HLT results   - set to empty to ignore HLT
        l1tResults              = cms.InputTag(''),                 # L1 GT results - set to empty to ignore L1
        l1tIgnoreMask           = cms.bool(False),                  # use L1 mask
        l1techIgnorePrescales   = cms.bool(False),                  # read L1 technical bits from PSB#9, bypassing the prescales
        daqPartitions           = cms.uint32(0x01),                 # used by the definition of the L1 mask
        throw                   = cms.bool(True),                   # throw exception on unknown trigger names
        triggerConditions       = cms.vstring( 
            '	HLT_Ele27_CaloIdT_CaloIsoVL_TrkIdVL_TrkIsoVL_Ele15_CaloIdT_CaloIsoVL_trackless_v*'
            )
        )

process.demo = cms.EDAnalyzer('MakeZEffTree',
    quiet = cms.untracked.bool(True),
    TagProbeProducer = cms.untracked.InputTag('tpMapWP80AndNTSuper'),
    photonTag        = cms.InputTag( "photons" ),
    #TagProbeProducer = cms.untracked.InputTag('tpMapTIDSingleTrigHFSC'), # No trigger matching
    #TagProbeProducer = cms.untracked.InputTag('tpMapTIDDoubleTrigHFTID'), # Trigger matching
    CutNames          = cms.untracked.vstring("Supercluster-Eta", "GsfTrack-EtaDet",  "Iso-Pt", "ElectronId-EtaDet", "HLT-EtaDet", "HFElectronId-EtaDet", "HFSuperCluster-Et","HFTightElectronId-EtaDet","EID95","ISO95","EID90","ISO90","EID85","ISO85","EID80","ISO80","EID70","ISO70","EID60","ISO60","HLT-GSF","ISO80Only","ISO80Conv","EID80Only","EID80Conv","WP95","WP90","WP85","WP80","NTLooseElectronId-EtaDet","NTTightElectronId-EtaDet","HFTID" ),
    passProbeCandTags = cms.untracked.VInputTag(cms.InputTag("theSuperClusters"),cms.InputTag("theGsfElectrons"),cms.InputTag("theIsolation"),cms.InputTag("theId"),cms.InputTag("theHLT"), cms.InputTag("HFElectronID"), cms.InputTag("theHFSuperClusters"), cms.InputTag("HFElectronIDTight"), cms.InputTag("ElectronID95"), cms.InputTag("Iso95"), cms.InputTag("ElectronID90"), cms.InputTag("Iso90"), cms.InputTag("ElectronID85"), cms.InputTag("Iso85"), cms.InputTag("ElectronID80"), cms.InputTag("Iso80"), cms.InputTag("ElectronID70"), cms.InputTag("Iso70"), cms.InputTag("ElectronID60"), cms.InputTag("Iso60"), cms.InputTag("theHLTGsf"), cms.InputTag("Iso80Only"), cms.InputTag("Iso80WConv"), cms.InputTag("ElectronID80Only"), cms.InputTag("ElectronID80WConv"), cms.InputTag("WorkingPoint95"),cms.InputTag("WorkingPoint90"),cms.InputTag("WorkingPoint85"),cms.InputTag("WorkingPoint80"),cms.InputTag("NTElecLoose"),cms.InputTag("NTElecTight"),cms.InputTag("theHFHLT")),
)

process.p = cms.Path(process.hltPickTriggered + process.otherStuff + process.lepton_cands + process.demo)
