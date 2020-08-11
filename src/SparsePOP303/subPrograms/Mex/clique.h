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

#ifndef _CLIQUE_
#define _CLIQUE_

#include "global.h"
void gen_maxcliques3(int msize, vector<int> oriidx, class SparseMat & extofcsp, class cliques & macls);

class cliques{
public:
    int numnode;
    int numcliques;
    vector<list<int> > clique;
    cliques();
    ~cliques();
    
    void initialize(int nodes, int csize);
    void write_maxCliques(string fname);
    int maxnnz();
};

class SparseMat{
    // Sparse matrix of MATLAB
public:
    vector<int> ir;
    vector<int> jc;
    
    SparseMat(){};
    ~SparseMat(){
        ir.clear();
        jc.clear();
    };
    void clear(){
        ir.clear();
        jc.clear();
    }
    void resizeIr(int n, int val){
        ir.resize(n, val);
    }
    void resizeJc(int m, int val){
        jc.resize(m, val);
    }
};

class EdgeSet{
public:
    int vertex1;
    int vertex2;
    EdgeSet(){
        vertex1 = 0;
        vertex2 = 0;
    };
    ~EdgeSet(){};
};

#endif /* #ifndef_CLIQUE_ */

