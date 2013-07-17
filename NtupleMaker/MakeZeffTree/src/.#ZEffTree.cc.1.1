#include "ZEffTree.h"

ZEffTree::ZEffTree(TFile& f, bool writable) : m_file(f) { 
    makeBranches(writable); 
    prepBitmap();
}

int ZEffTree::cutToBit(const std::string& cut) {
    std::map<std::string,int>::const_iterator i=cutToBits_.find(cut);
    return (i==cutToBits_.end())?(-1):(i->second);
}


bool ZEffTree::ZInfo::isSelected(int ielec, const std::string& bitname) const {
    int ibit=ZEffTree::cutToBit(bitname);
    if (ibit<0 || ielec<0 || ielec>=2){
        return false;
    }
    return ((bits[ielec] & (1 << ibit)) != 0);
}

void ZEffTree::ZInfo::setBit(int ielec, const std::string& bitname, bool val){
    int ibit=ZEffTree::cutToBit(bitname);
    if (ibit<0 || ielec<0 || ielec>=2){
        return; 
    }
    int mask = 1 << ibit;
    bits[ielec] = val ? (bits[ielec] | mask) : (bits[ielec] & ~mask);
}

/* Map from names to bitnums  */
std::map<std::string, int> ZEffTree::cutToBits_;

void ZEffTree::prepBitmap() {
    if (!cutToBits_.empty()) {
        return;
    }
    cutToBits_["Supercluster-Eta"] = 0;
    cutToBits_["GsfTrack-EtaDet"] = 1;
    cutToBits_["Iso-Pt"] = 2;
    cutToBits_["ElectronId-EtaDet"] = 3;
    cutToBits_["HLT-EtaDet"] = 4;
    cutToBits_["HFElectronId-EtaDet"] = 5;
    cutToBits_["HFSuperCluster-Et"] = 6;
    cutToBits_["HFTightElectronId-EtaDet"] = 7;
    cutToBits_["EID95"] = 8;
    cutToBits_["ISO95"] = 9;
    cutToBits_["EID90"] = 10;
    cutToBits_["ISO90"] = 11;
    cutToBits_["EID85"] = 12;
    cutToBits_["ISO85"] = 13;
    cutToBits_["EID80"] = 14;
    cutToBits_["ISO80"] = 15;
    cutToBits_["EID70"] = 16;
    cutToBits_["ISO70"] = 17;
    cutToBits_["EID60"] = 18;
    cutToBits_["ISO60"] = 19;
    cutToBits_["HLT-GSF"] = 20;
    cutToBits_["ISO80Only"] = 21;
    cutToBits_["ISO80Conv"] = 22;
    cutToBits_["EID80Only"] = 23;
    cutToBits_["EID80Conv"] = 24;
    cutToBits_["WP95"] = 25;
    cutToBits_["WP90"] = 26;
    cutToBits_["WP85"] = 27;
    cutToBits_["WP80"] = 28;
    cutToBits_["NTLooseElectronId-EtaDet"] = 29;
    //cutToBits_["NTTightElectronId-EtaDet"] = 30;
    //cutToBits_["HFTID"] = 31;
    cutToBits_["HFTID"] = 30;
}
