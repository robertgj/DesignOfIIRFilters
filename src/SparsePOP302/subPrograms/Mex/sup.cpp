/* -------------------------------------------------------------
 *
 * This file is a component of SparsePOP
 * Copyright (C) 2007 SparsePOP Project
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 *
 * ------------------------------------------------------------- */

#include "sup.h"
bool comp_sup(class sup & sup1, class sup & sup2){
	return (sup1 < sup2);
}
/* sup1 < sup2 */
bool sup::operator <(const class sup & t)const {
    const int sup1_nnz = idx.size();
    const int sup2_nnz = t.idx.size();
    if(sup1_nnz != 0 && sup2_nnz == 0){
        return false;
    }else if(sup2_nnz != 0 && sup1_nnz == 0){
        return true;
    //}else if(sup1_nnz == 0 && sup2_nnz == 0){
    //    return (bij < t.bij);
    }else{
		const int sup1_deg = accumulate(val.begin(),val.end(),0);
		const int sup2_deg = accumulate(t.val.begin(), t.val.end(),0);
		if(sup1_deg == sup2_deg){
			int i = 0;
			int min_nnz = sup1_nnz;
			if(min_nnz > sup2_nnz){
				 min_nnz = sup2_nnz;
			}
			while(i < min_nnz){
				if(t.idx[i] == idx[i]){
					if(t.val[i] == val[i]){
						i++;
					}else{
						return (t.val[i] < val[i]);
					}
				}else{
					return (t.idx[i] > idx[i]);
				}
			}

/* graded reverse lexicographic order. But it is slow. */
/*
			int i = sup1_nnz-1;
			int j = sup2_nnz-1;
			while(i >= 0 && j >= 0){
				if(idx[i] == t.idx[j]){
					if(val[i] == t.val[j]){
						i = i - 1;
						j = j - 1;
					}else{
						return (val[i] > t.val[j]);
					}
				}else{
					return (idx[i] > t.idx[j]);
				}
			}
*/
           // return (bij < t.bij);
        }else{
            return (sup1_deg < sup2_deg);
        }
    }
    return false;
}
void supSet::sort(){
    supList.sort(comp_sup);
}
sup::sup(){
    idx.resize(0);
    val.resize(0);
    //bij = 0;
    no = 0;
}
sup::sup(const sup& support){
    idx = support.idx;
    val = support.val;
    //bij = support.bij;
    no  = support.no;
}
sup::~sup(){
    idx.clear();
    val.clear();
}
sup& sup::operator=(const sup& support){
    if(this != &support){
        this->idx = support.idx;
        this->val = support.val;
    }
    return *this;
}
bool sup::operator==(const sup& support) const {
    return ((this->idx == support.idx) && (this->val == support.val));
}
bool sup::operator!=(const sup& support) const {
    return !(*this == support);
}


void sup::changeIndices(list<int> o2n_pattern){
    list<int>::iterator lit=o2n_pattern.begin();
    vector<int>::iterator vit=idx.begin();
    for(;vit != idx.end(); ++vit){
        advance(lit, (*vit));
        (*vit) = (*lit);
        lit = o2n_pattern.begin();
    }
}
void sup::push(int i, int v){
    if(v != 0){
        idx.push_back(i);
        val.push_back(v);
    }
}
void sup::clear(){
    idx.clear();
    val.clear();
}

void sup::erase_end(){
    idx.pop_back();
    val.pop_back();
}

list<class sup>::iterator supSet::erase(list<class sup>::iterator & supIte){
    return this->supList.erase(supIte);
}
void sup::disp(){
    vector<int>::iterator it=idx.begin();
    printf(" sup.idx:");
    for(;it!=idx.end();++it){
        printf(" %2d", (*it));
    }
    it = val.begin();
    printf(" sup.val:");
    for(;it!=val.end();++it){
        printf(" %2d", (*it));
    }
    printf("\n");
}
void sup::fdisp(ofstream & fout){
    
    int length=idx.size();
    fout<< " sup.idx:";
    for(int i=0;i<length;i++){
        fout<<" "<<idx[i]+1;
    }
    
    fout<<" sup.val:";
    for(int i=0;i<length;i++){
        fout<<" "<<val[i];
    }
    fout<<endl;
}
int sup::deg(){
    int deg = 0;
    if(!this->val.empty()){
        deg = accumulate(this->val.begin(), this->val.end(), 0);
    }
    return deg;
}
int sup::nnz(){
    //return this->idx.size();
    return idx.size();
}

supSet::supSet(){
    dimVar  = 0;
}
supSet::supSet(const supSet& supset){
    dimVar  = supset.dimVar;
    list<class sup>::iterator ite;
    supList.clear();
    supList = supset.supList;
}
supSet::~supSet(){
    this->supList.clear();
}

void supSet::disp(){
    list<class sup>::iterator supIte=this->supList.begin();
    int size=supList.size();
    
    for(int i=0;i<size;i++){
        cout<<"sup.";
        cout<<i+1;
        cout<<" : ";
        (*supIte).disp();
        supIte++;
    }
}
void sup::assignSupToArray(vector<int> & arrayData, int type){
// return the result of sup.val + arrayData if type = 1;
// return the result of sup.val - arrayData if type = -1;
    int len=val.size();
    int lenD=arrayData.size();
    if(type>=0){
        for(int i=0;i<len;i++){
            if(idx[i]>=lenD){
                cout << "lenD = " << lenD << endl;
                this->disp();
                errorMsg("## These Vector's length are different");
                exit(EXIT_FAILURE);
            }
            arrayData[idx[i]]+=val[i];
        }
    }
    if(type<0){
        for(int i=0;i<len;i++){
            if(idx[i]>=lenD){
                cout << "lenD = " << lenD << endl;
                this->disp();
                cout<<"error@sup::addDigitVal : These Vector's length are different"<<endl;
            }
            arrayData[idx[i]]-=val[i];
        }
    }
    
}


void supSet::pushSupSet(class supSet & newSet){
    list<class sup>::iterator ite;
    for(ite = newSet.supList.begin(); ite != newSet.supList.end(); ++ite){
        this->supList.push_back(*ite);
    }
}


void supSet::pushSupList(list<class sup> & SupList){
    list<class sup>::iterator ite;
    for(ite = SupList.begin(); ite != SupList.end(); ++ite){
        this->supList.push_back(*ite);
    }
}

void supSet::addSup(class sup & newSup, int type){
    
    list<class sup>::iterator oldSupIte=supList.begin();
    int len=supList.size();
    
    vector<int> Order;
    Order.resize(this->dimVar, 0);
    int temp;
    // the length of list is more than or equal to 1.
    if(len>0){
        int newDeg=newSup.deg();
        int oldDeg;
        for(int i=0;i<len;i++){
            oldDeg=(*oldSupIte).deg();
            if(newDeg>oldDeg){
                ++oldSupIte;
            }else if(newDeg<oldDeg){
                supList.insert(oldSupIte, newSup);
                return;
            }else if(newDeg==oldDeg){
                Order.clear();
                Order.resize(this->dimVar, 0);
                (*oldSupIte).assignSupToArray(Order);
                newSup.assignSupToArray(Order, -1);
                for(temp=0;temp<this->dimVar;temp++){
                    if(Order[temp] < 0){
                        supList.insert(oldSupIte, newSup);
                        return;
                    }else if(Order[temp] > 0){
                        ++oldSupIte;
                        break;
                    }
                }
                if(temp==this->dimVar){
                    return;
                }
            }
        }
        //add newSup into the last position of list because the degree is largest in the supSet.
    }
    supList.push_back(newSup);
    return;
}

int supSet::dimvar(){
    return this->dimVar;
}
list<class sup>::iterator supSet::begin(){
    return this->supList.begin();
}
list<class sup>::iterator supSet::end(){
    return this->supList.end();
}
int supSet::size(){
    return this->supList.size();
}
void supSet::setDimVar(int vnum){
    this->dimVar=vnum;
}
void genLexFixDeg(int k, int n, int W, class sup Sup, list<class sup> & supList){
    
    int Z=W;
    for(int i=Z;i>0;i--){
        Sup.push(k, i);
        if(W-i>0){
            for(int j=k+1;j<n;j++){
                genLexFixDeg(j, n, W-i, Sup, supList);
            }
        }
        else{
            supList.push_back(Sup);
            if(k==n-1){ break; }
        }
        Sup.erase_end();
    }
}

void supSet::changeIndicesAll(list<int> o2n_pattern){
    list<class sup>::iterator ite;
    for(ite = this->supList.begin(); ite != this->supList.end(); ++ite){
        (*ite).changeIndices(o2n_pattern);
    }
}
int supSet::deg(){
    
    list<class sup>::iterator ite;
    int maxDeg=0;
    int tempDeg;
    for(ite = this->supList.begin(); ite != this->supList.end(); ++ite){
        tempDeg = (*ite).deg();
        if(maxDeg < tempDeg){
            maxDeg = tempDeg;
        }
    }
    return maxDeg;
    
}
void supsetSet::changeIndicesAll(int nof, list<int> o2n_pattern){
    if(nof<1){
        errorMsg("## index is out of range");
        exit(EXIT_FAILURE);
    }
    this->supsetArray[nof].changeIndicesAll(o2n_pattern);
}
void genLexAll(int totalOfVars, int Deg, list<class sup> & supList){
    
    class sup Sup;
    supList.push_back(Sup);
    
    for(int W=1;W<=Deg;W++){
        for(int k=0;k<totalOfVars;k++){
            genLexFixDeg(k, totalOfVars, W, Sup, supList);
        }
    }
    
}

void supSet::unique(){
    //cout << endl;
    //cout << " Size of supList = " << supList.size() << endl;
    set<sup> ret;
    
    for(list<sup>::iterator ite = supList.begin();ite != supList.end();++ite){
        ret.insert(*ite);
    }
    supList.clear();
    for(set<sup>::iterator ite = ret.begin();ite != ret.end();++ite){
        supList.push_back(*ite);
    }
    //cout << " Size of supList = " << supList.size() << endl;
    //cout << endl;
}
void supSet::pushSup(class sup & newSup) {
    this->supList.push_back(newSup);
    
}

void supSet::getEvenSups(class supSet & eSups, int isUnique){
    list<class sup>::iterator ite;
    for(ite = this->supList.begin(); ite != this->supList.end(); ++ite){
        if((*ite).isEvenSup()==YES){
            eSups.pushSup(*ite);
        }
    }
    if(isUnique==YES){
        eSups.unique();
    }
}

int sup::dimvar(){
    return idx.size();
}
void sup2::setLow(double Lbound){
    this->lbd=Lbound;
}
void sup2::setUp(double Ubound){
    this->ubd=Ubound;
}

void sup::getIdxsVals(vector<int> & Idxs, vector<int> & Vals){
    if(idx.empty()){
        Idxs.clear();
        Vals.clear();
        //cout << "idx and val are empty." << endl;
        return;
    }
    int size=idx.size();
    for(int i=0;i<size;i++){
        Idxs.push_back(idx[i]);
        Vals.push_back(val[i]);
    }
    return;
}
void sup2::pushIdxVal(int Idx, int Val){
    if(Val != 0){
        this->idx.push_back(Idx);
        this->val.push_back(Val);
    }
}
void sup2::pushRL(int & R, int & L){
    this->r.push_back(R);
    this->l.push_back(L);
}
void sup2::setSup(class sup & Sup){
    
    vector<int> Idxs, Vals;
    Sup.getIdxsVals(Idxs, Vals);
    for(int i=0;i<Idxs.size();i++){
        this->idx.push_back(Idxs[i]);
        this->val.push_back(Vals[i]);
    }
}
void sup2::getSup(class sup & Sup){
    Sup.idx = idx;
    Sup.val = val;
}
int supSet2::size(){
    return this->supList.size();
}
int supSet2::dimvar(){
    return this->dimVar;
}
list<class sup2>::iterator supSet2::begin(){
    return this->supList.begin();
}
list<class sup2>::iterator supSet2::end(){
    return this->supList.end();
}
void sup2::disp(){
    int length=this->r.size();
    if(length > 0){
        cout<<endl;
        for(int i=0;i<length;i++){
            cout<<" r= "<<r[i]<<" l= "<<l[i]<<endl;
        }
    }else{
        cout << " r and l are empty." << endl;
    }
    
}
void supSet2::disp(){
    
    
    list<class sup2>::iterator supIte=this->supList.begin();
    int size=supList.size();
    
    cout<<"size of supSet2="<<size<<endl;
    
    for(int i=0;i<size;i++){
        cout<<"sup.";
        cout<<i+1;
        cout<<" : ";
        (*supIte).disp();
        ++supIte;
    }
    
    
}
void sup2::RL(vector<int> & R, vector<int> & L){
    for(int i=0;i<r.size();i++){
        R.push_back(this->r[i]);
        L.push_back(this->l[i]);
    }
}

void sup2::assignSupToArray(vector<int> & arrayData, int type){
// Return sup.val + arrayData if type = 1;
// Return sup.val - arrayData if type = -1;
    int len=val.size();
    int lenD=arrayData.size();
    
    if(type>=0){
        for(int i=0;i<len;i++){
            if(idx[i]>=lenD){
                errorMsg("## These Vector's length are different");
                exit(EXIT_FAILURE);
            }
            arrayData[idx[i]]+=val[i];
        }
    }
    if(type<0){
        for(int i=0;i<len;i++){
            if(idx[i]>=lenD){
                cout<<"659error@sup2::addDigitVal : These Vector's length are different"<<endl;
            }
            arrayData[idx[i]]-=val[i];
        }
    }
    
    
}
int sup2::deg(){
    int total = accumulate(this->val.begin(), this->val.end(), 0);
    return total;
}
int sup2::compSup(class sup & sup1){
// The value of this function is -1, 0 and 1.
// If this function returns 1, sup1 > sup2;
// If this function returns 0, sup1 = sup2;
// If this function returns -1, sup1 < sup2;
    
    class sup2 sup2;
    sup2.idx = this->idx;
    sup2.val = this->val;
    
    int size = sup1.idx.size();
    bool flag = false;
    for(int i=0; i < size; i++){
        if(sup1.idx[i] < sup2.idx[i]){
            return 1;
        }else if(sup1.idx[i] > sup2.idx[i]){
            return -1;
        }else{
            if(sup1.val[i] < sup2.val[i]){
                return -1;
            }else if(sup1.val[i] > sup2.val[i]){
                return 1;
            }else{
                flag = true;
            }
        }
    }
    if(flag){
        return 0;
    }
	return 1;/* does not reach here.*/    
    
}
void supSet2::addSup(int r, int l, class sup & newSup){
    
    list<class sup2>::iterator oldSupIte=supList.begin();
    int len=supList.size();
    class sup2 newSup2;
    
    if(len>0){
        int newDeg=newSup.deg();
        int oldDeg;
        for(;oldSupIte!=supList.end();++oldSupIte){
            oldDeg=(*oldSupIte).deg();
            if(newDeg<oldDeg){
                newSup2.setSup(newSup);
                newSup2.pushRL(r, l);
                supList.insert(oldSupIte, newSup2);
                return;
            }else if(newDeg==oldDeg){
                int v = (*oldSupIte).compSup(newSup);
                if(v == 0){
                    //cout<<"same"<<endl;
                    (*oldSupIte).pushRL(r, l);
                    return;
                }else if(v == -1){
                    //cout<<"diff1"<<endl;
                    newSup2.setSup(newSup);
                    newSup2.pushRL(r, l);
                    supList.insert(oldSupIte, newSup2);
                    return;
                }
            }
        }
    }
    newSup2.setSup(newSup);
    newSup2.pushRL(r, l);
    supList.push_back(newSup2);
    return;
}

bool supSet::doesExist(class sup & Sup){
    list<class sup>::iterator ite;
    int nVar = Sup.dimvar();
    int deg  = Sup.deg();
    int size = Sup.idx.size();
    bool flag;
    
    for(ite = supList.begin(); ite!=supList.end();++ite){
        if( (*ite).dimvar() == nVar && (*ite).idx.size() == size &&(*ite).deg()==deg){
            flag = equal((*ite).idx.begin(), (*ite).idx.end(), Sup.idx.begin());
            if(flag){
                flag = equal((*ite).val.begin(), (*ite).val.end(), Sup.val.begin());
                if(flag){
                    return true;
                }
            }
        }
    }
    return false;
}

// Return 1 if all elements of sup are even numbers.
int sup::isEvenSup(){
    for(int i=0;i<this->idx.size();i++){
        if(this->val[i]%2 !=0 ){
            return NO;
        }
    }
    return YES;
}

// add sup2 into the last position of list
void supSet2::pushSup(class sup2 & newSup2){
    supList.push_back(newSup2);
}
// return the upper bounds of sup2.
double sup2::up(){
    return this->ubd;
}
// return the lower bounds of sup2.
double sup2::low(){
    return this->lbd;
}

//clear supSet
void supSet::clear(){
    this->dimVar=0;
    this->supList.clear();
}
void supSet::setSupSet(int v, list<class sup> & suplist){
    dimVar=v;
    supList.clear();
    supList.assign(suplist.begin(), suplist.end());
}
void supSet::setSupSet(int v, set<class sup> & supset){
    
    dimVar=v;
    supList.clear();
    set<class sup>::iterator ite;
    for(ite = supset.begin(); ite != supset.end(); ++ite){
        supList.push_back(*ite);
    }
    
}
//write supports in the given file
void supSet::out_full(int k, string fName){
    
    std::ofstream fout;
    fout.open(fName.c_str(), ios::out|ios::app);
    if( fout.fail() ){
        errorMsg("## file not open for output");
        exit(EXIT_FAILURE);
    }
    
    int varsize = this->dimvar();
    int i = 0;
    
    list<class sup>::iterator ite;
    for(ite = supList.begin();ite != supList.end(); ++ite){
		fout.width(3);
        fout << k;
		fout << "-";
		fout.width(3);
		fout << i+1;
		fout << ":";
        int ell = 0;
        for(int j=0; j<varsize; j++){
            if(ell >= (*ite).idx.size()){
                fout<< "  0";
            }else{
                if((*ite).idx[ell] == j){
					fout.width(3);
                    fout<<(*ite).val[ell];
                    ell ++;
                }else{
                	fout<< "  0";
                }
            }
        }
        i++;
        fout<<endl;
    }
    fout.close();
}

void supSet::out_full(string fName){
    
    std::ofstream fout;
    fout.open(fName.c_str(), ios::out|ios::app);
    if( fout.fail() ){//
        errorMsg("## error:file not open for output");
        exit(EXIT_FAILURE);
    }
    
    int varsize = this->dimvar();
    int size = this->supList.size();
    
    fout<<varsize<<endl;
    fout<<size<<endl;
    
    vector<int> dum;
    
    list<class sup>::iterator ite = this->supList.begin();
    for(int i=0;i<size;i++){
        
        dum.clear();
        dum.resize(varsize, 0);
        (*ite).assignSupToArray(dum);
        for(int j=0;j<varsize;j++){
            fout<<" "<<dum[j];
        }
        fout<<endl;
        ++ite;
    }
    fout.close();
}
int supSet::nnz(){
    int total_nnz=0;
    list<class sup>::iterator ite = this->supList.begin();
    for(;ite!=this->supList.end(); ++ite){
        total_nnz += (*ite).idx.size();
    }
    return total_nnz;
}


bool SupMinusSup(class sup & sup1, class sup & sup2){
    // RETURN true if sup1 := sup1 - sup2 is a nonnegative integer vector..
    vector<int>::iterator it1, it2, vt1, vt2;
    if(sup2.idx.empty() && sup2.val.empty()){
        for(vt1=sup1.val.begin();vt1!=sup1.val.end();++vt1){
            if((*vt1) < 0){
                return false;
            }
        }
        return true;
    }else if(sup1.idx.empty() && sup1.val.empty()){
        sup1 = sup2;
        for(vt1=sup1.val.begin();vt1!=sup1.val.end();++vt1){
            (*vt1) = -(*vt1);
            if((*vt1) < 0){
                return false;
            }
        }
        return true;
    }
    /*
     * const int sup1_deg = sup1.deg();
     * const int sup2_deg = sup2.deg();
     * if(sup2_deg > sup1_deg){
     * return false;
     * }
     */
    //We assume that sup1 includes sup2!!!
    bool flag = includes(sup1.idx.begin(), sup1.idx.end(), sup2.idx.begin(), sup2.idx.end());
    if(!flag){
        //In this case, we do not compute sup1 - sup2.
        return false;
    }
    
    //We assume that sup1.idx == sup2.idx.
    it1 = sup1.idx.begin();
    it2 = sup2.idx.begin();
    vt2 = sup2.val.begin();
    for(vt1=sup1.val.begin();vt1!=sup1.val.end();){
        if((*it2)==(*it1)){
            (*vt1) = (*vt1) - (*vt2);
            if((*vt1) < 0){
                //In this case, we do not compute sup1 - sup2.
                return false;
            }else if((*vt1) == 0){
                it1 = sup1.idx.erase(it1);
                vt1 = sup1.val.erase(vt1);
            }else{
                ++it1;
                ++vt1;
            }
            ++it2;
            ++vt2;
            if(vt2 == sup2.val.end()){
                if(it2 == sup2.idx.end()){
                    return true;
                }else{
                    cout << "Error:" << endl;
                    cout << "The length of idx is different with the length of val." << endl;
                    sup2.disp();
                    return false;
                }
            }
        }else{
            ++it1;
            ++vt1;
        }
    }
    return true;
}
void supsetSet::removeEQU(int num, vector<int> remainIdx){
	if(remainIdx.empty() == false){
		int rsize = remainIdx.size();
		int ssize = supsetArray.size();
		int bsize = ssize -num-rsize;//polysystem has already been reduced before this function.
		
		vector<class supSet> tmpSet(rsize);
		vector<class supSet> btmpSet(bsize);
		int k=0;
		for(int i=0; i< num+rsize;i++){
			for(int j=0; j<rsize; j++){
				if(i == remainIdx[j]){
					tmpSet[k] = supsetArray[i];
					k++;
					break;
				}
			}
			supsetArray[i].clear();
		}
		for(int i=num+rsize; i<ssize; i++){
			btmpSet[i-num-rsize] = supsetArray[i];
			supsetArray[i].clear();
		}
		supsetArray.clear();
		supsetArray.resize(rsize+bsize);
		for(int i=0;i<rsize; i++){
			supsetArray[i] = tmpSet[i];
		}
		for(int i=rsize;i<rsize+bsize; i++){
			supsetArray[i] = btmpSet[i-rsize];
		}
		//cout << "After of removeEQU" << endl;
		//cout << rsize + bsize << endl;
	}

}
