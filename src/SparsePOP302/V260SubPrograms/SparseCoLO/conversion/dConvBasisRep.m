%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [LOP,clique,convMat] = dConvBasisRep0(A,sPatternVect,b,c,K,J)

% 01/27/2009, Modified by Kojima 

printCpuTimeSW = 0;

% function dConvBasisRep

% fprintf('## Conversion of a primal LOP into a sparse dual LOP based on the psd completion\n');

% The d-space conversion method using basis representation
% 2009/01/10
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

startingTime = cputime;

rowSizeA = size(A,1); 
colSizeA = size(A,2); 

LOP = [];
clique = [];
convMat = [];

if ~isfield(K,'s') || isempty(K.s) 
%    fprintf('## No conversion because K.s = [].\n'); 
    LOP.A = A;
    LOP.b = b;
    LOP.c = c;
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

if nargin <= 5
    J.f = size(A,1); 
    J.l = [];
    J.q = [];
    J.s = [];
else
    if ~isfield(J,'f')
        J.f = [];
    end
    if ~isfield(J,'l')
        J.l = [];
    end
    if ~isfield(J,'q')
        J.q = [];
    end
    if ~isfield(J,'s')
        J.s = [];
    end    
end

% Transpose c if c is a row vector 
if size(c,1) < size(c,2)
    c = c';
end
% Transpose b if b is a row vector 
if size(b,1) < size(b,2)
    b = b';
end

LOP.K = K;
LOP.K.s = [];
LOP.J = J; 

% Check the dimensions of free variables 
colPointer = 0; 
if isfield(K,'f') && ~isempty(K.f) && K.f > 0 
    fDim = K.f; 
    cVectFree = c(colPointer+1:colPointer+K.f,:); 
    AMatFree = A(:,colPointer+1:colPointer+K.f); 
    colPointer = colPointer + K.f; 
else
    fDim = 0; 
    LOP.K.f = 0; 
    cVectFree = []; 
    AMatFree = [];
end
% Check the dimensions of LP variables
if isfield(K,'l') && ~isempty(K.l) && K.l > 0 
    ellDim = K.l; 
    cVectOthers = c(colPointer+1:colPointer+K.l,:);
    AMatOthers = A(:,colPointer+1:colPointer+K.l);     
    colPointer = colPointer + K.l;
else
    ellDim = 0; 
    cVectOthers = [];
    AMatOthers = [];     
end
% Check the dimensions of SOCP variables
if isfield(K,'q') && ~isempty(K.q)
    qDim = sum(K.q);
    LOP.K.q = K.q;
    cVectOthers = [cVectOthers;c(colPointer+1:colPointer+qDim,:)];
    AMatOthers = [AMatOthers,A(:,colPointer+1:colPointer+qDim)];
    colPointer = colPointer + qDim;
else
    qDim = 0;   
end


% Initialization --->
rowSizeAMatFree0 = rowSizeA; % size(AMatFree,1); % 01/27/2009, fixed 
rowSizeAMatFree = rowSizeAMatFree0; 
colSizeAMatFree0 = size(AMatFree,2);
colSizeAMatFree = colSizeAMatFree0; 
colSizeAMatOthers = size(AMatOthers,2);
% <--- Initialization

noOfSDPcones = length(K.s);
clique = cell(1,noOfSDPcones);
convMat = cell(1,noOfSDPcones);

colPointer = fDim+ellDim+qDim; 

cliquePointer = 0; 

for kk=1:noOfSDPcones
%    startingTime = cputime;
    sDim = K.s(kk);
    if ~isempty(sPatternVect)
        spVect = sPatternVect(colPointer+(1:sDim*sDim));
        if nnz(spVect) == 0
            spVect = [];
        end
    else
        spVect = [];
    end
    Kadd.s = sDim;
    %%%%%
    startingTime = cputime; 
    if ~isempty(spVect)
        [sparsityPatternMat] = ...
            genSparsityPatternMat([A(:,colPointer+(1:sDim*sDim));spVect],c(colPointer+(1:sDim*sDim),1),Kadd);
    else
        [sparsityPatternMat] = ...
            genSparsityPatternMat(A(:,colPointer+(1:sDim*sDim)),c(colPointer+(1:sDim*sDim),1),Kadd);
    end
    if printCpuTimeSW == 1 
        fprintf('cpu time for genSparsityPatternMat = %10.5e\n',cputime - startingTime); 
    end
    
    %%%%%
    startingTime = cputime; 
    [oneClique] = cliquesFromSpMatD(sparsityPatternMat); 
    if printCpuTimeSW == 1 
        fprintf('cpu time for cliquesFromSpMatD = %10.5e\n',cputime - startingTime); 
    end
    
    %%%%%%%%%%
    %%%%%%%%%%
    % Information on forest 
    Apart = A(:,colPointer+1:colPointer+sDim*sDim);
    Cpart = c(colPointer+1:colPointer+sDim*sDim,:)';    
    startingTime = cputime;
    % printCpuTimeSW = 0; 
    if 0 == 1 % printCpuTimeSW == 1 
        fprintf('*** Forest Convert Start ***  \n');
    end
    [AConvert,CConvert,KConvert,cliqueConvert,NoForest,retrieveInfoKK] = ...
        forestConvert(Apart,Cpart,sDim,oneClique);
    retrieveInfo{kk} = retrieveInfoKK;
%     size(cliqueConvert,2)
%     for i=1:10
%         cliqueConvert{i}
%     end
%     retrieveInfoKK
    ii = size(cliqueConvert,2); 
    for i=1:ii
        cliquePointer = cliquePointer+1; 
        clique{cliquePointer} = cliqueConvert{i};
    end
    %%%%%%%%%
    % clique{kk} = oneClique;
    %%%%%%%%%%
    %%%%%%%%%%
    
    % printCpuTimeSW = 0;
    if 0 == 1 % printCpuTimeSW == 1 
        fprintf('*** Forest Convert End   *** ');No
        fprintf('//  NoForest = %d, time = %e\n',NoForest,cputime-startingTime);
    end
    %%%%%%%%%%
    
    %%%%%%%%%%
%    fprintf('## no. of cliques = %4d, min clique = %3d, max clique = %3d, average size = %5.1f\n',...
%        oneClique.NoC,oneClique.minC,oneClique.maxC,sum(oneClique.NoElem)/oneClique.NoC);
    %%%%%%%%%%
    startingTime = cputime; 
    [AbarAdd,bAdd,KbarAdd,convMatAdd] = ...
        primalToSparseDual(A(:,colPointer+(1:sDim*sDim)),c(colPointer+(1:sDim*sDim),1),Kadd,oneClique);
    if printCpuTimeSW == 1 
        fprintf('cpu time for primalToSparseDual = %10.5e\n',cputime - startingTime); 
    end
    convMat{kk} = convMatAdd;
    AbarAdd = AbarAdd'; 
    cVectFree = [cVectFree; -bAdd]; 
    rowSizeAbarAdd = size(AbarAdd,1); 
    colSizeAbarAdd = size(AbarAdd,2); 
    AbarAddFree = AbarAdd(1:rowSizeAMatFree0,:);
    AbarAddsdp = AbarAdd(rowSizeAMatFree0+1:rowSizeAbarAdd,:); 
    AMatFree = [[AMatFree,[AbarAddFree;sparse(rowSizeAMatFree-rowSizeAMatFree0,colSizeAbarAdd)]];... 
                [sparse(rowSizeAbarAdd-rowSizeAMatFree0,colSizeAMatFree),AbarAddsdp]]; 
    rowSizeAMatFree = size(AMatFree,1); 
    colSizeAMatFree = size(AMatFree,2);     
    %%%%%
    LOP.K.f = LOP.K.f + colSizeAbarAdd; 
    LOP.J.s = [LOP.J.s,KbarAdd.s];
    colPointer = colPointer + sDim*sDim;
end

LOP.c = cVectFree; 
LOP.A = AMatFree;
LOP.b = [b; sparse(rowSizeAMatFree-rowSizeA,1)];
if ~isempty(AMatOthers)
    LOP.c = [LOP.c; cVectOthers]; 
    LOP.A = [LOP.A,[AMatOthers; sparse(rowSizeAMatFree-rowSizeA,colSizeAMatOthers)]]; 
end

%%%%%%%%%%%%%%%%%%
if size(retrieveInfo,2) < size(clique,2)
    [clique] = unifyForests(clique,retrieveInfo);
end
clear retrieveInfo
%%%%%%%%%%%%%%%%%%

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




