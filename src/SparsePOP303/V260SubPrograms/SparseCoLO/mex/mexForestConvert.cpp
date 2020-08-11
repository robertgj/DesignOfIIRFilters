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

// [AtConvert,CtConvert,KConvert,cliqueConvert,NoForest,retrieveInfo]
//   = mexForestConvert(At,Ct,sDim,clique)


// If the cliques are {1,4,5},{2,6,8},{3,6,9},{5,7}
// We divide the block into two sub-blocks {1,4,5,7}, {2,3,6,8,9}

// NoForest = 2 // the number of sub-blocks
// KConvert.s = [4,5]
// cliqueConvert{1} = {1,2,3}, {3,4} ( <= {1,4,5}, {5,7})
//      NoC = 2, NoElem = [3,2], Elem = [1,2,3,3,4]
// cliqueConvert{2} = {1,3,4}, {2,3,5} ( <= {2,6,8}, {3,6,9})
//      NoC = 2, NoElem = [3,3], Elem = [1,3,4,2,3,5]

// retrieveInfo.noSDPcones = 2 // NoForest
// retrieveInfo.sDim = 9
// retrieveInfo.s = [4,5]
// retrieveInfo.retrieveIndex = {1,4,5,7,2,3,6,8,9} // row vector of sDim
 
#define PRINT_ESSENTIAL 0
#define PRINT_DEBUG     0
#define PRINT_TIME      0
#include <iostream>
#include <cstdio>
#include <cstdlib>
// #include <cmath> // for sqrt
#include <vector>
#include <set>
#include <algorithm>
using namespace std;

#include <mex.h>
#include "ccputime.h"
#if linux == 0
typedef int mwSize;
typedef int mwIndex;
#endif

class Clique
{
public:
  int  forestNumber;
  int  size;
  int* ele;

  Clique() {
    forestNumber = -1; // dummy initialize
    size = 0;
    ele = NULL;
  }
  ~Clique() {
    finalize();
  }
  void initialize(int size) {
    this->size = size;
    ele = new int[size];
  }
  void finalize() {
    if (ele != NULL) {
      delete[] ele;
    }
    ele = NULL;
  }
  void print() {
    mexPrintf(" :: f=%d :: ", forestNumber);
    for (int i=0; i<size; ++i) {
      mexPrintf("%d ", ele[i]);
    }
  }
  void sortEle() {
    sort(&(ele[0]),&(ele[size]));
  }
  static bool isCross(Clique* a, Clique* b) {
    bool judge = false;
    int a_size = a->size;
    int b_size = b->size;
    int* a_ele = a->ele;
    int* b_ele = b->ele;

    int a_index = 0;
    int b_index = 0;

    while (a_index < a_size && b_index < b_size) {
      if (a_ele[a_index] == b_ele[b_index]) {
	judge = true;
	break;
      }
      else if (a_ele[a_index] < b_ele[b_index]) {
	a_index++;
      }
      else if (a_ele[a_index] > b_ele[b_index]) {
	b_index++;
      }
    }
    return judge;
  }
};

class Forest
{
public:
  int forestNumber;
  int blockSize;
  vector<Clique*>* clique_p;
  set<int>* mergedClique;
  Forest() {
    forestNumber = 0;
    blockSize    = 0;
    clique_p     = NULL;
    mergedClique = NULL;
  }
  ~Forest() {
    finalize();
  }
  void initialize(int forestNumber) {
    this->forestNumber = forestNumber;
    clique_p = new vector<Clique*>;
    mergedClique = new set<int>;
  }
  void finalize() {
    if (clique_p != NULL) {
      delete clique_p;
    }
    clique_p = NULL;
    if (mergedClique != NULL) {
      delete mergedClique;
    }
    mergedClique = NULL;
  }
  void mergeClique() {
    int length = clique_p->size();
    for (int p=0; p<length; ++p) {
      Clique* target = clique_p->at(p);
      int* ele = target->ele;
      int inlength = target->size;
      for (int i = 0; i< inlength; ++i) {
	mergedClique->insert(ele[i]);
      }
    }
    blockSize = mergedClique->size();
  }
  void print() {
    if (clique_p != NULL) {
      int length = clique_p->size();
      for (int index=0; index<length; ++index) {
	clique_p->at(index)->print();
      }
    }
    mexPrintf("\n");
    if (mergedClique != NULL) {
      mexPrintf("    mergedClique = ");
      set<int>::iterator it;
      for (it = mergedClique->begin(); it != mergedClique->end();
	   it++) {
	mexPrintf("%d ",*it);
      }
      mexPrintf("\n");
    }
  }
	
};

class JE
{
public:
  int j;
  double ele;
  static bool compare(JE* a, JE* b) {
    if (a->j < b->j) {
      return true;
    }
    return false;
  }
};

void mexFunction(int nlhs, mxArray* plhs[],
                 int nrhs, const mxArray* prhs[])
{
  const mxArray* At_ptr      = prhs[0];
  const mxArray* Ct_ptr      = prhs[1];
  const mxArray* sDim_ptr    = prhs[2];
  const mxArray* clique_ptr  = prhs[3];

  int sDim = (int) (mxGetScalar(sDim_ptr));
  int NoClique = (int)(*(mxGetPr(mxGetField(clique_ptr,0,"NoC"))));

  #if PRINT_ESSENTIAL
  mexPrintf("sDim  = %d  \n",sDim);
  mexPrintf("NoClique = %d\n", NoClique);
  #endif

  Clique* clique = new Clique[NoClique];
  for (int p=0; p<NoClique; ++p) {
    int size_p = (int) (mxGetPr(mxGetField(clique_ptr,0,"NoElem")))[p];
    clique[p].initialize(size_p);
  }
  int index = 0;
  double* cliqueEle = mxGetPr(mxGetField(clique_ptr,0,"Elem"));
  for (int p=0; p<NoClique; ++p) {
    int size_p = clique[p].size;
    for (int i=0; i<size_p; ++i) {
      clique[p].ele[i] = (int) (cliqueEle[index] - 1);
      index++;
    }
    clique[p].sortEle();
  }

  #if PRINT_DEBUG
  for (int p=0; p<NoClique; ++p) {
    mexPrintf("clique[%d] = ",p);
    clique[p].print();
    mexPrintf("\n");
  }
  #endif

  // Check the conectivity of cliques
  int* forestNumber = new int[NoClique];
  for (int p=0; p<NoClique; ++p) {
    forestNumber[p] = p;
  }

  for (int p1=0; p1<NoClique; ++p1) {
    for (int p2=p1; p2<NoClique; ++p2) {
      if (forestNumber[p1]==forestNumber[p2]) {
	continue;
      }
      if (Clique::isCross(&clique[p1],&clique[p2]) == true) {
	int smallNumber = forestNumber[p1];
	int largeNumber = forestNumber[p2];
	if (smallNumber > largeNumber) {
	  int tmp = smallNumber;
	  smallNumber = largeNumber;
	  largeNumber = tmp;
	}
	for (int p3=0; p3<NoClique; ++p3) {
	  if (forestNumber[p3] == largeNumber) {
	    forestNumber[p3] = smallNumber;
	  }
	}
      }
    }
  }
  #if PRINT_DEBUG
  mexPrintf("forestNumber = ");
  for (int p=0; p<NoClique; ++p) {
    mexPrintf("%d ",forestNumber[p]);
  }
  mexPrintf("\n");
  #endif

  
  vector<Forest*>* forest = new vector<Forest*>;
  // Separate cliques into each forest
  for (int p=0; p<NoClique; ++p) {
    int forestIndex = 0;
    int NoForest    = forest->size();
    for (; forestIndex < NoForest; ++forestIndex) {
      if(forest->at(forestIndex)->forestNumber == forestNumber[p]) {
	break;
      }
    }
    if (forestIndex < NoForest) {
      // we add clique[p] into this forest
      forest->at(forestIndex)->clique_p->push_back(&clique[p]);
    } else {
      // we need to add new forest
      Forest* newForest = new Forest;
      newForest->initialize(forestNumber[p]);
      newForest->clique_p->push_back(&clique[p]);
      forest->push_back(newForest);
    }
  }

  // Update forestNumber
  int NoForest = forest->size();
  for (int forestIndex=0; forestIndex < NoForest; ++forestIndex) {
    forest->at(forestIndex)->forestNumber = forestIndex;
    vector<Clique*>* clique_p = forest->at(forestIndex)->clique_p;
    int length = clique_p->size();
    for (int index=0; index<length; ++index) {
      clique_p->at(index)->forestNumber = forestIndex;
    }
  }

  #if PRINT_DEBUG
  for (int forestIndex=0; forestIndex < NoForest; ++forestIndex) {
    mexPrintf("** Forest[%d] **\n",forestIndex);
    forest->at(forestIndex)->print();
  }
  #endif
    
  
  for (int forestIndex=0; forestIndex < NoForest; ++forestIndex) {
    forest->at(forestIndex)->mergeClique();
  }
  
  #if PRINT_DEBUG
  for (int forestIndex=0; forestIndex < NoForest; ++forestIndex) {
    mexPrintf("** Forest[%d] **\n",forestIndex);
    forest->at(forestIndex)->print();
  }
  #endif
  
  // Table from row/column index to converted index
  int* blockNumber = new int[sDim];
  int* blockIndex  = new int[sDim];
  int* blockSize   = new int[sDim];
  int* blockStart  = new int[NoForest+1];
  blockStart[0] = 0;
  for (int forestIndex=0; forestIndex < NoForest; ++forestIndex) {
    set<int>* mergedClique = forest->at(forestIndex)->mergedClique;
    set<int>::iterator it;
    int index = 0;
    int fNumber = forest->at(forestIndex)->forestNumber;
    int bSize   = forest->at(forestIndex)->blockSize;
    for (it = mergedClique->begin(); it != mergedClique->end();
	 it++, ++index) {
      blockNumber[*it] = fNumber;
      blockIndex [*it] = index;
      blockSize  [*it] = bSize;
    }
    blockStart[forestIndex+1] = blockStart[forestIndex]
      + bSize*bSize;
  }

  #if 0 | PRINT_DEBUG
  mexPrintf("blockNumber = ");
  for (int i=0; i<sDim; ++i) {
    mexPrintf("%d ", blockNumber[i]);
  }
  mexPrintf("\n");

  mexPrintf("blockIndex  = ");
  for (int i=0; i<sDim; ++i) {
    mexPrintf("%d ", blockIndex[i]);
  }
  mexPrintf("\n");

  mexPrintf("blockSize   = ");
  for (int i=0; i<sDim; ++i) {
    mexPrintf("%d ", blockSize[i]);
  }
  mexPrintf("\n");

  mexPrintf("blockStart  = ");
  for (int i=0; i<=NoForest; ++i) {
    mexPrintf("%d ", blockStart[i]);
  }
  mexPrintf("\n");
  #endif
  
  mwSize nDim = mxGetM(Ct_ptr);
  mwIndex* CtRow    = mxGetIr(Ct_ptr);
  mwIndex* CtColumn = mxGetJc(Ct_ptr);
  double * CtEle    = mxGetPr(Ct_ptr);

  mwSize mDim = mxGetN(At_ptr);
  mwIndex* AtRow    = mxGetIr(At_ptr);
  mwIndex* AtColumn = mxGetJc(At_ptr);
  double * AtEle    = mxGetPr(At_ptr);
  
  vector<JE*>* Cconvert = new vector<JE*>;
  vector<JE*>* Aconvert = new vector<JE*>[mDim];

  #if PRINT_ESSENTIAL
  if (mxIsEmpty(Ct_ptr) || mxGetNzmax(Ct_ptr) == 0 || CtColumn[1] == 0) {
    mexPrintf("mDim = %zd, nDim = %zd, nz(C) = %zd, nz(A) = %zd\n",
	      mDim, nDim, 0, mxGetNzmax(At_ptr));
  }
  else {
    mexPrintf("mDim = %zd, nDim = %zd, nz(C) = %zd, nz(A) = %zd\n",
	      mDim, nDim, mxGetNzmax(Ct_ptr), mxGetNzmax(At_ptr));
  }
  #endif
  if (mxIsEmpty(Ct_ptr) || mxGetNzmax(Ct_ptr) == 0 || CtColumn[1] == 0) {
    // Note that CtConvert is column
    plhs[1] = mxCreateSparse(blockStart[NoForest],1,0,mxREAL);
    mwIndex* CtConvertColumn = mxGetJc(plhs[1]);
    CtConvertColumn[0] = CtConvertColumn[1] = 0;
  } else {
    const mwSize CtSize = CtColumn[1];
    for (size_t index = 0; index<CtSize; ++index) {
      mwIndex ijIndex = CtRow[index];
      double  ele     = CtEle[index];
      int i = ((int)ijIndex % sDim);
      int j = ((int)ijIndex / sDim);
      #if 0 | PRINT_DEBUG
      mexPrintf("i = %d, j = %d, ele = %e  ijIndex = %zd, "
		"index = %zd CtSize = %zd at %dline\n",
		i,j,ele, ijIndex, index, CtSize, __LINE__);
      #endif

      int blockSTART  = blockStart [blockNumber[i]];
      int blockSIZE   = blockSize  [i];
      int blockINDEXi = blockIndex [i];
      int blockINDEXj = blockIndex [j];

      if (blockStart[blockNumber[i]] != blockStart[blockNumber[j]]) {
	mexPrintf("Something Strange bst[%d] = %d , bst[%d] = %d\n",
		  i, blockStart[blockNumber[i]],
		  j, blockStart[blockNumber[j]]);
      }
      if (blockSize[i] != blockSize[j]) {
	mexPrintf("Something Strange bsi[%d] = %d , bsi[%d] = %d\n",
		  i, blockSize[i], j, blockSize[j]);
      }
      JE* je = new JE;
      je->j = blockSTART + blockINDEXi + blockINDEXj * blockSIZE;
      je->ele = ele;
      Cconvert->push_back(je);
    }
    
    sort(Cconvert->begin(),Cconvert->end(),JE::compare);
    int Clength = Cconvert->size();
    // Note that CtConvert is column
    plhs[1] = mxCreateSparse(nDim,1,Clength,mxREAL);
    mxArray* CtConvert_ptr = plhs[1];
    
    mwIndex* CtConvertRow    = mxGetIr(CtConvert_ptr);
    mwIndex* CtConvertColumn = mxGetJc(CtConvert_ptr);
    double*  CtConvertEle    = mxGetPr(CtConvert_ptr);
    
    CtConvertColumn[0] = 0;
    CtConvertColumn[1] = Clength;
    for (int index=0; index<Clength; ++index) {
      JE* je = Cconvert->at(index);
      CtConvertRow[index] = je->j;
      CtConvertEle[index] = je->ele;
    }
  }
    
  for (size_t k=0; k<mDim; ++k) {
    for (size_t index = AtColumn[k]; index<AtColumn[k+1]; ++index) {
      mwIndex ijIndex = AtRow[index];
      double  ele     = AtEle[index];
      int i = ((int)ijIndex % sDim);
      int j = ((int)ijIndex / sDim);
      #if 0 | PRINT_DEBUG
      mexPrintf("i = %d, j = %d, ele = %e  %dline\n",
		i,j,ele,__LINE__);
      #endif
      #if 0 | PRINT_DEBUG
      mexPrintf("bn[%d] = %d, bn[%d] = %d\n",
		i,blockNumber[i],j,blockNumber[j]);
      #endif

      int blockSTART  = blockStart [blockNumber[i]];
      int blockSIZE   = blockSize  [i];
      int blockINDEXi = blockIndex [i];
      int blockINDEXj = blockIndex [j];

      if (blockStart[blockNumber[i]] != blockStart[blockNumber[j]]) {
	mexPrintf("Something Strange bst[%d] = %d , bst[%d] = %d\n",
		  i, blockStart[blockNumber[i]],
		  j, blockStart[blockNumber[j]]);
      }
      if (blockSize[i] != blockSize[j]) {
	mexPrintf("Something Strange bsi[%d] = %d , bsi[%d] = %d\n",
		  i, blockSize[i], j, blockSize[j]);
      }
      JE* je = new JE;
      je->j = blockSTART + blockINDEXi + blockINDEXj * blockSIZE;
      je->ele = ele;
      #if PRINT_DEBUG
      mexPrintf("k = %d, je->j = %d, je->ele = %e\n",k,je->j,je->ele);
      #endif
      Aconvert[k].push_back(je);
    }
  }
  
  int nzmax = 0;
  for (size_t k=0; k<mDim; ++k) {
    sort(Aconvert[k].begin(),Aconvert[k].end(),JE::compare);
    nzmax += Aconvert[k].size();
  }
  
  // Note that AtConvert is transposed AConvert
  plhs[0] = mxCreateSparse(nDim,mDim,nzmax,mxREAL);
  mxArray* AtConvert_ptr = plhs[0];
  mwIndex* AtConvertRow    = mxGetIr(AtConvert_ptr);
  mwIndex* AtConvertColumn = mxGetJc(AtConvert_ptr);
  double*  AtConvertEle    = mxGetPr(AtConvert_ptr);
  AtConvertColumn[0] = 0;
  int AtIndex = 0;
  for (size_t k=0; k<mDim; ++k) {
    vector<JE*>* Aconvertk = &Aconvert[k];
    int length = Aconvertk->size();
    for (int index=0; index<length; ++index) {
      JE* je = Aconvertk->at(index);
      AtConvertRow[AtIndex] = je->j;
      AtConvertEle[AtIndex] = je->ele;
      AtIndex++;
      #if PRINT_DEBUG
      mexPrintf("k = %d, je->j = %d, je->ele = %e\n",k,je->j,je->ele);
      #endif
    }
    AtConvertColumn[k+1] = AtConvertColumn[k] + length;
  }

  // KConvert
  const char* KConvert_field_name[1] = {
    "s"
  };
  plhs[2] = mxCreateStructMatrix(1,1,1,KConvert_field_name);
  mxArray* Kconvert_ptr = plhs[2];
  
  mxArray* KConvertS_ptr = mxCreateDoubleMatrix(1,NoForest,mxREAL);
  mxSetField(Kconvert_ptr,0,KConvert_field_name[0],KConvertS_ptr);
  double* KConvertS = mxGetPr(KConvertS_ptr);
  for (int forestIndex=0; forestIndex<NoForest; ++forestIndex) {
    KConvertS[forestIndex] = forest->at(forestIndex)->blockSize;
  }

  // cliqueConvert
  const int cliqueConvertFieldNumber = 3;
  const char* cliqueConvertFieldName[cliqueConvertFieldNumber] = {
    "NoC", "Elem", "NoElem"
  };
  plhs[3] = mxCreateCellMatrix(1,NoForest);
  mxArray* cliqueConvert_ptr = plhs[3];
  
  for (int forestIndex = 0; forestIndex < NoForest; ++forestIndex) {
    mxArray* clique_ptr = mxCreateStructMatrix(1,1,cliqueConvertFieldNumber,
					       cliqueConvertFieldName);
    mxSetCell(cliqueConvert_ptr,forestIndex,clique_ptr);
    
    int totalNoElem = 0;
    vector<Clique*>* clique_p = forest->at(forestIndex)->clique_p;
    int NoC = clique_p->size();
    for (int i=0; i<NoC; ++i) {
      totalNoElem += clique_p->at(i)->size;
    }
    #if 0 |PRINT_DEBUG
    mexPrintf("forestIndex = %d, NoC = %d, Elem = %d\n",
	      forestIndex, NoC, totalNoElem);
    #endif
    
    mxArray* NoC_ptr = mxCreateDoubleScalar(NoC);
    mxSetField(clique_ptr, 0, cliqueConvertFieldName[0], NoC_ptr);

    // Elem and NoElem are row vectors
    mxArray* Elem_ptr   = mxCreateDoubleMatrix(1,totalNoElem,mxREAL);
    mxSetField(clique_ptr, 0, cliqueConvertFieldName[1], Elem_ptr);
    double* Elem   = mxGetPr(Elem_ptr);
    mxArray* NoElem_ptr = mxCreateDoubleMatrix(1,NoC,mxREAL);
    mxSetField(clique_ptr, 0, cliqueConvertFieldName[2], NoElem_ptr);
    double* NoElem = mxGetPr(NoElem_ptr);
    
    for (int i=0; i<NoC; ++i) {
      NoElem[i] = (double) clique_p->at(i)->size;
    }
    #if 0 | PRINT_DEBUG
    mexPrintf("NoElem = ");
    for (int i=0; i<NoC; ++i) {
      mexPrintf("%d ", (int) NoElem[i]);
    }
    mexPrintf("\n");
    #endif
    
    int index = 0;
    for (int ind1=0; ind1<NoC; ++ind1) {
      Clique* targetClique = clique_p->at(ind1);
      int length = targetClique->size;
      for (int ind2=0; ind2<length; ++ind2) {
	int j = targetClique->ele[ind2];
	int jConvert = blockIndex[j];
	Elem[index] = (double) (jConvert+1);
	index++;
      }
    }
    #if 0 | PRINT_DEBUG
    mexPrintf("Elem = ");
    for (int i=0; i<index; ++i) {
      mexPrintf("%d ", (int) Elem[i]);
    }
    mexPrintf("\n");
    #endif
  }

  // NoForest
  plhs[4] = mxCreateDoubleScalar(NoForest);
  
  // retrieveInfo

  const int retrieveInfoFieldNumber = 4;
  const char* retrieveInfoFieldName[retrieveInfoFieldNumber] = {
    "noOfSDPcones", "s", "retrieveIndex", "sDim"
  };
  plhs[5] = mxCreateStructMatrix(1,1,retrieveInfoFieldNumber,
				 retrieveInfoFieldName);
  mxArray* retrieveInfo_ptr = plhs[5];
  mxArray* noOfSDPcones_ptr = mxCreateDoubleScalar(NoForest);
  mxSetField(retrieveInfo_ptr, 0,
	     retrieveInfoFieldName[0], noOfSDPcones_ptr);
  mxArray* riS_ptr = mxCreateDoubleMatrix(1,NoForest,mxREAL);
  mxSetField(retrieveInfo_ptr, 0,
	     retrieveInfoFieldName[1], riS_ptr);
  double* riS = mxGetPr(riS_ptr);
  for (int forestIndex = 0; forestIndex < NoForest; ++forestIndex) {
    riS[forestIndex] = (double)forest->at(forestIndex)->blockSize;
  }
  

  mxArray* riRI_ptr = mxCreateDoubleMatrix(1,sDim,mxREAL);
  mxSetField(retrieveInfo_ptr, 0,
	     retrieveInfoFieldName[2], riRI_ptr);
  double* riRI = mxGetPr(riRI_ptr);
  int* ForestStart = new int[NoForest+1];
  ForestStart[0] = 0;
  for (int forestIndex=0; forestIndex < NoForest; ++forestIndex) {
    int bSize   = forest->at(forestIndex)->blockSize;
    ForestStart[forestIndex+1] = ForestStart[forestIndex] + bSize;
  }
  for (int i=0; i<sDim; ++i) {
    int blockNumber_i = blockNumber[i];
    int blockIndex_i  = blockIndex [i];
    riRI[ForestStart[blockNumber_i]+blockIndex_i] = i+1;
  }
  mxArray* risDim_ptr = mxCreateDoubleScalar(sDim);
  mxSetField(retrieveInfo_ptr, 0,
	     retrieveInfoFieldName[3], risDim_ptr);

  #if 0 | PRINT_DEBUG
  mexPrintf("retrieveInfo Cones ::[%d]:: ", NoForest);
  for (int forestIndex=0; forestIndex < NoForest; ++forestIndex) {
    mexPrintf("%d ",(int)riS[forestIndex]);
  }
  mexPrintf("\n");
  mexPrintf("retrieveIndex ::[%d]:: ", sDim);
  for (int i=0; i<sDim; ++i) {
    mexPrintf("%d ", (int)riRI[i]);
  }
  mexPrintf("\n");
  #endif
  
  // Delete All memory space
  for (int i=0; i<Cconvert->size(); ++i) {
    delete Cconvert->at(i);
  }
  delete Cconvert;
  for (int k=0; k< mDim; ++k) {
    for (int i=0; i<Aconvert[k].size(); ++i) {
      delete Aconvert[k].at(i);
    }
  }
  delete[] Aconvert;
  for (int i=0; i<NoForest; ++i) {
    forest->at(i)->finalize();
  }
  delete forest;
  for (int i=0; i<NoClique; ++i) {
    clique[i].finalize();
  }
  delete[] clique;

  delete[] blockNumber;
  delete[] blockIndex;
  delete[] blockSize;
  delete[] blockStart;
  delete[] ForestStart;
  // mexPrintf("Here at Line %d\n",__LINE__);
    
      
  // [AtConvert,CtConvert,KConvert,cliqueConvert,NoForest]
  //   = mexForestConvert(At,Ct,sDim,clique)
}
