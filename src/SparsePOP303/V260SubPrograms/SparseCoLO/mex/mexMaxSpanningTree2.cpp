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
#include <vector>
#include <algorithm>

#include <mex.h>

#include "ccputime.h"
#if linux == 0
typedef int mwSize;
typedef int mwIndex;
#endif


using namespace std;

class Edge
{
public:
  mwIndex i,j;
  int weight, degree, edge_number;
  Edge(mwIndex i,mwIndex j,int weight, int degree, int edge_number);
  static bool compare(Edge* a, Edge* b);
};

Edge::Edge(mwIndex i, mwIndex j, int weight, int degree, int edge_number)
{
  this->i = i;
  this->j = j;
  this->weight      = weight;
  this->degree      = degree;
  this->edge_number = edge_number;
}

bool Edge::compare(Edge* a, Edge* b)
{
  // Note : Decending order
  if (a->weight > b->weight) {
    return true;
  }
  return false;
}


void mexFunction(int nlhs, mxArray* plhs[],
		 int nrhs, const mxArray* prhs[])
{

  if (nrhs!=2) {
    mexErrMsgTxt("The Number of Input is 2\n");
  }
  if (!mxIsDouble(prhs[0])) {
    mexErrMsgTxt("prhs[0] (edgeCostVectC) should be double\n");
  }
  if (!mxIsDouble(prhs[1]) || !mxIsSparse(prhs[1])) {
    mexErrMsgTxt("prhs[1] (incidenceMatrixC) should be double and sparse\n");
  }
  if (nlhs!=2) {
    mexErrMsgTxt("The Number of Output is 2\n");
  }
      
  vector<Edge*>* edges;
  edges = NULL;
  edges = new vector<Edge*>;
  if (edges == NULL) {
    mexErrMsgTxt("Memory exhausted");
  }
  
  TimeStart(FILE_READ_START);

  const mxArray* edgeCostVectC    = prhs[0];
  const mxArray* incidenceMatrixC = prhs[1];

  double new_time = 0.0;
  // M = edge number, N = node number
  const size_t M = mxGetN(incidenceMatrixC);
  const size_t N = mxGetM(incidenceMatrixC);
  #if PRINT_ESSENTIAL
  mexPrintf("M = %zd, N = %zd\n",M,N);
  #endif
  mwIndex* incidenceRow    = mxGetIr(incidenceMatrixC);
  mwIndex* incidenceColumn = mxGetJc(incidenceMatrixC);
  double* edgeCostEle  = mxGetPr(edgeCostVectC);
  for (size_t edgeNumber = 0; edgeNumber < M; ++edgeNumber) {
    mwIndex i = incidenceRow[incidenceColumn[edgeNumber]];
    mwIndex j = incidenceRow[incidenceColumn[edgeNumber]+1];
    int weight = (int) edgeCostEle[edgeNumber];
    TimeStart(NEW_START);
    Edge* edge;
    edge = NULL;
    edge = new Edge(i, j, weight, 0, edgeNumber);
    if (edge == NULL) {
      mexErrMsgTxt("Memory exhausted");
    }
    edges->push_back(edge);
    TimeEnd(NEW_END);
    new_time += TimeCal(NEW_START,NEW_END);
  }
  TimeEnd(FILE_READ_END);
  double file_read = TimeCal(FILE_READ_START,FILE_READ_END);
  #if PRINT_TIME
  mexPrintf("file read = %lf second\n",file_read);
  mexPrintf("new  time = %lf second\n",new_time);
  #endif
  
  // mexPrintf("# edges = %d\n",edges->size());
  
  TimeStart(SORT_START);
  // sort(edges->begin(), edges->end(), Edge::compare);
  #if PRINT_DEBUG
  for (size_t k=0; k<M; ++k) {
    Edge* a = edges->at(k);
    mexPrintf("Sort:: (%zd,%zd), w=%d, d=%d, NO=%d\n",
	   a->i,a->j,a->weight,a->degree,a->edge_number);
  }
  #endif
  TimeEnd(SORT_END);
  double sort_time = TimeCal(SORT_START,SORT_END);
  #if PRINT_TIME
  mexPrintf("sort time = %lf second\n",sort_time);
  #endif
  
  TimeStart(TREE_START);
  int* forest;
  forest = NULL;
  forest = new int[N];
  if (forest == NULL) {
    mexErrMsgTxt("Memory exhausted");
  }
  // if forest[i] < 0, the i-th node does not attend to any forest yet.
  // In particular, to check whether the nodes belong to the same
  // forest with smaller cost, initial values distinct negative integers.
  for (size_t i=0; i<N; ++i) {
    forest[i] = -1-i;
  }
  size_t* nodeDegree;
  nodeDegree = NULL;
  nodeDegree = new size_t[N];
  if (nodeDegree == NULL) {
    mexErrMsgTxt("Memory exhausted");
  }
  for (size_t i=0; i<N; ++i) {
    nodeDegree[i] = 0;
  }
  
  // mexPrintf("M = %zd\n",M);
  size_t treeEdge = 0;
  size_t forestNumber = 1;
  vector<Edge*>* spanningTree;
  spanningTree = NULL;
  spanningTree = new vector<Edge*>;
  if (spanningTree == NULL) {
    mexErrMsgTxt("Memory exhausted");
  }
  int previousWeight = -1;
  size_t currentWeightLast = 0;
  
  for (size_t k=0; k<M; ++k) {
    if (treeEdge==N-1) {
      break;
    }
    Edge* a = edges->at(k);
    if (previousWeight != a->weight) {
      previousWeight = a->weight;
      size_t l=k+1;
      for (; l<M; ++l) {
	Edge* b = edges->at(l);
	if (b->weight != a->weight) {
	  break;
	}
	b->degree = nodeDegree[b->i] + nodeDegree[b->j];
      }
      currentWeightLast = l;
      #if PRINT_DEBUG
      rMessage("currentWeightLast = " << currentWeightLast);
      #endif
    }

    size_t min_degree_index = k;
    int min_degree = a->degree;
    for (size_t l=k+1; l<currentWeightLast; ++l) {
      Edge* b = edges->at(l);
      if (b->degree < min_degree) {
	min_degree = b->degree;
	min_degree_index = l;
      }
      else if (b->degree == min_degree) {
	// if max degree is smaller, then we adopt it
	int a_i = nodeDegree[a->i];
	int a_j = nodeDegree[a->j];
	int b_i = nodeDegree[b->i];
	int b_j = nodeDegree[b->j];

	if (a_i < a_j ) {
	  a_i = a_j;
	}
	if (b_i < b_j ) {
	  b_i = b_j;
	}
	if (b_i < a_i) {
	  min_degree = b->degree;
	  min_degree_index = l;
	}
      }
      
    }
    #if PRINT_DEBUG
    mexPrintf("k= %zd, min_degree_index = %zd, min_degree = %d\n",
	   k,min_degree_index,min_degree);
    #endif
    if (min_degree_index != k) {
      Edge* tmp = edges->at(k);
      edges->at(k) = edges->at(min_degree_index);
      edges->at(min_degree_index) = tmp;
    }
    a = edges->at(k);
    #if PRINT_DEBUG
    mexPrintf("Challenge (%zd,%zd)\n",a->i,a->j);
    #endif
    
    size_t i=a->i;
    size_t j=a->j;
    if (forest[i] == forest[j]) {
      // Do not add this edge to avoid a cycle
      continue;
    }
    
    if (forest[i] < 0 && forest[j] <0) {
      spanningTree->push_back(a);
      forest[i] = forest[j] = forestNumber;
      forestNumber++;
    }
    else if (forest[i] < 0 && forest[j] >0 ) {
      spanningTree->push_back(a);
      forest[i] = forest[j];
    }
    else if (forest[i] > 0 && forest[j] <0 ) {
      spanningTree->push_back(a);
      forest[j] = forest[i];
    }
    else if (forest[i] > 0 && forest[j] > 0) {
      spanningTree->push_back(a);
      int forest_small = forest[i];
      int forest_large = forest[j];
      if (forest[j] < forest[i]) {
	forest_small = forest[j];
	forest_large = forest[i];
      }
      for (size_t l=0; l<N; ++l) {
	if (forest[l] == forest_large) {
	  forest[l] = forest_small;
	}
      }
    }

    #if PRINT_DEBUG
    mexPrintf("edge added (%zd,%zd)\n",i,j);
    #endif
    treeEdge++;
    nodeDegree[i]++;
    nodeDegree[j]++;
    for (size_t l=k+1; l<currentWeightLast; ++l) {
      Edge* b = edges->at(l);
      b->degree = nodeDegree[b->i] + nodeDegree[b->j];
      #if PRINT_DEBUG
      rMessage("edge["<< b->i << "," << b->j
	       << "]:degree = " << b->degree);
      #endif
    }
  }

  size_t spanningTreeSize = spanningTree->size();
  #if PRINT_ESSENTIAL
  if (spanningTreeSize == N-1) {
    mexPrintf("SPANNED\n");
  }
  else {
    mexPrintf("MULTIPLE FORESTS\n");
  }
  #endif
  TimeEnd(TREE_END);
  double tree_time = TimeCal(TREE_START,TREE_END);
  #if PRINT_TIME
  mexPrintf("tree time = %lf second\n",tree_time);
  #endif

  #if PRINT_DEBUG
  for (size_t i=0; i<N; ++i) {
    mexPrintf("nodeDegree[%zd] = %d\n",i,nodeDegree[i]);
  }
  #endif
  int totalDegree = 0;
  int totalWeight = 0;

  for (size_t k=0; k<M; ++k) {
    Edge* a = edges->at(k);
    a->degree = nodeDegree[a->i] + nodeDegree[a->j];
  }
  for (size_t k=0; k<spanningTreeSize; ++k) {
    Edge* a = spanningTree->at(k);
    totalDegree += a->degree;
    totalWeight += a->weight;
  }
  #if PRINT_DEBUG
  mexPrintf("totalDegree = %d\n",totalDegree);
  mexPrintf("totalWeight = %d\n",totalWeight);
  #endif

  #if PRINT_ESSENTIAL
  if (totalDegree == (int)(4*N-6) && spanningTreeSize == N-1) {
    rMessage("We obtain LINE graph");
  }
  #endif

  #if PRINT_DEBUG
  for (size_t k=0; k<spanningTreeSize; ++k) {
    Edge* a = spanningTree->at(k);
    mexPrintf("Tree:: (%zd,%zd) , w=%d, d=%d, NO=%d\n",
	   a->i,a->j,a->weight,a->degree,a->edge_number);
  }
    
  #endif
  
  #if PRINT_DEBUG
  for (size_t i=0; i<N; ++i) {
    mexPrintf("forest[%zd] = %d\n",i,forest[i]);
  }
  #endif

  TimeStart(FILE_WRITE_START);
  // treeValue = totalWeight
  plhs[0] = mxCreateDoubleScalar(totalWeight);
  // basisIdx
  plhs[1] = mxCreateDoubleMatrix(spanningTreeSize,1,mxREAL);
  double* eleBasisIdx = mxGetPr(plhs[1]);
  for (size_t k=0; k<spanningTreeSize; ++k) {
    Edge* a = spanningTree->at(k);
    eleBasisIdx[k] = a->edge_number+1;
  }
  TimeEnd(FILE_WRITE_END);
  double file_write_time = TimeCal(FILE_WRITE_START,FILE_WRITE_END);
  #if PRINT_TIME
  mexPrintf("file write = %lf second\n",file_write_time);
  #endif

  TimeStart(DELETE_START);
  if (nodeDegree) {
    delete[] nodeDegree;
    nodeDegree = NULL;
  }
  if (forest) {
    delete[] forest;
    forest = NULL;
  }
  for (size_t k=0; k<M; ++k) {
    Edge* a = edges->at(k);
    if (a) {
      delete a;
    }
    edges->at(k) = NULL;
  }
  if (edges) {
    delete edges;
    edges = NULL;
  }
  if (spanningTree) {
    delete spanningTree;
  }
  TimeEnd(DELETE_END);
  double delete_time = TimeCal(DELETE_START,DELETE_END);
  #if PRINT_TIME
  mexPrintf("delete time = %lf second\n",delete_time);
  #endif
}
  
