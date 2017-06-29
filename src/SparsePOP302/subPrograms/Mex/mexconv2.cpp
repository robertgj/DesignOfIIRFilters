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

//************************************************************
//****** mexconv2 ********************************************
//************************************************************
void mexconv2(
        /*IN*/
        class s3r & POP,
        vector<int> & Oriidx,
//vector<vector<int> > Extmat,
        class SparseMat & ExtofCSP,
        /*OUT*/
        class mysdp & SDPdata
        
        ){
#ifdef DEBUG
    string  main_func_names[] = {
    "Generate maximal cliques",
    "gen_basisindices",
    "genBasisSupports",
    "initialize_polyinfo",
    "get_subjectto_polys_and_basups",
    "get_allsups",
    "initialize_supset",
    "reduceSupSets",
    "get_removes and eraseCompZeroSups",
    "get_momentmatrix_basups",
    "get_allsups_in_momentmatrix",
    "allsups, pushsups and simplifications",
    "remove_sups",
    "initialize_supset",
    "redundant_OneBounds, redundant_ZeroBouds and addBoundToPOP",
    "push_back and push",
    "get_poly_a_bass_info",
    "get_psdp",
    "remove_sups",
    "get_lsdp"
};
#endif /* #ifdef DEBUG */
/* These commands measure the size of memory used in conversin_part2 of SparsePOP.*/
/*
 * cout << "***Start " << endl;
 * int ret = 0;
 * ret = system("top -b -n 1 | grep MATLAB | head -1 |awk '{printf(\"memory = %s\\n\"), $6}' ");
 * if(ret != 0){
 * cout << "Error: system() does not work." << endl;
 * }
 */
conversion_part2(/*IN*/ POP, Oriidx, ExtofCSP, /*OUT*/ SDPdata);
/*
 * ret = system("top -b -n 1 | grep MATLAB | head -1 |awk '{printf(\"memory = %s\\n\"), $6}' ");
 * if(ret != 0){
 * cout << "Error: system() does not work." << endl;
 * }
 * cout << "***End " << endl;
 */
/* print cputime comsumed in each function of conversion_part2.*/
#ifdef DEBUG
mexPrintf("*Time(mexconv2)\n");
double conv2time = 0.0;
double t;
for(int i=0;i<20;i++){
    t = (POP.timedata[i+1] - POP.timedata[i])/(double)CLOCKS_PER_SEC;
    if(t > 1){
        mexPrintf("[%2d] %4.2f ", i, (POP.timedata[i+1]-POP.timedata[i])/(double)CLOCKS_PER_SEC);
        mexPrintf(" <-- %s\n", main_func_names[i].c_str());
    }
    conv2time += (double)(POP.timedata[i+1]-POP.timedata[i])/(double)CLOCKS_PER_SEC;
}
mexPrintf("total %4.2f\n", conv2time);
#endif /* #ifdef DEBUG */
}

//********************************************************
//** mexFuction ******************************************
//********************************************************
void mexFunction(int lnum, mxArray * ldata [], int rnum, const mxArray * rdata[]) {
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
            * params,
            * extmat,
            * oriidx;
    
    double
            * Typecone,
            * Sizecone,
            * Degree,
            * Dimvar,
            * Noterms,
            * Lo,
            * Up;
	mwIndex
		* Supir, * Supjc,
		* Coefir, * Coefjc,
		* Extir, * Extjc;
            
            double
            * Suppr,
            * Coefpr,
            * Oriidxpr;
    
    class s3r POP;
    
    typelist    = rdata[0];
    sizelist    = rdata[1];
    degreelist  = rdata[2];
    dimvarlist  = rdata[3];
    notermslist = rdata[4];
    lbdlist     = rdata[5];
    ubdlist     = rdata[6];
    supdata     = rdata[7];
    coefdata    = rdata[8];
    params      = rdata[9];
    extmat      = rdata[10];
    oriidx      = rdata[11];
    
    
    Typecone = mxGetPr(typelist);
    Sizecone = mxGetPr(sizelist);
    Degree = mxGetPr(degreelist);
    Dimvar = mxGetPr(dimvarlist);
    Noterms = mxGetPr(notermslist);
    
    Supir = mxGetIr(supdata);
    Supjc = mxGetJc(supdata);
    Suppr = mxGetPr(supdata);
    
    Coefir = mxGetIr(coefdata);
    Coefjc = mxGetJc(coefdata);
    Coefpr = mxGetPr(coefdata);
    
    Extir = mxGetIr(extmat);
    Extjc = mxGetJc(extmat);
    
    Oriidxpr = mxGetPr(oriidx);
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
    //set upper bounds-------------------------------------------
    /*
     * POP.Polysys.bounds.allocLo(POP.Polysys.dimVar);
     * POP.Polysys.boundsNew.allocLo(POP.Polysys.dimVar);
     * POP.Polysys.bounds.allocUp(POP.Polysys.dimVar);
     * POP.Polysys.boundsNew.allocUp(POP.Polysys.dimVar);
     */
    Lo = mxGetPr(lbdlist);
    Up = mxGetPr(ubdlist);
    for(int i=0;i<POP.Polysys.dimVar;i++){
        if(Lo[i] > MIN){
            POP.Polysys.bounds.setLow(i+1, Lo[i]);
            POP.Polysys.boundsNew.setLow(i+1, Lo[i]);
        }
        if(Up[i] < MAX){
            POP.Polysys.bounds.setUp(i+1, Up[i]);
            POP.Polysys.boundsNew.setUp(i+1, Up[i]);
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
    int length = 0;
    int nnzsup = mxGetNzmax(supdata);
    int nnzcoef = mxGetNzmax(coefdata);
    //mexPrintf("Start reading POPs\n");
    //mexPrintf("Polysys.numSys = %2d\n", POP.Polysys.numSys);
    //mexPrintf("nnzsup         = %2d\n", nnzsup);
    for(int p=0;p<POP.Polysys.numSys;p++){
        //mexPrintf(" %d th polynomial form \n",p);
        POP.Polysys.setPolyNoSys(p, p);
        POP.Polysys.setPolyTypeSize(p, (int)Typecone[p], (int)Sizecone[p]);
        POP.Polysys.setPolyDegree(p, (int)Degree[p]);
        POP.Polysys.setPolyDimVar(p, (int)Dimvar[p]);
        POP.Polysys.polynomial[p].noTerms = 0;
        //mexPrintf("%d --- size of supp = %d\n", p,(int)Noterms[p]);
        
        mtotal += (int)Noterms[p];
        while(m<mtotal){
            //*** generate each monomial ***
            //allocate memory for supports
            class mono Mono;
            Mono.allocSupp((int)Dimvar[p]);
            //set supports
            //mexPrintf("Supjc[%2d] = %2d\n",m, Supjc[m]);
            //mexPrintf("Supjc[%2d] = %2d\n",m+1, Supjc[m+1]);
            if(Supjc[m+1] - Supjc[m] > 0){
                while( sidx < Supjc[m+1] && sidx < nnzsup){
                    //mexPrintf("sidx = %2d\n", sidx);
                    //mexPrintf("sup ir = %d pr = %d\n",(int)Supir[sidx],(int)Suppr[sidx]);
                    Mono.setSupp((int)Supir[sidx], (int)Suppr[sidx]);
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
            for(int k=0; k< Mono.Coef.size();k++){
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
    //t2 = (double)clock();
    //mexPrintf("Reading Time = %f\n",(t2-t1)/(double)CLOCKS_PER_SEC );
    //mexPrintf("addmono Time = %f\n",s/(double)CLOCKS_PER_SEC );
    //mexPrintf("End of reading POP\n");
    
    //set extmat
    mtotal = 0;
    sidx = 0;
    //vector<vector<int> > Extmat(POP.Polysys.dimVar);
    int nnzext = mxGetNzmax(extmat);
    //int nelem = mxGetNumberOfElements(extmat);
    //mexPrintf("nDim  = %2d\n", POP.Polysys.dimVar);
    //mexPrintf("nnzext= %2d\n", nnzext);
    //mexPrintf("nelem = %2d\n", nelem);
    
    /*
     * for(int i=0;i<POP.Polysys.dimVar;i++){
     * Extmat[i].resize(POP.Polysys.dimVar,0);
     * //mexPrintf("sidx = %2d\n",sidx);
     * //mexPrintf("Extir[%2d] = %2d\n", i, Extir[i]);
     * //mexPrintf("Extjc[%2d] = %2d\n", i+1, Extjc[i+1]);
     * while(sidx < Extjc[i+1] && sidx < nnzext){
     * Extmat[i][Extir[sidx]] = 1;
     * sidx++;
     * }
     * }
     */
    class SparseMat ExtofCSP;
    ExtofCSP.resizeIr(nnzext, 0);
    ExtofCSP.resizeJc(POP.Polysys.dimVar+1, 0);
    for(int i=0; i<nnzext; i++){
        ExtofCSP.ir[i] = Extir[i];
    }
    for(int j=0; j<POP.Polysys.dimVar+1; j++){
        ExtofCSP.jc[j] = Extjc[j];
    }
    //mexPrintf("End of Extmat\n");
    
    
    vector<int> Oriidx(POP.Polysys.dimVar);
    for(int i=0;i<POP.Polysys.dimVar;i++){
        Oriidx[i] = (int)Oriidxpr[i]-1;
    }
    //mexPrintf("End of Oriidx\n");
    
    int nDim = POP.Polysys.dimVar;
    POP.Polysys.posOflbds.resize(nDim);
    POP.Polysys.posOfubds.resize(nDim);
    /*
     * for(int i=0; i < nDim; i++){
     * POP.Polysys.posOflbds[i].resize(nDim+1,0);
     * POP.Polysys.posOfubds[i].resize(nDim+1,0);
     * }
     */
    POP.degOneTerms.resize(nDim, 0);
    
    int lbdnnz, ubdnnz, row, col, val, Ncol, idx;
	mwIndex
		* lbdIdxir, * lbdIdxjc,
		* ubdIdxir, * ubdIdxjc;
            
            double
            * lbdIdxpr,
            * ubdIdxpr;
    
    lbdnnz   = mxGetNzmax(rdata[12]);
    lbdIdxir = mxGetIr(rdata[12]);
    lbdIdxjc = mxGetJc(rdata[12]);
    lbdIdxpr = mxGetPr(rdata[12]);
    ubdnnz   = mxGetNzmax(rdata[13]);
    ubdIdxir = mxGetIr(rdata[13]);
    ubdIdxjc = mxGetJc(rdata[13]);
    ubdIdxpr = mxGetPr(rdata[13]);
    
    
    
    //mexPrintf("rdata[12]\n");
    //mexPrintf("nnz = %2d\n", lbdnnz);
    int nnz0 = 0;
    Ncol = mxGetN(rdata[12]);
    for(int i=0; i < Ncol;i++){
        for(int j = 0; j < lbdIdxjc[i+1] - lbdIdxjc[i]; j++){
            idx = lbdIdxjc[i] + j;
            val = (int) lbdIdxpr[idx];
            col = i;
            row = lbdIdxir[idx];
            if(val > 1.0e-5){
                //mexPrintf("row = %2d, col = %2d, val = %2d\n", row,col,val);
                //POP.Polysys.posOflbds[row][col] = val;
                POP.Polysys.posOflbds[row].push_back(val);
                nnz0 = nnz0 + 1;
            }
            if(nnz0 == lbdnnz){
                break;
            }
        }
        if(nnz0 == lbdnnz){
            break;
        }
    }
    
    //mexPrintf("rdata[13]\n");
    //mexPrintf("nnz = %2d\n", ubdnnz);
    nnz0 = 0;
    Ncol = mxGetN(rdata[13]);
    for(int i=0; i < Ncol;i++){
        for(int j = 0; j < ubdIdxjc[i+1] - ubdIdxjc[i]; j++){
            idx = ubdIdxjc[i] + j;
            val = (int) ubdIdxpr[idx];
            if(val > 1.0e-5){
                row = ubdIdxir[idx];
                col = i;
                //mexPrintf("row = %2d, col = %2d, val = %2d\n", row,col,val);
                //POP.Polysys.posOfubds[row][col] = val;
                POP.Polysys.posOfubds[row].push_back(val);
                nnz0 = nnz0 + 1;
            }
            if(nnz0 == ubdnnz){
                break;
            }
        }
        if(nnz0 == ubdnnz){
            break;
        }
    }
    //mexPrintf("End of setting posOflbds and posOfubds.\n");
    /*
     * for(int i=0;i < POP.Polysys.dimVar;i++){
     * //mexPrintf("lbd size  = %d\n",POP.Polysys.posOflbds.size());
     * //mexPrintf("ubd size  = %d\n",POP.Polysys.posOfubds.size());
     * for(int j=0; j<POP.Polysys.dimVar+1; j++){
     * if(POP.Polysys.posOflbds[i][j] > 1.0e-5){
     * //mexPrintf("lbdIdx[%2d][%2d] = %2d\n",i,j,POP.Polysys.posOflbds[i][j]);
     * }
     * if(POP.Polysys.posOfubds[i][j] > 1.0e-5){
     * //mexPrintf("ubdIdx[%2d][%2d] = %2d\n",i,j,POP.Polysys.posOfubds[i][j]);
     * }
     * }
     * }
     */
    //mexPrintf("End of outputting posOflbds and posOfubds.\n");
    
    class mysdp SDPdata;
    
    //**************************************************
    //      mex conversion part2
    mexconv2( POP, Oriidx, ExtofCSP, SDPdata );
    //mexconv2( POP,Oriidx,Extmat,SDPdata );
    //**************************************************
    
    //set SDPdata
    int dim = 1;
	mwIndex * dims = new mwIndex[1];
	dims[0] = 1;
    
    int nfields = 6;
    const char * field_names [] = {"blockStruct", "typeCone", "nBlock", "mDim", "bVect", "sparseMatrix" };
    ldata[0] = mxCreateStructArray(dim, dims, nfields, field_names);
    
    double
            * Blockstruct,
            * Types,
            * BVect,
            * SpaMat;
    
    int elements = 0;
    for(int i=1;i<=SDPdata.nBlocks;i++){
        for(int j=SDPdata.block_info[0][i];j<SDPdata.block_info[0][i] + SDPdata.block_info[1][i];j++){
            elements++;
        }
    }
    
    mxSetField( ldata[0], 0, "mDim",          mxCreateDoubleScalar((double)SDPdata.mDim));
    mxSetField( ldata[0], 0, "nBlock",          mxCreateDoubleScalar((double)SDPdata.nBlocks));
    mxSetField( ldata[0], 0, "blockStruct",     mxCreateDoubleMatrix(1, SDPdata.nBlocks, mxREAL));
    mxSetField( ldata[0], 0, "typeCone",        mxCreateDoubleMatrix(1, SDPdata.nBlocks, mxREAL));
    mxSetField( ldata[0], 0, "bVect",           mxCreateDoubleMatrix(1, SDPdata.mDim, mxREAL));
    mxSetField( ldata[0], 0, "sparseMatrix",    mxCreateDoubleMatrix(elements, 5, mxREAL));
    
    Blockstruct = mxGetPr(mxGetField(ldata[0], 0, "blockStruct"));
    Types       = mxGetPr(mxGetField(ldata[0], 0, "typeCone"));
    BVect       = mxGetPr(mxGetField(ldata[0], 0, "bVect"));
    SpaMat      = mxGetPr(mxGetField(ldata[0], 0, "sparseMatrix"));
    
    for(int i=0;i<SDPdata.mDim;i++){
        BVect[i] = 0;
    }
	//mexPrintf("*** in mexconv2.cpp *** \n");
	/*
	for(int i=0;i<SDPdata.block_info.size();i++){
		for(int j=0; j<SDPdata.block_info[i].size();j++){
			mexPrintf("SDPdata.block_info[%d][%d] = %d\n", i, j, SDPdata.block_info[i][j]);
		}
	}
	mexPrintf("mDim = %d\n", SDPdata.mDim);
	*/
    for(int i=SDPdata.block_info[0][0];i<SDPdata.block_info[0][0] + SDPdata.block_info[1][0];i++){
		int idx = SDPdata.ele.sup.pnz[0][i];
		//mexPrintf("idx   = %d\n",SDPdata.ele.sup.pnz[0][i]);
		//mexPrintf("bvect = %f\n",SDPdata.ele.coef[i]);
		if(idx > 0){
			idx = idx -1;
		}
		BVect[idx] = SDPdata.ele.coef[i];
    }
    
    int bst = elements  ;
    int ist = elements << 1;
    int jst = elements*3;
    int cst = elements << 2;
    elements = 0;
   	 
    for(int i=1;i<=SDPdata.nBlocks;i++){
		//mexPrintf("i = %d\n", i);
		//mexPrintf("bLOCKsTruct[%d]   = %d\n", i, SDPdata.bLOCKsTruct[i]);
        //mexPrintf("block_info[0][%d] = %d\n", i, SDPdata.block_info[0][i]);
        //mexPrintf("block_info[0][%d] = %d\n", i, SDPdata.block_info[1][i]);
		Blockstruct[i-1] = (double)SDPdata.bLOCKsTruct[i];
        Types[i-1]       = (double)SDPdata.block_info[2][i];
    	    
        for(int j=SDPdata.block_info[0][i];j<SDPdata.block_info[0][i] + SDPdata.block_info[1][i];j++){
			//mexPrintf("SDPdata.ele.sup.pnz[0][%d] = %d\n", j, SDPdata.ele.sup.pnz[0][j]);
            if(SDPdata.ele.sup.pnz[0][j] >= 0){
                SpaMat[elements      ] = SDPdata.ele.sup.pnz[0][j];
                SpaMat[elements + bst] = SDPdata.ele.bij[0][j];
                SpaMat[elements + ist] = SDPdata.ele.bij[1][j];
                SpaMat[elements + jst] = SDPdata.ele.bij[2][j];
                SpaMat[elements + cst] = SDPdata.ele.coef[j];
                elements ++;
            }
        }
    }
    //ldata[1] = mxCreateDoubleScalar(POP.linearterms);
    int tidx=0;
    for(int i =0; i < POP.Polysys.dimVar;i++){
        if(POP.degOneTerms[i] !=0){
            //mexPrintf("Monomial with one degree = %d\n",POP.degOneTerms[i]);
            tidx++;
        }
    }
    //mexPrintf(" = %d\n",tidx);
    ldata[1] = mxCreateDoubleMatrix(tidx, 1, mxREAL);//(POP.degOneTerms);
    double *degOne = mxGetPr(ldata[1]);
    for(int i =0; i < tidx;i++){
        if(POP.degOneTerms[i] !=0){
            degOne[i] = POP.degOneTerms[i];
            //mexPrintf("Monomial with one degree = %d\n",POP.degOneTerms[i]);
            //mexPrintf("Monomial with one degree = %d\n",degOne[i]);
        }
    }
    
    //nDim == POP.Polysys.dimVar;
    //int mtotal;
    //int nnz = ;
    // 2010-01-09 H.Waki sparse matrix version
    int nnz = POP.xIdxVec.vap_size;
    int mDim= POP.xIdxVec.pnz_size;
    ldata[2] = mxCreateSparse(nDim, mDim, nnz, mxREAL);
	mwIndex
		*irs, *jcs;
	double *sr;
    sr = mxGetPr(ldata[2]);
    irs= mxGetIr(ldata[2]);
    jcs= mxGetJc(ldata[2]);
    int count = 0;
    
    for(int i=0;i<nnz;i++){
        sr[i] = 0;
        irs[i] = 0;
    }
    jcs[0] = 0;
    for(int i=0; i<POP.xIdxVec.pnz_size; i++){
        if(POP.xIdxVec.pnz[0][i] >= 0){
            for(int j=0; j<POP.xIdxVec.pnz[1][i];j++){
                idx = POP.xIdxVec.pnz[0][i] + j;
                irs[count] = POP.xIdxVec.vap[0][idx];
                sr[count] = POP.xIdxVec.vap[1][idx];
                count++;
            }
        }
        jcs[i+1] = count;
    }
    //jcs[mDim] = nnz;
    
    /*
     * for(int i=0;i<nDim;i++){
     * for(int j=0; j<mDim; j++){
     * irs[count] = i;
     * sr[count] = ;
     * count++;
     * }
     * jcs[i] = count;
     * }
     * jcs[nDim] = nnz;
     */
    
    // 2010-01-09 H.Waki dense matrix version
    /*
     * int mDim = POP.xIdxVec.size();
     * ldata[2] = mxCreateDoubleMatrix(mDim, nDim, mxREAL);
     * double *xIdxVec = mxGetPr(ldata[2]);
     * for(int i=0; i<nDim; i++){
     * for(int j=0; j<mDim; j++){
     * xIdxVec[i*mDim + j] = POP.xIdxVec[j][i];
     * }
     * }
     */
    delete [] dims;
	ldata[3] = mxCreateDoubleScalar(POP.Polysys.objConst);
    //mexPrintf("### Finish mexconv2 ###\n");
    return;
}
