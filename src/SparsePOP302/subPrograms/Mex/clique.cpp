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

#include "clique.h"

cliques::cliques(){
    numnode = 0;
    numcliques = 0;
}
cliques::~cliques(){
    for(int i=0;i<clique.size();i++){
        clique[i].clear();
    }
    clique.clear();
}
void cliques::initialize(int nodes, int csize){
    this->numnode = nodes;
    this->numcliques = csize;
    clique.resize(csize);
}
int cliques::maxnnz(){
    
    int maxsize = 0;
    vector<list<int> >::iterator it=clique.begin();
    for(;it!=clique.end();++it){
        if(maxsize < (*it).size()){
            maxsize = (*it).size();
        }
    }
    return maxsize;
    
}
void cliques::write_maxCliques(string fname){
    std::ofstream fout;
    fout.open(fname.c_str(), ios::app);
    if(fout.fail()){
        errorMsg("## file does not open for output");
        exit(EXIT_FAILURE);
    }
    
    int i, maxC, minC;
    maxC = clique[0].size();
    minC = clique[0].size();
    for(i = 1; i< this->numcliques;i++){
        if(maxC < clique[i].size()){
            maxC = clique[i].size();
        }
        if(minC > clique[i].size()){
            minC = clique[i].size();
        }
    }
    list<int>::iterator it;
    fout << "# Maximal clique structure induced from csp graph" << endl;
    fout << "#Cliques = " << this->numcliques << ", maxC = " << maxC << ", minC = " << minC << endl;
    for(int j=0; j<this->numcliques;j++){
        fout << "clique " << j + 1 << " : ";
        it = clique[j].begin();
        for(;it!=clique[j].end();++it){
            fout<< (*it)+1 << " ";
        }
        fout << endl;
    }
    fout << endl;
    fout.close();
}


void gen_maxcliques3(int msize, vector<int> oriidx, class SparseMat & extofcsp, class cliques & macls){
    
    int clsize = 1;
    bool doesinc;
    int nonzeros;
    vector<bool> rowdummyIdx(msize);
    
    rowdummyIdx[0] = true;
    nonzeros = extofcsp.jc[1] - extofcsp.jc[0];
    vector<int>::iterator it1, it2, it3, it4;
	/*
	cout << "msize = " << msize << endl;
	cout << extofcsp.ir.size() << endl;
	cout << extofcsp.jc.size() << endl;
	cout << extofcsp.jc[msize] << endl;
	for(int i=0;i<extofcsp.jc[msize];i++){
		cout << "extofcsp.ir[" << i << "]=" << extofcsp.ir[i] << endl;
	}
	cout << "Finishi printing extofcsp.ir" << endl;
	cout << endl;
	for(int i=0;i<extofcsp.jc.size();i++){
		cout << "extofcsp.jc[" << i << "]=" << extofcsp.jc[i] << endl;
	}
	cout << "Finishi printing extofcsp.jc" << endl;
	*/
    for(int i=1;i<msize;i++){
        //check( inclusion relation between two cliques)
        it1 = extofcsp.ir.begin();
        doesinc = false;
        it1 = it1 + extofcsp.jc[i];
        it2 = it1 + extofcsp.jc[i+1] - extofcsp.jc[i];
        for(int j=0;j<i;j++){
            it3 = extofcsp.ir.begin();
            it3 = it3 + extofcsp.jc[j];
            it4 = it3 + extofcsp.jc[j+1] - extofcsp.jc[j];
            doesinc = includes(it3, it4, it1, it2);
            if(doesinc == true){
                break;
            }
        }
        
        //it's max clique
        if(doesinc == false){
            rowdummyIdx[i] = true;
            clsize ++;
            nonzeros += extofcsp.jc[i+1]-extofcsp.jc[i];
        }else{
            rowdummyIdx[i] = false;
        }
    }
	
	/*
	for(int i=0; i<rowdummyIdx.size(); i++){
		cout << "rowdummyIdx[" << i << "]=" << rowdummyIdx[i] << endl;
	}
	cout << "msize  = " << msize  << endl;
	cout << "clsize = " << clsize << endl;
	*/
    //generate max cliques
    macls.initialize(msize, clsize);
    
    clsize = 0;
    for(int i=0;i<msize;i++){
        if(rowdummyIdx[i] == true){
            for(int j=extofcsp.jc[i];j<extofcsp.jc[i+1];j++){
                macls.clique[clsize].push_back(oriidx[extofcsp.ir[j]]);
            }
            macls.clique[clsize].sort();
            clsize++;
        }
    }
}

bool same_edge(class EdgeSet & edge1, class EdgeSet & edge2){
    
    if(edge1.vertex1 == edge2.vertex1 && edge1.vertex2 == edge2.vertex2){
        return true;
    }
    if(edge1.vertex1 == edge2.vertex2 && edge1.vertex2 == edge2.vertex1){
        return true;
    }
    return false;
}
bool comp_edge(class EdgeSet & edge1, class EdgeSet & edge2){
    
    if(edge1.vertex2 < edge2.vertex2){
        return true;
    }else if(edge1.vertex2 == edge2.vertex2){
        if(edge1.vertex1 <= edge2.vertex1){
            return true;
        }else{
            return false;
        }
	}
    //}else if(edge1.vertex2 > edge2.vertex2){
        return false;
    //}
}

