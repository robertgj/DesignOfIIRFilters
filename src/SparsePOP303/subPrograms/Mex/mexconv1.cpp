/* -------------------------------------------------------------
 *
 * This file is a component of SparsePOP
 * Copyright (C) 2007-2011 SparsePOP Project
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

#include "global.h"
#include "sup.h"
#include "polynomials.h"
#include "spvec.h"
#include "conversion.h"
#include "Parameters.h"

//*********************************************************
//                      mexconv1
//*********************************************************
void mexconv1(
        
        /*IN*/
        class s3r & POP,
        double    & objconst,
        int       & slen,
        vector<double> & scalevalue,
        int       & blen,
        vector<double> & bvect,
        int       & mlen,
        vector<double> & permmatrix
        ){
    /*
     * cout << "***Start " << endl;
     * system("top d 1 n 1 b | grep MATLAB | head -1 |awk '{printf(\"memory = %s\\n\"), $6}' ");
     */
    conversion_part1(POP, objconst, slen, scalevalue, blen, bvect, mlen, permmatrix);
    /*
     * system("top d 1 n1 b | grep MATLAB | head -1 |awk '{printf(\"memory = %s\\n\"), $6}' ");
     * cout << "***End " << endl;
     */
#ifdef DEBUG
double totaltime = 0;
mexPrintf("*Time(mexconv1)\n");
double t;
for(int i=0;i<9;i++){
    t = (POP.timedata1[i+1] - POP.timedata1[i])/(double)CLOCKS_PER_SEC;
    if(t > 1){
        mexPrintf("[%2d] %2.2f\n", i, (POP.timedata1[i+1]-POP.timedata1[i])/(double)CLOCKS_PER_SEC);
    }
    totaltime += (double)(POP.timedata1[i+1] - POP.timedata1[i])/(double)CLOCKS_PER_SEC;
}
mexPrintf("total %2.2f\n", totaltime);
#endif /* #ifdef DEBUG */
}

//**********************************************************
//                      mexFuction
//**********************************************************
void mexFunction(int lnum, mxArray * ldata [], int rnum, const mxArray * rdata[]) {
    
    //printf("*** mexFunction( mexconv1 ) ***\n");
    // printf("num o input = %d\n",rnum);
    // printf("num o output = %d\n",lnum);
    
    // printf("*** SET POP ***\n");
    // printf("\n");
    
    const mxArray
            * typelist,
            * sizelist,
            * degreelist,
            * dimvarlist,
            * notermslist,
            * supdata,
            * coefdata,
            * lbdlist,
            * ubdlist,
            * params;
    
    class s3r POP;
    
    typelist = rdata[0];
    sizelist = rdata[1];
    degreelist = rdata[2];
    dimvarlist = rdata[3];
    notermslist = rdata[4];
    lbdlist = rdata[5];
    ubdlist = rdata[6];
    supdata = rdata[7];
    coefdata = rdata[8];
    params =rdata[9];
    
    //printf("set data\n");
    
    double *Typecone = mxGetPr(typelist);
    double *Sizecone = mxGetPr(sizelist);
    double *Degree = mxGetPr(degreelist);
    double *Dimvar = mxGetPr(dimvarlist);
	double *Noterms = mxGetPr(notermslist);
	mwIndex *Supir = mxGetIr(supdata);
	mwIndex *Supjc = mxGetJc(supdata);
	double  *Suppr = mxGetPr(supdata);
	mwIndex *Coefir = mxGetIr(coefdata);
	mwIndex *Coefjc = mxGetJc(coefdata);
	double *Coefpr = mxGetPr(coefdata);
    
	#ifdef DEBUG
	POP.param.disp_parameters();
	#endif
	POP.param.mxSetParameters(params);
	#ifdef DEBUG
	POP.param.disp_parameters();
	#endif

    //set dimension of variables and number of object function
    POP.Polysys.allocSys((int)Dimvar[0] , (int)mxGetN(rdata[0]));
    
    //set lower bounds-------------------------------------------
    //POP.Polysys.bounds.allocLo(POP.Polysys.dimVar);
    double *Lo = mxGetPr(lbdlist);
    for(int i=0;i<POP.Polysys.dimVar;i++){
        //mexPrintf("Lo[%d] = %f\n",i,Lo[i]);
        if(Lo[i] > MIN){
            POP.Polysys.bounds.setLow(i+1, Lo[i]);
            //mexPrintf("Lo[%d] = %f\n",i,Lo[i]);
        }
    }
    
    //set upper bounds-------------------------------------------
    //POP.Polysys.bounds.allocUp(POP.Polysys.dimVar);
    double *Up = mxGetPr(ubdlist);
    for(int i=0;i<POP.Polysys.dimVar;i++){
        if(Up[i] < MAX){
            POP.Polysys.bounds.setUp(i+1, Up[i]);
            //mexPrintf("Up[%d] = %f\n",i,Up[i]);
        }
    }
    
    //double t1, t2;
    //double s, s1, s2;
    //s = 0;
    //t1 = (double)clock();
    //set objective function and constraints -------------------
    int m, cf, mtotal, sidx, cidx, len;
    m    = 0;
    cf   = 0;
    len  = 0;
    mtotal = 0;
    sidx = 0;
    cidx = 0;
    bool flag;
    int nnzsup = mxGetNzmax(supdata);
    int nnzcoef = mxGetNzmax(coefdata);
    for(int p=0;p<POP.Polysys.numSys;p++){
        //mexPrintf(" %d th polynomial form (terms = %d) \n",p,(int)Noterms[p]);
        POP.Polysys.setPolyNoSys(p, p);
        POP.Polysys.setPolyTypeSize(p, (int)Typecone[p], (int)Sizecone[p]);
        POP.Polysys.setPolyDegree(p, (int)Degree[p]);
        POP.Polysys.setPolyDimVar(p, (int)Dimvar[p]);
        mtotal += (int)Noterms[p];
        while(m<mtotal){
            //*** generate each monomial ***
            //allocate memory for supports
            class mono Mono;
            Mono.allocSupp((int)Dimvar[p]);
            //set supports
            //mexPrintf("%d --- size of supp = %d\n", p,(int)Noterms[p]);
            if(Supjc[m+1] - Supjc[m] > 0){
                while( sidx < Supjc[m+1] && sidx < nnzsup){
                    //mexPrintf("sup ir = %d pr = %d\n",(int)Supir[sidx],(int)Suppr[sidx]);
                    Mono.setSupp((int)Supir[sidx], (int)Suppr[sidx]);
                    //cout << "Supir = " << Supir[sidx] << ", Suppr = " << Suppr[sidx] << endl;
                    sidx++;
                }
                Mono.sortMono();
            }
            //set coefficient
            if((int)Typecone[p] != 3){
                Mono.allocCoef( (int)Sizecone[p] );
            }
            else{
                Mono.allocCoef( (int)(Sizecone[p]*Sizecone[p]) );
            }
            if(Coefjc[m+1] - Coefjc[m] > 0){
                while(cidx < Coefjc[m+1] && cidx < nnzcoef){
                    Mono.setCoef(Coefpr[cidx], Coefir[cidx]);
                    cidx++;
                }
            }
            //s1 = (double)clock();
            flag = false;
            for(int k=0; k< Mono.Coef.size(); k++){
                if(fabs(Mono.Coef[k]) > EPS){
                    flag = true;
                    break;
                }
            }
            if(flag){
                POP.Polysys.polynomial[p].monoList.push_back(Mono);
                POP.Polysys.polynomial[p].noTerms++;
            }
            //s2 = (double)clock();
            //s = s + (s2 -s1);
            m++;
        }
    }
    //POP.Polysys.writePolynomials();
    //t2 = (double)clock();
    //mexPrintf("Reading Time = %f\n",(t2-t1)/(double)CLOCKS_PER_SEC );
    //mexPrintf("addmono Time = %f\n",s/(double)CLOCKS_PER_SEC );
    //mexPrintf("End of reading POP\n");
    
    int nDim = POP.Polysys.dimVar;
    // NO. of constraints "x_i >= l_i" and "x_i <= u_i"  in POP
    POP.Polysys.posOflbds.resize(nDim);
    POP.Polysys.posOfubds.resize(nDim);
    POP.degOneTerms.resize(nDim, 0);
    
    // printf("\n");
    //*** mexconv1 *************************************
    
    int      slen=0;
    int      blen=0;
    int      mlen=0;
    double   objconst=0;
    vector<double> scalevalue;
    vector<double> bvect;
    vector<double> permmatrix;
    
    // printf("*** mexconv1 *** \n");
    mexconv1( POP, objconst, slen, scalevalue, blen, bvect, mlen, permmatrix );
    
    //printf("numsys = %d\n",POP.Polysys.numSys);
    //printf("*** succeeded *** \n\n");
    //***********************************************
    
    double
            * NewType,
            * NewSize,
            * NewDeg,
            * NewDim,
            * NewNoterms,
            * NewLo,
            * NewUp,
            * Scalevalue;
    
	mwIndex
		* NewSupir, * NewSupjc,
		* NewCoefir, * NewCoefjc,
		* Bveir, * Bvejc,
		* Permir, * Permjc,
		* Cspir, * Cspjc;
            
            double
            * NewSuppr,
            * NewCoefpr,
            * Bvepr,
            * Permpr,
            * Csppr;
    
    int ir, ir2;
    int limit;
    
    ldata[0] = mxCreateDoubleMatrix(1, POP.Polysys.numSys, mxREAL);
    ldata[1] = mxCreateDoubleMatrix(1, POP.Polysys.numSys, mxREAL);
    ldata[2] = mxCreateDoubleMatrix(1, POP.Polysys.numSys, mxREAL);
    ldata[3] = mxCreateDoubleMatrix(1, POP.Polysys.numSys, mxREAL);
    ldata[4] = mxCreateDoubleMatrix(1, POP.Polysys.numSys, mxREAL);
    ldata[5] = mxCreateDoubleMatrix(1, POP.Polysys.dimVar, mxREAL);
    ldata[6] = mxCreateDoubleMatrix(1, POP.Polysys.dimVar, mxREAL);
    
    NewType    = mxGetPr(ldata[0]);
    NewSize    = mxGetPr(ldata[1]);
    NewDeg     = mxGetPr(ldata[2]);
    NewDim     = mxGetPr(ldata[3]);
    NewNoterms = mxGetPr(ldata[4]);
    NewLo      = mxGetPr(ldata[5]);
    NewUp      = mxGetPr(ldata[6]);
    
    //Set ldata[0](new_notermslist)
    
    //printf("new_notermslist\n");
    for(int p=0;p<POP.Polysys.numSys;p++){
        //       printf("degree = %d\n",POP.Polysys.polynomial[p].degree);
        //       printf("dimvar = %d\n",POP.Polysys.polynomial[p].dimVar);
        //       printf("noterms = %d\n",POP.Polysys.polynomial[p].noTerms);
        //       printf("[ %d ] poly ",p);
        NewType[p] = (double)POP.Polysys.polyTypeCone(p);//printf(" t");
        NewSize[p] = POP.Polysys.polySizeCone(p);//printf(" s");
        NewDim[p]  = (double)POP.Polysys.polyDimvar(p);//printf(" dm");
        NewNoterms[p] = POP.Polysys.polyNoterms(p);//printf(" nt\n");
        NewDeg[p]  = (double)POP.Polysys.polyDegree(p);//printf(" dg");
    }
    
    
    //Set ldata[1](new_lbdlist) and ldata[2](new_ubdlist)
    
    //printf("new_lbd and ubdlist\n");
    for(int d=0;d<POP.Polysys.dimVar;d++){
        // printf("[ %2d ] %lf %lf\n",d,POP.Polysys.boundsNew.lbd(d),POP.Polysys.boundsNew.ubd(d));
        NewLo[d] = POP.Polysys.boundsNew.lbd(d);
        NewUp[d] = POP.Polysys.boundsNew.ubd(d);
    }
    
    //Set ldata[3](new_supdata) and ldata[4](new_coefdata)
    
    // printf("new_sup and coef data\n");
    int supnnz = 0;
    list<class mono>::iterator ite;
    
    mtotal = 0;
    
    int maxcsize = 1;
    int coefnnz = 0;
    for(int p=0;p<POP.Polysys.numSys;p++){
        
        supnnz += POP.Polysys.polySupNnz(p);
        coefnnz += POP.Polysys.polyCoefNnz(p);
        
        if(NewType[p] == 3){
            if(maxcsize < NewSize[p]*NewSize[p]){
                maxcsize = (int)(NewSize[p]*NewSize[p]);
            }
        }
        
        mtotal += POP.Polysys.polyNoterms(p);
        
    }
    
    //printf("maxcsize = %d coefnnz = %d\n",maxcsize,coefnnz);
    
    ldata[7] = mxCreateSparse(POP.Polysys.dimVar, mtotal , supnnz, mxREAL);
    ldata[8] = mxCreateSparse(maxcsize, mtotal, coefnnz, mxREAL);
    
    NewSupir = mxGetIr(ldata[7]);
    NewSupjc = mxGetJc(ldata[7]);
    NewSuppr = mxGetPr(ldata[7]);
    
    NewCoefir = mxGetIr(ldata[8]);
    NewCoefjc = mxGetJc(ldata[8]);
    NewCoefpr = mxGetPr(ldata[8]);
    
    int sw = 1;
    mtotal = 0;
    sidx = 0;
    cidx = 0;
    vector<int>::iterator iit;
    vector<int>::iterator vit;
    //mexPrintf("# of polys = %2d\n",POP.Polysys.numSys);
    for(int p=0;p<POP.Polysys.numSys;p++){
        //POP.Polysys.polynomial[p].writePolyData();
        ite = POP.Polysys.polynomial[p].monoList.begin();
        //mexPrintf("noterm = %d\n",(int)NewNoterms[p]);
        for(m=0;m<NewNoterms[p];m++){
            
            NewSupjc [ m + mtotal ] = sidx;
            NewCoefjc[ m + mtotal ] = cidx;
            //cout << "Mono ";
            //(*ite).printSupp();
            //cout << endl;
            vit = (*ite).supVal.begin();
            for(iit=(*ite).supIdx.begin();iit!=(*ite).supIdx.end();++iit){
                NewSupir[sidx] = (*iit);
                NewSuppr[sidx] = (double)(*vit);
                //cout << "(*iit) = " << (*iit) << " (*vit) = " << (*vit) << endl;
                sidx++;
                ++vit;
            }
            if(NewType[p] != 3){
                NewCoefir[cidx] = 0;
                NewCoefpr[cidx] = (*ite).Coef[0];
                cidx++;
            }
            else{
                for(int j=0;j<(*ite).Coef.size();j++){
                    if((*ite).Coef[j]!=0.0){
                        NewCoefir[cidx] = j;
                        NewCoefpr[cidx] = (*ite).Coef[j];
                        cidx++;
                    }
                }
            }
            ++ite;
        }
        mtotal += (int) NewNoterms[p];
    }
    
    NewSupjc [mtotal] = sidx;
    NewCoefjc[mtotal] = cidx;
    
    //set objconst
    ldata[9] = mxCreateDoubleScalar(objconst);
    
    //printf("set scalevalue slen = %d\n",slen);
    //set scalevalue
    ldata[10] = mxCreateDoubleMatrix(1, slen, mxREAL);
    Scalevalue = mxGetPr(ldata[10]);
    
    for(int i=0;i<slen;i++){
        //   printf("i=%d\n scale value = %lf\n",i,scalevalue[i]);
        Scalevalue[i] = scalevalue[i];
    }
    
    // printf("set bvect\n");
    //set bvect
    ldata[11] = mxCreateDoubleMatrix(POP.Polysys.dimVar, 1, mxREAL);
    Bvepr = mxGetPr(ldata[11]);
    for(int i=0;i<POP.Polysys.dimVar;i++){
        Bvepr[i] = bvect[i];
    }
    
    //printf("set perm matrix\n");
    //set perm matrix
    ldata[12] = mxCreateSparse(POP.Polysys.dimVar, POP.Polysys.dimVar, POP.Polysys.dimVar, mxREAL);
    Permir = mxGetIr(ldata[12]);
    Permjc = mxGetJc(ldata[12]);
    Permpr = mxGetPr(ldata[12]);
    
    sidx = 0;
    
    for(int i=0;i<POP.Polysys.dimVar;i++){
        Permjc[i] = sidx;
        //for(int j=0;j<POP.Polysys.dimVar;j++){
        //if(permmatrix[i+j*POP.Polysys.dimVar] != 0){
        //Permir[sidx] = j;
        Permir[sidx] = i;
        //Permpr[sidx] = permmatrix[i+j*POP.Polysys.dimVar];
        Permpr[sidx] = permmatrix[i];
        sidx++;
        //}
        //}
    }
    //mexPrintf("sidx = %d mlen = %d\n",sidx,nnz);
    Permjc[POP.Polysys.dimVar] = sidx;
    
   //printf("set CSP Matrix\n");
    
    if(POP.param.sparseSW == 1){
        int numOfNoterms0 = (int) NewNoterms[0];
        vector<list<int> > SetOfEdges(POP.Polysys.numSys+numOfNoterms0-1);
        list<mono>::iterator it =  POP.Polysys.polynomial[0].monoList.begin();
        for(int i=0;i<numOfNoterms0;i++){
            for(int j=0;j<(*it).supIdx.size();j++){
                SetOfEdges[i].push_back((*it).supIdx[j]);
            }
            ++it;
        }
        for(int i=0;i<POP.Polysys.numSys-1;i++){
            POP.Polysys.polynomial[i+1].sumSupports(SetOfEdges[i+numOfNoterms0]);
        }
        list<EdgeSet> edgeset;
        list<int>::iterator it1, it2;
        for(int i=0; i< numOfNoterms0+POP.Polysys.numSys-1;i++){
            it1 = SetOfEdges[i].begin();
            for(;it1!=SetOfEdges[i].end();++it1){
                for(it2 = it1;it2!=SetOfEdges[i].end();++it2){
                    class EdgeSet edge;
                    edge.vertex1 = (*it2);
                    edge.vertex2 = (*it1);
                    edgeset.push_back(edge);
                }
            }
            SetOfEdges[i].clear();
        }
	for(int i=0; i<POP.Polysys.dimVar; i++){
                    class EdgeSet edge;
                    edge.vertex1 = i;
                    edge.vertex2 = i;
                    edgeset.push_back(edge);
	}
        SetOfEdges.clear();
        edgeset.sort(comp_edge);
        edgeset.unique(same_edge);
        /*
          cout << "Edge Set " << endl;
          list<EdgeSet>::iterator eit=edgeset.begin();
          for(;eit!=edgeset.end();++eit){
          cout <<"(" << (*eit).vertex1 << "," << (*eit).vertex2 << ")" << endl;
          }
         */
        mlen = edgeset.size();
        ldata[13] = mxCreateSparse(POP.Polysys.dimVar, POP.Polysys.dimVar, mlen, mxREAL);
        Cspir = mxGetIr(ldata[13]);
        Cspjc = mxGetJc(ldata[13]);
        Csppr = mxGetPr(ldata[13]);
        //cout << "mlen = " << mlen << endl;
        
        int col = 0;
        cidx = 0;
        double val = 0;
        for(list<EdgeSet>::iterator eit=edgeset.begin();eit!=edgeset.end();){
            Cspjc[col] = cidx;
            while(eit != edgeset.end() && (*eit).vertex2 == col){
                Cspir[cidx] = (*eit).vertex1;
                if((*eit).vertex1 == (*eit).vertex2){
                    Csppr[cidx] = (double)6*POP.Polysys.dimVar;
                }else{
                    val = (double)(1+rand()%100000)/100000;
                    Csppr[cidx] = val;
                }
                cidx++;
                ++eit;
            }
            col++;
            if(col >= POP.Polysys.dimVar){
                break;
            }
        }
        Cspjc[col] = cidx;
        edgeset.clear();
        
    }else{
        ldata[13] = mxCreateSparse(POP.Polysys.dimVar, POP.Polysys.dimVar, POP.Polysys.dimVar, mxREAL);
        Cspir = mxGetIr(ldata[13]);
        Cspjc = mxGetJc(ldata[13]);
        Csppr = mxGetPr(ldata[13]);
        
        for(int i=0;i<POP.Polysys.dimVar;i++){
            Cspjc[i] = i;
            Cspir[i] = i;
            Csppr[i] = 1;
        }
        Cspjc[POP.Polysys.dimVar] = POP.Polysys.dimVar;
    }
    int lbdnnz, ubdnnz;
	mwIndex * lbdIdxir, * lbdIdxjc, * ubdIdxir, * ubdIdxjc;
            double * lbdIdxpr, * ubdIdxpr;
    
    lbdnnz = 0;
    ubdnnz = 0;
    nDim = POP.Polysys.dimVar;
    for(int i=0; i<nDim; i++){
        lbdnnz = lbdnnz+POP.Polysys.posOflbds[i].size();
        ubdnnz = ubdnnz+POP.Polysys.posOfubds[i].size();
    }
    
    ldata[14] = mxCreateSparse(nDim, nDim+1, lbdnnz, mxREAL);
    ldata[15] = mxCreateSparse(nDim, nDim+1, ubdnnz, mxREAL);
    lbdIdxpr = mxGetPr(ldata[14]);
    lbdIdxir = mxGetIr(ldata[14]);
    lbdIdxjc = mxGetJc(ldata[14]);
    ubdIdxpr = mxGetPr(ldata[15]);
    ubdIdxir = mxGetIr(ldata[15]);
    ubdIdxjc = mxGetJc(ldata[15]);
    
    lbdnnz = 0;
    ubdnnz = 0;
    vector<bool> flagl(nDim);
    vector<bool> flagu(nDim);
    int check = 0;
    for(int j=0; j<nDim;j++){
        flagl[j] = true;
        flagu[j] = true;
    }
    list<int>::iterator lit, uit;
    for(int i=0; i<nDim+1; i++){
        lbdIdxjc[i] = lbdnnz;
        ubdIdxjc[i] = ubdnnz;
        if(check != 2*nDim){
            for(int j=0; j<nDim; j++){
                if(flagl[j] && POP.Polysys.posOflbds[j].empty()){
                    flagl[j] = false;
                }else if(flagl[j]){
                    lit = POP.Polysys.posOflbds[j].begin();
                    advance(lit, i);
                    if(lit != POP.Polysys.posOflbds[j].end()){
                        lbdIdxpr[lbdnnz] = (*lit);
                        lbdIdxir[lbdnnz] = j;
                        lbdnnz++;
                    }else{
                        flagl[j] = false;
                        check++;
                    }
                }
                if(flagu[j] && POP.Polysys.posOfubds[j].empty()){
                    flagu[j] = false;
                }else if(flagu[j]){
                    uit = POP.Polysys.posOfubds[j].begin();
                    advance(uit, i);
                    if(uit != POP.Polysys.posOfubds[j].end()){
                        ubdIdxpr[ubdnnz] = (*uit);
                        ubdIdxir[ubdnnz] = j;
                        ubdnnz++;
                    }else{
                        flagu[j] = false;
                        check++;
                    }
                }
            }
        }
    }
    lbdIdxjc[nDim+1] = lbdnnz;
    ubdIdxjc[nDim+1] = ubdnnz;
    //mexPrintf("End of outputting lbdIdx and ubdIdx\n");
    return;
}
