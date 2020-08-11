/*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is a component of SparseCoLO 
% Copyright (C) 2009 
% Masakazu Kojima Group
% Department of Mathematical and Computing Sciences
% Tokyo Institute of Technology
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*/

#define PRINT_ESSENTIAL 0
#define PRINT_DEBUG 0
#define PRINT_TIME  0
#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cmath> // for sqrt
#include <vector>
#include <algorithm>
using namespace std;

#include <mex.h>
#include "ccputime.h"
#if linux == 0
typedef int mwSize;
typedef int mwIndex;
#endif


class idEqPatternOne
{
public:
  size_t clique_i, clique_j;
  int overlap_size;
  int* overlaps;
  int* location_i; // in each clique
  int* location_j; // in each clique
};

class IJCE
{
public:
  int i,j,cliqueNumber;
  double ele;
  static bool compareJ(IJCE* input1, IJCE* input2) {
    if (input1->j < input2->j) { return true; }
    else return false;
  }
};

class coverCandidateOne
{
public:
  int i;
  vector<int>* cliqueNumber;
  vector<int>* location_i;
  vector<int>* location_j;
};

class assignedNumber
{
public:
  int k;
  int number;
};

void mexFunction(int nlhs, mxArray* plhs[],
                 int nrhs, const mxArray* prhs[])
{
  if (nlhs != 2 && nrhs != 6) {
    mexErrMsgTxt("The number of input is 6 and output is 2.\n");
  }

  const mxArray* clique        = prhs[0];
  const mxArray* sDim          = prhs[1];
  const mxArray* idEqPattern   = prhs[2];
  const mxArray* At            = prhs[3];
  const mxArray* c             = prhs[4];
  const mxArray* K             = prhs[5];

  int sDim_v = (int) (*mxGetPr(sDim));
  int K_v    = (int) (*mxGetPr(mxGetField(K,0,"s")));

  // The size of the variable matrix
  // We assume the variable matrix is one block
  // with multiple cliques

  int NoClique = (int)(*(mxGetPr(mxGetField(clique,0,"NoC"))));
  #if PRINT_ESSENTIAL
  mexPrintf("sDim  = %d, K = %d\n",sDim_v,K_v);
  mexPrintf("NoClique = %d\n", NoClique);
  #endif
  int* cliqueSize  = new int[NoClique];
  for (int p=0; p<NoClique; ++p) {
    cliqueSize[p] = (int) (mxGetPr(mxGetField(clique,0,"NoElem")))[p];
  }
  #if PRINT_DEBUG
  mexPrintf("cliqueSize = ");
  for (int p=0; p<NoClique; ++p) {
    mexPrintf("%d ", cliqueSize[p]);
  }
  mexPrintf("\n");
  #endif
  // The point where the variables of the clique start
  // in the converted problem

  int* cliqueStart = new int[NoClique+1];
  cliqueStart[0] = 0;
  for (int p=0; p<NoClique; ++p) {
    cliqueStart[p+1] = cliqueStart[p]+cliqueSize[p]*cliqueSize[p];
  }
  #if PRINT_DEBUG 
  mexPrintf("cliqueStart = ");
  for (int p=0; p<=NoClique; ++p) {
    mexPrintf("%d ", cliqueStart[p]);
  }
  mexPrintf("\n");
  #endif

  // How many clique cover each row/column
  int* cliqueCounter = new int[K_v];
  for (int i=0; i<K_v; ++i) {
    cliqueCounter[i] = 0;
  }

  // The elements of each clique
  int** cliqueElements;
  cliqueElements = new int*[NoClique];
  double* cliqueElements_ele = mxGetPr(mxGetField(clique,0,"Elem"));
  for (int p=0; p<NoClique; ++p) {
    int length = cliqueSize[p];
    cliqueElements[p] = new int[cliqueSize[p]];
    for (int index=0; index<length; ++index) {
      double double_size = *cliqueElements_ele;
      int    int_size    = (int)double_size;
      if (int_size < double_size - 0.5) {
	int_size++;
      }
      if (int_size > double_size + 0.5) {
	int_size--;
      }
      int ind = int_size -1;
      cliqueElements[p][index] = ind;
      cliqueCounter[ind]++;
      cliqueElements_ele++;
    }
  }
  // The clique number which belong to the row/column
  int** indexCliqueName     = new int*[K_v];
  // The row/column number in each clique for each row/column
  int** indexCliqueLocation = new int*[K_v];

  // for i-th input row/column 
  // cliqueNumber = indexCliqueName[i][index];
  // cliqueColumn = indexCliqueLocation[i][index];
  
  for (int i=0; i<K_v; ++i) {
    indexCliqueName    [i] = new int[cliqueCounter[i]];
    indexCliqueLocation[i] = new int[cliqueCounter[i]];
  }
  int* cliqueCounter_i = new int[K_v];
  for (int i=0; i<K_v; ++i) {
    cliqueCounter_i[i] = 0;
  }
  for (int p=0; p<NoClique; ++p) {
    int length = cliqueSize[p];
    for (int index=0; index<length; ++index) {
      int ind = cliqueElements[p][index];
      int point = cliqueCounter_i[ind];
      indexCliqueName[ind][point]     = p;
      indexCliqueLocation[ind][point] = index;
      cliqueCounter_i[ind]++;      
    }
  }

  #if PRINT_ESSENTIAL
  mexPrintf("We ASSUME each clique is sorted\n");
  #endif

  #if PRINT_DEBUG
  mexPrintf("Each clique is ");
  for (int p=0; p<NoClique; ++p) {
    int length = cliqueSize[p];
    mexPrintf("[ ");
    for (int index=0; index<length; ++index) {
      mexPrintf("%d ",cliqueElements[p][index]);
    }
    mexPrintf(" ] ");
  }
  mexPrintf("\n");
  mexPrintf("Each index is covered by \n");
  for (int i=0; i<K_v; ++i) {
    mexPrintf("i = %d : %d : ", i, cliqueCounter[i]);
    for (int index=0; index<cliqueCounter[i]; ++index) {
      mexPrintf("cl[%d].loc[%d], ", indexCliqueName[i][index],
	     indexCliqueLocation[i][index]);
    }
    mexPrintf("\n");
  }
  #endif

  // coverCandidate(i,j) is candidate cliques for (i,j)-element
  // Note that coverCandidate is column-orientation sparse format
  // To find row-number, access coverCandidata[j] sequensially.

  // If coverCandidate(i,j)->cliqueNumber->size() == 1
  // we have only one clique for (i,j)-element
  
  //  Each candidate has
  //  cliqueNumber and location_i,j to indicate location in each clique
  
  vector<coverCandidateOne*>* coverCandidate
    = new vector<coverCandidateOne*>[K_v];

  for (int j=0; j<K_v; ++j) {
    for (int i=0; i<K_v; ++i) {
      int overlap_count = 0;
      int index_i = 0;
      int index_j = 0;
      coverCandidateOne* cco = NULL;
      const int    cliqueCounter_i =  cliqueCounter[i];
      const int    cliqueCounter_j =  cliqueCounter[j];
      const int* indexCliqueName_i =  indexCliqueName[i];
      const int* indexCliqueName_j =  indexCliqueName[j];
      
      while (index_i < cliqueCounter_i && index_j < cliqueCounter_j) {
	if (indexCliqueName_i[index_i] < indexCliqueName_j[index_j]) {
	  index_i++;
	  continue;
	}
	if (indexCliqueName_j[index_j] < indexCliqueName_i[index_i]) {
	  index_j++;
	  continue;
	}
	// Here, we found the clique which covers (i,j) element
	if (overlap_count == 0) {
	  cco = new coverCandidateOne;
	  cco->i = i;
	  cco->cliqueNumber = new vector<int>;
	  cco->location_i   = new vector<int>;
	  cco->location_j   = new vector<int>;
	  coverCandidate[j].push_back(cco);
	}
	#if 0
	mexPrintf("pushing (%d,%d) cl[%d].loc(%d,%d)\n",
	       i,j,indexCliqueName_i[index_i],
	       indexCliqueLocation[i][index_i],
	       indexCliqueLocation[j][index_j]);
	#endif
	cco->cliqueNumber->push_back(indexCliqueName_i[index_i]);
	cco->location_i->push_back(indexCliqueLocation[i][index_i]);
	cco->location_j->push_back(indexCliqueLocation[j][index_j]);
	overlap_count++;
	index_i++;
	index_j++;
      }
    }
  }

  #if PRINT_DEBUG
  mexPrintf("CoverCandidate\n");
  for (int j=0; j<K_v; ++j) {
    int length = coverCandidate[j].size();
    for (int ss = 0; ss<length; ++ss) {
      coverCandidateOne* cco = coverCandidate[j].at(ss);
      int i = cco->i;
      int length2 = cco->cliqueNumber->size();
      mexPrintf("(%d,%d) : ",i,j);
      for (int tt = 0; tt<length2; ++tt) {
	mexPrintf("cl[%d].loc(%d,%d) ", cco->cliqueNumber->at(tt),
	       cco->location_i->at(tt), cco->location_j->at(tt));
      }
      mexPrintf("\n");
    }
  }
  #endif

  // idEqPatterns define equality constraints
  // to identify elements which belong to multiple cliques

  // Note that since we use max spanning tree
  // The number of idEqPatterns = NoClique - 1
  // clique_i and clique_j is connected
  
  idEqPatternOne* idEqPatterns = new idEqPatternOne[NoClique-1];
  mwIndex*    idEqPatterns_i   = mxGetIr(idEqPattern);
  double* idEqPatterns_overlap = mxGetPr(idEqPattern);
  for (int p=0; p<NoClique-1; ++p) {
    idEqPatterns[p].clique_i = *idEqPatterns_i;
    idEqPatterns_i++;
    idEqPatterns[p].clique_j = *idEqPatterns_i;
    idEqPatterns_i++;
    int n = (int) (*idEqPatterns_overlap);
    double double_size = (sqrt((double)(8*n+1))-1)/2;
    int int_size = (int)double_size;
    if (int_size < double_size - 0.5) {
      int_size++;
    }
    if (int_size > double_size + 0.5) {
      int_size--;
    }
    idEqPatterns[p].overlap_size = int_size;
    #if PRINT_DEBUG
    mexPrintf("OverLap_Size between %zd and %zd is %d (n=%d)\n",
	   idEqPatterns[p].clique_i,idEqPatterns[p].clique_j,
	   idEqPatterns[p].overlap_size,n);
    #endif
    idEqPatterns_overlap++;
    idEqPatterns_overlap++;
  }

  // overlaps is overlapped row/column number
  // location_i is the row/column number in clique_i 
  for (int p=0; p<NoClique-1; ++p) {
    idEqPatterns[p].overlaps   = new int[idEqPatterns[p].overlap_size];
    idEqPatterns[p].location_i = new int[idEqPatterns[p].overlap_size];
    idEqPatterns[p].location_j = new int[idEqPatterns[p].overlap_size];
    const size_t i = idEqPatterns[p].clique_i;
    const size_t j = idEqPatterns[p].clique_j;
    const int length_i = cliqueSize[i];
    const int length_j = cliqueSize[j];
    int* cliqueElements_i = cliqueElements[i];
    int* cliqueElements_j = cliqueElements[j];
    int* overlaps   = idEqPatterns[p].overlaps;
    int* location_i = idEqPatterns[p].location_i;
    int* location_j = idEqPatterns[p].location_j;
    int index = 0;
    int index_i, index_j;
    index_i = index_j = 0;
    while (index_i < length_i && index_j < length_j) {
      int n_i = cliqueElements_i[index_i];
      int n_j = cliqueElements_j[index_j];
      if (n_i < n_j) {
	index_i++; continue;
      }
      if (n_j < n_i) {
	index_j++; continue;
      }
      overlaps[index]   = n_i;
      location_i[index] = index_i;
      location_j[index] = index_j;
      
      index++; index_i++; index_j++;
    }
  }

  #if 0 | PRINT_DEBUG
  mexPrintf("idEqPatterns = \n");
  for (int p=0; p<NoClique-1; ++p) {
    mexPrintf("( %zd, %zd) : %d : ",
	   idEqPatterns[p].clique_i, idEqPatterns[p].clique_j,
	   idEqPatterns[p].overlap_size);
    for (int q=0; q<idEqPatterns[p].overlap_size; ++q) {
      mexPrintf(" %d as cl[%zd].loc[%d] and cl[%zd].loc[%d],",
	     idEqPatterns[p].overlaps[q],
	     idEqPatterns[p].clique_i,
	     idEqPatterns[p].location_i[q],
	     idEqPatterns[p].clique_j,  
	     idEqPatterns[p].location_j[q]);
    }
    mexPrintf("\n");
  }
  #endif
  
  #if PRINT_ESSENTIAL
  mexPrintf("PreProcessing is OVER \n");
  #endif

  // Note that At is transpose of A
  int  mDim     = (int) mxGetN(At);
  mwIndex* ARow = mxGetJc(At);
  mwIndex* ACol = mxGetIr(At);
  double*  AEle = mxGetPr(At);

  #if PRINT_DEBUG
  mexPrintf("nnz(original   A) = %zd\n", ARow[mDim]);
  #endif
  // If the clique to insert is determined,
  // the element is stored into ApcPrepared
  // otherwise into ApcNotPrepared
  vector<IJCE*>* ApcPrepared = new vector<IJCE*>[mDim];
  vector<IJCE*>* ApcNotPrepared = new vector<IJCE*>[mDim];

  int* eachRowCliqueAssigned = new int[NoClique];

  // How many elements are assigned the clique
  // This will be generated by eachRowCliqueAssigned from A[k]
  // This counts only upper triangular variable matrix
  vector<assignedNumber*>* cliqueAssigned;
  cliqueAssigned = new vector<assignedNumber*>[NoClique];
  
  for (int k=0; k<mDim; ++k) {
    for (int p=0; p<NoClique; ++p) {
      eachRowCliqueAssigned[p] = 0;
    }
    int previous_j = -1;
    int index_i = 0;
    vector<coverCandidateOne*>::iterator coverCandidateJ;
    mwIndex Ak_start = ARow[k];
    mwIndex Ak_end   = ARow[k+1];
    for (mwIndex ind_j = Ak_start; ind_j < Ak_end; ++ind_j) {
      mwIndex Aj       = ACol[ind_j];
      mwIndex i        = Aj % K_v;
      mwIndex j        = Aj / K_v;
      if (i > j) {
	// only upper trianguler is processed
	continue;
      }
      double ele   = AEle[ind_j];
      if (previous_j != (int)j) {
	previous_j = (int)j;
	index_i = 0;
	coverCandidateJ = coverCandidate[j].begin();
      }
      // mexPrintf(" extract A[%d](%zd,%zd) = %e\n",k,i,j,ele);
      if (ele == 0.0 || ele == -0.0) {
	continue;
      }
      while ((int)i != (*coverCandidateJ)->i) {
	coverCandidateJ++;
      }
      if ((*coverCandidateJ)->cliqueNumber->size() == 1) {
	// only one candidate clique
	IJCE* oneInput = new IJCE;
	oneInput->i = (*coverCandidateJ)->location_i->at(0);
	oneInput->j = (*coverCandidateJ)->location_j->at(0);
	oneInput->cliqueNumber
	  = (*coverCandidateJ)->cliqueNumber->at(0);
	// Only upper triangluar matrix
	if (oneInput->i <= oneInput->j) {
	  eachRowCliqueAssigned[oneInput->cliqueNumber]++;
	}
	oneInput->ele = ele;
	ApcPrepared[k].push_back(oneInput);
	#if PRINT_DEBUG
	mexPrintf("     One Clique Input : ");
	mexPrintf("A[%d].cl[%d].loc(%d,%d) = %e\n",
	       k, oneInput->cliqueNumber,
	       oneInput->i, oneInput->j, oneInput->ele);
	#endif
      }
      else {
	// multiple candidate cliques
	IJCE* oneInput = new IJCE;
	oneInput->i = i;
	oneInput->j = j;
	oneInput->cliqueNumber = 0;
	oneInput->ele = ele;
	ApcNotPrepared[k].push_back(oneInput);
	#if PRINT_DEBUG
	mexPrintf("Multiple Clique Input : ");
	mexPrintf("A[%d](%d,%d) = %e\n",
	       k, 
	       oneInput->i, oneInput->j, oneInput->ele);
	#endif
      }
    }
    for (int p=0; p<NoClique; ++p) {
      if (eachRowCliqueAssigned[p]!=0) {
	assignedNumber* a = new assignedNumber;
	a->k = k;
	a->number = eachRowCliqueAssigned[p];
	cliqueAssigned[p].push_back(a);
      }
    }
  }

  #if PRINT_DEBUG
  mexPrintf("CliqueAssigned after One Candidate Input\n");
  for (int p=0; p<NoClique; ++p) {
    mexPrintf("p = %d : ",p);
    int size = cliqueAssigned[p].size();
    for (int index = 0; index<size; ++index) {
      assignedNumber* a = cliqueAssigned[p].at(index);
      mexPrintf("[k=%d,num=%d]",a->k,a->number);
    }
    mexPrintf("\n");
  }
  #endif

  // update cliqueAssigned by idEqPattern
  int mIndex = mDim;
  for (int p=0; p<NoClique-1; ++p) {
    int overlap_size = idEqPatterns[p].overlap_size;
    for (int laps_i=0; laps_i<overlap_size; ++laps_i) {
      for (int laps_j=laps_i; laps_j<overlap_size; ++laps_j) {
	assignedNumber* a = new assignedNumber;
	a->k = mIndex;
	a->number = 1;
	assignedNumber* b = new assignedNumber;
	b->k = mIndex;
	b->number = 1;
	cliqueAssigned[idEqPatterns[p].clique_i].push_back(a);
	cliqueAssigned[idEqPatterns[p].clique_j].push_back(b);
	mIndex++;
      }
    }
  }
  
  // The number of columns of ApcTrans  
  int totalMIndex = mIndex;
  
  #if PRINT_DEBUG
  mexPrintf("CliqueAssigned after idEqPatterns\n");
  for (int p=0; p<NoClique; ++p) {
    mexPrintf("p = %d : ",p);
    int size = cliqueAssigned[p].size();
    for (int index = 0; index<size; ++index) {
      assignedNumber* a = cliqueAssigned[p].at(index);
      mexPrintf("[k=%d,num=%d]",a->k,a->number);
    }
    mexPrintf("\n");
  }
  #endif

  // cliqueAssignedAccum is the total number of assigned
  // This is used for a cost estimation on F3 formula
  int* cliqueAssignedAccum = new int[NoClique];
  for (int p=0; p<NoClique; ++p) {
    int length = cliqueAssigned[p].size();
    int accum = 0;
    for (int ss=0; ss<length; ++ss) {
      accum += cliqueAssigned[p].at(ss)->number;
    }
    cliqueAssignedAccum[p] = accum;
  }
  
  #if PRINT_DEBUG
  mexPrintf("cliqueAssignedAccum = ");
  for (int p=0; p<NoClique; ++p) {
    mexPrintf("%d ", cliqueAssignedAccum[p]);
  }
  mexPrintf("\n");
  #endif
    
  int* cliqueAssignedIndex = new int[NoClique];
  for (int p=0; p<NoClique; ++p) {
    cliqueAssignedIndex[p] = 0;
  }

  // Detemine the clique number for each ANonPrepared 
  for (int k=0; k<mDim; ++k) {

    // Recover eachRowCliqueAssigned
    for (int p=0; p<NoClique; ++p) {
      int index_p = cliqueAssignedIndex[p];
      int last_p  = cliqueAssigned[p].size();
      while (index_p < last_p &&  cliqueAssigned[p].at(index_p)->k < k) {
	index_p++;
      }
      if (index_p < last_p && cliqueAssigned[p].at(index_p)->k == k) {
	eachRowCliqueAssigned[p] = cliqueAssigned[p].at(index_p)->number;
      }
      else {
	eachRowCliqueAssigned[p] = 0;
      }
      cliqueAssignedIndex[p] = index_p;
    }
    #if PRINT_DEBUG
    mexPrintf("EachRowCliqueAssinged[%d] = ",k);
    for (int p=0; p<NoClique; ++p) {
      mexPrintf("%d ", eachRowCliqueAssigned[p]);
    }
    mexPrintf("\n");
    #endif
    int length = ApcNotPrepared[k].size();
    for (int ss=0; ss<length; ++ss) {
      IJCE* oneInput = ApcNotPrepared[k].at(ss);
      #if PRINT_DEBUG
      mexPrintf("ANon[%d](%d,%d) = %e\n", k, 
	     oneInput->i, oneInput->j, oneInput->ele);
      #endif
      vector<coverCandidateOne*>::iterator coverCandidateJ;
      coverCandidateJ = coverCandidate[oneInput->j].begin();
      while ((*coverCandidateJ)->i != oneInput->i) {
	coverCandidateJ++;
      }
      coverCandidateOne* cco = *coverCandidateJ;

      // search minmum cliqueAssignedAccum in both
      // assigned clique for k and nonAssigned clique for k
      int assignedTargetClique = -1;
      int minAssigned = 0;
      int assignedLocation_i = 0;
      int assignedLocation_j = 0;
      int nonAssignedTargetClique = -1;
      int nonMinAssigned = 0;
      int nonAssignedLocation_i = 0;
      int nonAssignedLocation_j = 0;
      
      int length2 = cco->cliqueNumber->size();
      for (int tt = 0; tt<length2; ++tt) {
	int cliqueNumber = cco->cliqueNumber->at(tt);
	#if PRINT_DEBUG
	mexPrintf("cl[%d].loc(%d,%d) ", cco->cliqueNumber->at(tt),
	       cco->location_i->at(tt), cco->location_j->at(tt));
	#endif
	if (eachRowCliqueAssigned[cliqueNumber] > 0) {
	  if (assignedTargetClique == -1
	      || cliqueAssignedAccum[cliqueNumber] < minAssigned) {
	    assignedTargetClique = cliqueNumber;
	    minAssigned = cliqueAssignedAccum[cliqueNumber];
	    assignedLocation_i = cco->location_i->at(tt);
	    assignedLocation_j = cco->location_j->at(tt);
	  }
	}
	else { // NonAssignedCase
	  if (nonAssignedTargetClique == -1
	      || cliqueAssignedAccum[cliqueNumber] < nonMinAssigned) {
	    nonAssignedTargetClique = cliqueNumber;
	    nonMinAssigned = cliqueAssignedAccum[cliqueNumber];
	    nonAssignedLocation_i = cco->location_i->at(tt);
	    nonAssignedLocation_j = cco->location_j->at(tt);
	  }
	}
      }
      #if PRINT_DEBUG
      mexPrintf("\n");
      #endif
      // If at least one clique is already assinged,
      // we find from them,
      // otherwise we find from all candidates
      int targetClique     = assignedTargetClique;
      int targetLocation_i = assignedLocation_i;
      int targetLocation_j = assignedLocation_j;
      if (targetClique == -1) {
	targetClique     = nonAssignedTargetClique;
	targetLocation_i = nonAssignedLocation_i;
	targetLocation_j = nonAssignedLocation_j;
      }
      cliqueAssignedAccum[targetClique]++;
      eachRowCliqueAssigned[targetClique]++;
      
      oneInput = ApcNotPrepared[k].at(ss);
      oneInput->i = targetLocation_i;
      oneInput->j = targetLocation_j;
      oneInput->cliqueNumber = targetClique;
      #if PRINT_DEBUG
      mexPrintf("ANon[%d](%d,%d) = %e -> ", k, 
	     oneInput->i, oneInput->j, oneInput->ele);
      mexPrintf("A[%d].cl[%d].loc(%d,%d) = %e\n", k, 
	     oneInput->cliqueNumber,
	     oneInput->i, oneInput->j, oneInput->ele);
      #endif
      ApcPrepared[k].push_back(oneInput);
    }
  }

  // Now All Elements from A is stored into ApcPrepared

  // Recover lower triangular in ApcPrepared
  for (int k=0; k<mDim; ++k) {
    int length = ApcPrepared[k].size();  // the length should fix
    for (int ss=0; ss<length; ++ss) {
      IJCE* oneInput = ApcPrepared[k].at(ss);
      if (oneInput->j != oneInput->i) {
	IJCE* reflectInput = new IJCE;
	reflectInput->i = oneInput->j;
	reflectInput->j = oneInput->i;
	reflectInput->cliqueNumber = oneInput->cliqueNumber;
	reflectInput->ele = oneInput->ele;
	ApcPrepared[k].push_back(reflectInput);
      }
    }
  }
  

  // sort ApcPrepared by column index which will be set into j
  for (int k=0; k<mDim; ++k) {
    int length = ApcPrepared[k].size();
    for (int ss=0; ss<length; ++ss) {
      IJCE* oneInput = ApcPrepared[k].at(ss);
      oneInput->j = cliqueStart[oneInput->cliqueNumber]
	+ oneInput->i + oneInput->j * cliqueSize[oneInput->cliqueNumber];
    }
  }
  for (int k=0; k<mDim; ++k) {
    sort(ApcPrepared[k].begin(),ApcPrepared[k].end(),
	 IJCE::compareJ);
  }


  // We count the number of NonZeros for ApcTrans
  size_t nzmax = 0;
  for (int k=0; k<mDim; ++k) {
    nzmax += ApcPrepared[k].size();
  }
  #if 0 | PRINT_DEBUG
  mexPrintf("nnz(converted  A) = %d\n", nzmax);
  #endif
  // for +1 and -1
  for (int p=0; p<NoClique-1;++p) {
    int overlaps = idEqPatterns[p].overlap_size;
    nzmax += overlaps*2; // for diagonal (+1 and -1)
    nzmax += overlaps*(overlaps-1)*2; // for non-diagonal (+1x2 and -1x2)
  }
  #if PRINT_DEBUG
  mexPrintf("rows = %d, totalMIndex = %d, nzmax = %d\n",
	 cliqueStart[NoClique],totalMIndex,nzmax);
  #endif
  #if PRINT_ESSENTIAL
  mexPrintf("size(Apc) = (%d,%d), nz(Apc) = %d\n",
	 totalMIndex,cliqueStart[NoClique],nzmax);
  #endif
  plhs[0] = mxCreateSparse(cliqueStart[NoClique],totalMIndex,
			   nzmax,mxREAL);
  mxArray* ApcTrans   = plhs[0];
  mwIndex* ApcTransRow    = mxGetIr(ApcTrans);
  mwIndex* ApcTransColumn = mxGetJc(ApcTrans);
  double* ApcTransEle = mxGetPr(ApcTrans);
  size_t ApcTransIndex   = 0;

  
  for (int k=0; k<mDim; ++k) {
    int length = ApcPrepared[k].size();
    for (int ss = 0; ss < length; ++ss) {
      IJCE* oneInput = ApcPrepared[k].at(ss);
      #if PRINT_DEBUG
      mexPrintf("ApcTransIndex = %zd, k = %d, j = %d, ele = %e\n",
	     ApcTransIndex, k, oneInput->j, oneInput->ele);
      #endif
      ApcTransRow[ApcTransIndex] = oneInput->j;
      ApcTransEle[ApcTransIndex] = oneInput->ele;
      ApcTransIndex++;
    }
    ApcTransColumn[k+1] = ApcTransIndex;
  }
  #if 0 | PRINT_DEBUG
  mexPrintf("nnz(immigrated A) = %zd\n", ApcTransIndex);
  #endif

  #if PRINT_DEBUG
  mexPrintf("Equalities from idEqPatterns\n");
  #endif
  mIndex = mDim;
  for (int p=0; p<NoClique-1; ++p) {
    size_t  clique_i  = idEqPatterns[p].clique_i;
    size_t  clique_j  = idEqPatterns[p].clique_j;
    int  overlap_size = idEqPatterns[p].overlap_size;
    int* location_i   = idEqPatterns[p].location_i;
    int* location_j   = idEqPatterns[p].location_j;
    #if 0 | PRINT_DEBUG
    mexPrintf("ApcTransIndexStart = %zd, estimateEnd = %zd\n",
	   ApcTransIndex,
	   ApcTransIndex + overlap_size*(overlap_size+1));
    #endif
    for (int tj=0; tj<overlap_size; ++tj) {
      int j1 = location_i[tj];
      int j2 = location_j[tj];
      int indexStart1 = cliqueStart[clique_i] + j1 * cliqueSize[clique_i];
      int indexStart2 = cliqueStart[clique_j] + j2 * cliqueSize[clique_j];
      for (int ti=tj; ti<overlap_size; ++ti) {
	int i1 = location_i[ti];
	int i2 = location_j[ti];
	int index1 = indexStart1 + i1;
	int index2 = indexStart2 + i2;
	#if 0 | PRINT_DEBUG
	mexPrintf("cSt_i = %d cSt_j = %d, "
	       "cSz_i = %d cSz_j = %d, "
	       "i1 = %d i2 = %d j1 = %d, j2 = %d\n",
	       cliqueStart[clique_i], cliqueStart[clique_j],
	       cliqueSize[clique_i], cliqueSize[clique_j],
	       i1,i2,j1,j2);
	#endif

	if (i1 == j1) { // diagonal
	  ApcTransRow[ApcTransIndex+0] = index1;
	  ApcTransRow[ApcTransIndex+1] = index2;
	  ApcTransEle[ApcTransIndex+0] =  1;
	  ApcTransEle[ApcTransIndex+1] = -1;
          #if 0 | PRINT_DEBUG
	  mexPrintf("ApcTransIndex = %zd, k = %d, j = %d, ele = %e\n",
		 ApcTransIndex, mIndex, index1, 1.0);
	  mexPrintf("ApcTransIndex = %zd, k = %d, j = %d, ele = %e\n",
		 ApcTransIndex+1, mIndex, index2, -1.0);
          #endif
	  ApcTransIndex += 2;
	}
	else { // non-diagonal
	  int index3 = cliqueStart[clique_i]
	    + i1 * cliqueSize[clique_i] + j1;
	  int index4 = cliqueStart[clique_j]
	    + i2 * cliqueSize[clique_j] + j2;
	  ApcTransRow[ApcTransIndex+0] = index1;
	  ApcTransRow[ApcTransIndex+1] = index2;
	  ApcTransRow[ApcTransIndex+2] = index3;
	  ApcTransRow[ApcTransIndex+3] = index4;
	  ApcTransEle[ApcTransIndex+0] =  1;
	  ApcTransEle[ApcTransIndex+1] = -1;
	  ApcTransEle[ApcTransIndex+2] =  1;
	  ApcTransEle[ApcTransIndex+3] = -1;
          #if 0 | PRINT_DEBUG
	  mexPrintf("ApcTransIndex = %d, k = %d, j = %d, ele = %e\n",
		 ApcTransIndex, mIndex, index1, 1.0);
	  mexPrintf("ApcTransIndex = %d, k = %d, j = %d, ele = %e\n",
		 ApcTransIndex+1, mIndex, index2, -1.0);
	  mexPrintf("ApcTransIndex = %d, k = %d, j = %d, ele = %e\n",
		 ApcTransIndex+2, mIndex, index3, 1.0);
	  mexPrintf("ApcTransIndex = %d, k = %d, j = %d, ele = %e\n",
		 ApcTransIndex+3, mIndex, index4, -1.0);
          #endif
	  ApcTransIndex += 4;
	}
	mIndex++;
	ApcTransColumn[mIndex] = ApcTransIndex;
      }
    }
    #if 0 | PRINT_DEBUG
    mexPrintf("ApcTransIndexEnd = %zd\n",ApcTransIndex);
    #endif

  }

  #if 0 | PRINT_DEBUG
  // mIndex should be totalMIndex
  // nzmax should be ApcTransIndex
  mexPrintf("mIndex = %d, totalMIndex = %d\n", mIndex, totalMIndex);
  mexPrintf("nzmax = %zd, ApcTransIndex = %zd\n", nzmax, ApcTransIndex);
  #endif
  if (mIndex != totalMIndex) {
    mexPrintf("Conversion ERROR % !!");
    mexPrintf("mIndex = %d, totalMIndex = %d\n", mIndex, totalMIndex);
  }
  if (nzmax != ApcTransIndex) {
    mexPrintf("Conversion ERROR % !!");
    mexPrintf("nzmax = %zd, ApcTransIndex = %zd\n", nzmax, ApcTransIndex);
  }

  // for coeffcient matrix
  mwIndex*   cRow = mxGetIr(c);
  mwIndex*   cCol = mxGetJc(c);
  double*    cEle = mxGetPr(c);
  if (mxIsEmpty(c) || mxGetNzmax(c) == 0 || cCol[1] == 0) {
    #if PRINT_ESSENTIAL
    mexMexPrintf("nz(cPc) = 0 :: empty\n");
    #endif
    plhs[1] = mxCreateSparse(cliqueStart[NoClique],1,0,mxREAL);
    mxArray* cPcTrans = plhs[1];
    // mwIndex* cPcTransRow    = mxGetIr(cPcTrans);
    mwIndex* cPcTransColumn = mxGetJc(cPcTrans);
    // double*  cPcTransEle    = mxGetPr(cPcTrans);
    cPcTransColumn[0] = 0;
    cPcTransColumn[1] = 0;
  }
  else {
    int cPcLength = cCol[1];
    //  mexPrintf("cPcLength = %d\n",cPcLength);
    #if PRINT_ESSENTIAL
    mexMexPrintf("nz(cPc) = %d\n",cPcLength);
    #endif
    plhs[1] = mxCreateSparse(cliqueStart[NoClique],1,cPcLength,mxREAL);
    mxArray* cPcTrans = plhs[1];
    mwIndex* cPcTransRow    = mxGetIr(cPcTrans);
    mwIndex* cPcTransColumn = mxGetJc(cPcTrans);
    double*  cPcTransEle    = mxGetPr(cPcTrans);

    cPcTransColumn[0] = 0;
    cPcTransColumn[1] = cPcLength;
    int previous_j = -1;
    vector<coverCandidateOne*>::iterator coverCandidateJ;
    for(int cPcTransIndex = 0; cPcTransIndex < cPcLength;
	++cPcTransIndex) {
      int i = cRow[cPcTransIndex] % K_v;
      int j = cRow[cPcTransIndex] / K_v;
      double ele = cEle[cPcTransIndex];
      if (previous_j != j) {
	previous_j = j;
	coverCandidateJ = coverCandidate[j].begin();
      }
      while (i != (*coverCandidateJ)->i) {
	coverCandidateJ++;
      }
      // Input first candidate
      int location_i = (*coverCandidateJ)->location_i->at(0);
      int location_j = (*coverCandidateJ)->location_j->at(0);
      int cliqueNumber = (*coverCandidateJ)->cliqueNumber->at(0);
      #if PRINT_DEBUG
      mexPrintf("cPcIndex %d : C[%d,%d] -> C.cl[%d].loc(%d,%d) = %e\n",
	     cPcTransIndex,i,j,cliqueNumber,location_i,location_j,ele);
      #endif
      int rowIndex = cliqueStart[cliqueNumber] + location_i
	+ location_j * cliqueSize[cliqueNumber];
      cPcTransRow[cPcTransIndex] = rowIndex;
      cPcTransEle[cPcTransIndex] = ele;
    }
  }


  // Delete all allocated memory space
  delete[] cliqueSize;
  delete[] cliqueStart;
  delete[] cliqueCounter;
  for (int p=0; p<NoClique; ++p) {
    delete[] cliqueElements[p];
  }
  delete[] cliqueElements;
  for (int i=0; i<K_v; ++i) {
    delete[] indexCliqueName[i];
    delete[] indexCliqueLocation[i];
  }
  delete[] indexCliqueName;
  delete[] indexCliqueLocation;
  delete[] cliqueCounter_i;

  vector<coverCandidateOne*>::iterator ccoi;
  for (int i=0; i<K_v; ++i) {
    for (ccoi = coverCandidate[i].begin();
	 ccoi != coverCandidate[i].end(); ++ccoi) {
      delete (*ccoi)->cliqueNumber;
      delete (*ccoi)->location_i;
      delete (*ccoi)->location_j;
      delete *ccoi;
      
    }
  }
  delete[] coverCandidate;

  for (int p=0; p<NoClique-1; ++p) {
    delete[] idEqPatterns[p].overlaps;
    delete[] idEqPatterns[p].location_i;
    delete[] idEqPatterns[p].location_j;
  }
  
  delete[] idEqPatterns;

  vector<IJCE*>::iterator ijcei;
  for (int k=0; k<mDim; ++k) {
    for (ijcei = ApcPrepared[k].begin(); ijcei != ApcPrepared[k].end();
	 ++ijcei) {
      delete *ijcei;
    }
  }
  delete[] ApcPrepared;
  // Note that all elements in ApcNotPrepared are
  // deleted as elements in ApcPrepared 
  delete[] ApcNotPrepared;

  delete[] eachRowCliqueAssigned;

  vector<assignedNumber*>::iterator ani;
  for (int p=0; p<NoClique; ++p) {
    for (ani = cliqueAssigned[p].begin(); ani != cliqueAssigned[p].end();
	 ++ani) {
      delete *ani;
    }
  }
  delete[] cliqueAssigned;
  delete[] cliqueAssignedAccum;
  delete[] cliqueAssignedIndex;
  return;
}
