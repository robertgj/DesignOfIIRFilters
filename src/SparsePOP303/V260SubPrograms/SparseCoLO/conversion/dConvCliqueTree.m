%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [LOP,clique] = dConvCliqueTree(A,sPatternVect,b,c,K,J)

%
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
%

printCpuTimeSW = 0; 

% function dConvCliqueTree

% The d-space conversion method using clique trees
% 2009/01/13
% Masakazu Kojima
% 
% Input LOP problem 
%   minimize	c^T x
%   subject to	A x - b \in coneJ, x \in coneK
%
% input data
%   A : a matrix
%   b : a column vector
%   c : a column vector
%   K denotes a conic structre of the domain space consisting of 
%       K.f --- the dimension of free variables
%       K.l --- the dimension of LP variables
%       K.q --- the sizes of second-order cone variables
%       K.s --- the sizes of matrix variables
%   J denotes a conic structure of the constraint in the range space
%       J.f --- the dimension of equality constraints 
%       J.l --- the dimension of LP constraints
%       J.q --- the sizes of second-order cone constraints 
%       J.s --- the sizes of LMI constraints 
%
%   sPetternVect
%       
% global MEMORY
% if MEMORY == 1
%     d = whos('*');
%     mem = 0;
%     for i=1:length(d)
%         mem = mem + d(i).bytes;
%     end
% end

startingTime = cputime;

LOP = [];
clique = [];
convMat = [];

[mDim0,nDim0] = size(A); 

if nargin <= 5
    J.f = mDim0; 
elseif ~isfield(J,'f') | isempty(J.f)
	J.f = 0;
end

LOP.J = J; 

if ~isfield(K,'s') || isempty(K.s) 
%    fprintf('## No conversion because K.s = [].\n'); 
    LOP.A = A;
    LOP.b = b;
    LOP.c = c;
    if size(LOP.c,1) < size(LOP.c,2)
        LOP.c = LOP.c';
    end
    LOP.K = K;
    LOP.J = J;
    clique = [];
    convMat = [];
    return
else
    sDimTotal = 0;
    for i=1:length(K.s)
        sDimTotal = sDimTotal + K.s(i)*K.s(i); 
    end
end

% Transpose c if c is a column vector 
if size(c,2) < size(c,1)
    c = c';
end
% Transpose b if b is a row vector 
if size(b,1) < size(b,2)
    b = b';
end

% size(c)

% Check the dimensions of non SDP cones 
if isfield(K,'f') && ~isempty(K.f) && K.f > 0 
    fDim = K.f;
    LOP.K.f = K.f;
else
    fDim = 0; 
end
if isfield(K,'l') && ~isempty(K.l) && K.l > 0 
    ellDim = K.l;
    LOP.K.l = K.l; 
else
    ellDim = 0; 
end
if isfield(K,'q') && ~isempty(K.q)
    qDim = sum(K.q); 
    LOP.K.q = K.q; 
else
    qDim = 0; 
end
if isfield(K,'r') && ~isempty(K.r)
    rDim = sum(K.r); 
    LOP.K.r = K.r; 
else
    rDim = 0; 
end

nonSDPdim = fDim+ellDim+qDim+rDim; 

mDimA = size(A,1); 

% Initialization ---> 
    LOP.A = A(:,1:nonSDPdim); % To be updated 
    LOP.b = b; % To be apdated
    LOP.c = c(1:nonSDPdim); %To be updated
    LOP.K.s = [];
    nDim = nonSDPdim; % To be updated
    mDim = mDimA; % To be updated
    colPointer = nonSDPdim;
% <--- Initialization

noOfSDPcones = length(K.s); 

timeForSparsityPattern = 0;
timeForClique = 0; 
timeForConversion = 0;

% K
% colPointer
% size(sPatternVect)
% noOfSDPcones
% 
ccIndex = 1;
for  kk =1:noOfSDPcones
    %    kk
    startingTime = cputime;
    sDim = K.s(kk);
    if ~isempty(sPatternVect)
        spVect = sPatternVect(colPointer+1:colPointer+sDim*sDim);
        if nnz(spVect) == 0
            spVect = [];
        end
    else
        spVect = [];
    end
    Kadd.s = sDim; 
    startingTime = cputime;
    if ~isempty(spVect)
        [spacityPatternMat] = genSparsityPatternMat([A(:,colPointer+1:colPointer+sDim*sDim);spVect],c(1,colPointer+1:colPointer+sDim*sDim),Kadd);
    else
        [spacityPatternMat] = genSparsityPatternMat(A(:,colPointer+1:colPointer+sDim*sDim),c(1,colPointer+1:colPointer+sDim*sDim),Kadd);
    end
    if printCpuTimeSW == 1
        fprintf('//  genSparsityPatternMat time = %e\n',cputime-startingTime); 
    end

    % <--- Construction of the aggregated sparsity pattern
    timeForSparsityPattern = timeForSparsityPattern + cputime - startingTime;
    startingTime = cputime;
    [oneClique] = cliquesFromSpMatD(spacityPatternMat);
    timeForClique = timeForClique + cputime - startingTime;
    Apart = A(:,colPointer+1:colPointer+sDim*sDim);
    Cpart = c(:,colPointer+1:colPointer+sDim*sDim);
    
    startingTime = cputime;
    printCpuTimeSW = 0; 
    if printCpuTimeSW == 1 
        fprintf('*** Forest Convert Start ***  \n');
    end
    [AConvert,CConvert,KConvert,cliqueConvert,NoForest,retrieveInfoKK] = ...
        forestConvert(Apart,Cpart,sDim,oneClique);
    retrieveInfo{kk} = retrieveInfoKK;
    printCpuTimeSW = 0;
    if printCpuTimeSW == 1 
        fprintf('*** Forest Convert End   *** ');No
        fprintf('//  NoForest = %d, time = %e\n',NoForest,cputime-startingTime);
    end
    printCpuTimeSW = 0; 
    colP = 0;
    for tt=1:NoForest
        Ktt.s = KConvert.s(tt);
        Att = AConvert(:,colP+1:colP+Ktt.s * Ktt.s);
        Ctt = CConvert(1,colP+1:colP+Ktt.s * Ktt.s);
        if 0
            cliqueConvert{tt}
            cliqueConvert{tt}.Elem
            cliqueConvert{tt}.NoElem
            cliqueConvert{tt}.idxMatrix
            cliqueConvert{tt}.Set
        end
        if cliqueConvert{tt}.NoC == 1
            AbarAdd   = Att;
            cbarAdd   = Ctt;
            KbarAdd.s = Ktt.s;
            oneCliqueTT = cliqueConvert{tt};
        else
            if printCpuTimeSW == 1
                fprintf('sparsePrimal\n');
            end
            startingTime = cputime;
                       
            [AbarAdd,cbarAdd,KbarAdd,oneCliqueTT] = ...
                sparsePrimal(Att,Ctt,Ktt,cliqueConvert{tt});
            
            if printCpuTimeSW == 1
                fprintf('//  sparsePrimal time = %e\n',cputime-startingTime); 
            end
        end
        clique{ccIndex} = oneCliqueTT;
        ccIndex = ccIndex + 1;
        colP = colP + Ktt.s * Ktt.s;
        
        mDimAdd = size(AbarAdd,1) - mDimA;
        nDimAdd = size(AbarAdd,2);
        % update --->
        LOP.A = [ [LOP.A(1:mDimA,:),      AbarAdd(1:mDimA,:)]; ...
                  [LOP.A(mDimA+1:mDim,:),sparse(mDim-mDimA,nDimAdd)]; ...                      
                  [sparse(mDimAdd,nDim), AbarAdd(mDimA+1:mDimA+mDimAdd,:) ] ];
        LOP.b = [LOP.b; sparse(mDimAdd,1)];
        LOP.c = [LOP.c, cbarAdd]; % [LOP.c; cbarAdd];
        LOP.K.s = [LOP.K.s, KbarAdd.s];
        mDim = mDim + mDimAdd;
        nDim = nDim + nDimAdd;
    end
    % Adjust kk for increment of the end of this 'while'
    timeForConversion = timeForConversion + cputime - startingTime;
    % <--- update
    colPointer = colPointer + sDim*sDim; 

end

[mDim1,nDim1] = size(LOP.A); 

LOP.A = LOP.A([1:J.f, mDim0+1:mDim1,J.f+1:mDim0],:); 
LOP.b = LOP.b([1:J.f, mDim0+1:mDim1,J.f+1:mDim0],:);
LOP.J.f = LOP.J.f + mDim1 - mDim0; 

if size(LOP.c,1) < size(LOP.c,2)
    LOP.c = LOP.c';
end

%%%%%%%%%%%%%%%%%%
if size(retrieveInfo,2) < size(clique,2)
    [clique] = unifyForests(clique,retrieveInfo);
end
clear retrieveInfo
%%%%%%%%%%%%%%%%%%

debugSW = 0;
if debugSW == 1
    LOP.K.s
    for kk=1:noOfSDPcones
        idx = 0; 
        if printCpuTimeSW == 1 
            fprintf('clique{%d}.Set\n',kk);
        end
        for p=1:clique{kk}.NoC
            p
            sDimE = clique{kk}.NoElem(p);
            clique{kk}.Elem(idx+(1:sDimE))
            idx + sDimE; 
        end
    end
    noOfSDPcones = length(LOP.K.s);
    [rowSize,colSize] = size(LOP.A);
    if printCpuTimeSW == 1 
        fprintf('LOP.K.s = \n');
        fprintf('Cbar = \n');
    end
    pointer = 0;
    for k=1:noOfSDPcones
        full(reshape(LOP.c(pointer+1:pointer+LOP.K.s(k)*LOP.K.s(k),1),LOP.K.s(k),LOP.K.s(k)))
        pointer = pointer + LOP.K.s(k)*LOP.K.s(k);  
    end
    for i=1:rowSize
        if printCpuTimeSW == 1 
            fprintf('LOP.A{%d} = \n',i);
        end
        pointer = 0;
        for k=1:noOfSDPcones
            full(reshape(LOP.A(i,pointer+1:pointer+LOP.K.s(k)*LOP.K.s(k)),LOP.K.s(k),LOP.K.s(k)))
            pointer = pointer + LOP.K.s(k)*LOP.K.s(k);  
        end
    end
    XXXXX
end

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
