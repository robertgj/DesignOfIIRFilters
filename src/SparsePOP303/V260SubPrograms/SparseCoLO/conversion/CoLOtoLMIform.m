function [LOP] = CoLOtoLMIform(A,b,c,K,J); 

% 
% Input LOP problem 
%   minimize	c^T x
%   subject to	A x - b \in coneJ, x \in coneK
%

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

if size(c,1) < size(c,2)
    c = c';
end
if size(b,1) < size(b,2)
    b = b';
end

if isempty(J) 
    J.f = size(A,1);
elseif isfield(K,'f') && ~isempty(K.f) && K.f == size(A,2)
    LOP.A = A;
    LOP.A = A;
    LOP.b = b;
    LOP.c = c;
    LOP.J = J; 
    LOP.K = K;
    fprintf('LOP to be converted into LMI standard form is already LMI standard form\n'); 
    return    
end

K0 = K;
J0 = J;

rowSizeA = size(A,1);
colSizeA = size(A,2);

rowPointer = 0;
if isfield(J,'f') && ~isempty(J.f) && J.f > 0
    AMatFree = A(rowPointer+1:rowPointer+J.f,:);
    bVectFree = b(rowPointer+1:rowPointer+J.f,:);
    rowPointer = rowPointer + J.f; 
else
    AMatFree = [];
    bVectFree = [];
end
if isfield(J,'l') && ~isempty(J.l) && J.l > 0
    AMatLP = A(rowPointer+1:rowPointer+J.l,:);
    bVectLP = b(rowPointer+1:rowPointer+J.l,:);
    rowPointer = rowPointer + J.l; 
else
    AMatLP = [];
    bVectLP = [];
end
if isfield(J,'q') && ~isempty(J.q)
    qDim = sum(J.q); 
    AMatSOCP = A(rowPointer+1:rowPointer+qDim,:);
    bVectSOCP = b(rowPointer+1:rowPointer+qDim,:);
    rowPointer = rowPointer + qDim; 
else
    AMatSOCP = [];
    bVectSOCP = [];
end
if isfield(J,'s') && ~isempty(J.s)
    AMatSDP = A(rowPointer+1:rowSizeA,:);
    bVectSDP = b(rowPointer+1:rowSizeA,:);
else
    AMatSDP = [];
    bVectSDP = [];
end

if isfield(K,'f') && ~isempty(K.f) && K.f > 0
    colPointer = K.f; 
else
    K.f = 0;
    colPointer = 0;
end

if isfield(K,'l') && ~isempty(K.l) && K.l > 0
    addRows = sparse(K.l,colSizeA); 
    addRows(:,colPointer+1:colPointer+K.l) = speye(K.l,K.l); 
    AMatLP = [AMatLP; addRows];
    bVectLP = [bVectLP; sparse(K.l,1)]; 
    if isfield(K,'f') && ~isempty(K.f) 
        K.f = K.f + K.l;
    else
        K.f = K.l;
    end
    if isfield(J,'l') && ~isempty(J.l) 
        J.l = J.l + K.l;
    else
        J.l = K.l;
    end
    colPointer = colPointer + K.l; 
    K.l = [];
end

if isfield(K,'q') && ~isempty(K.q)
    for i=1:length(K.q)
        addRows = sparse(K.q(i),colSizeA);
        addRows(:,colPointer+1:colPointer+K.q(i)) = speye(K.q(i),K.q(i));
        AMatSOCP = [AMatSOCP; addRows];
        bVectSOCP = [bVectSOCP; sparse(K.q(i),1)]; 
        if isfield(K,'f') && ~isempty(K.f)
            K.f = K.f + K.q(i);
        else
            K.f = K.q(i);
        end
        if isfield(J,'q') && ~isempty(J.q)
            J.q = [J.q K.q(i)];
        else
            J.q = K.q(i);
        end
        colPointer = colPointer + K.q(i);         
    end
    K.q = [];
end
if isfield(K,'s') && ~isempty(K.s)
    for i=1:length(K.s)
        sDim = K.s(i)*K.s(i); 
        addRows = sparse(sDim,colSizeA);
        addRows(:,colPointer+1:colPointer+sDim) = speye(sDim,sDim);
        AMatSDP = [AMatSDP; addRows];
        bVectSDP = [bVectSDP; sparse(sDim,1)]; 
        colPointer = colPointer + sDim;         
    end
end

AMat = [AMatFree; AMatLP; AMatSOCP; AMatSDP];
clear AMatFree AMatLP AMatSOCP AMatSDP
bVect = [bVectFree; bVectLP; bVectSOCP; bVectSDP];
clear bVectFree bVectLP bVectSOCP bVectSDP

if isfield(K,'s') && ~isempty(K.s)
    AMatSDP = AMat(:,K.f+1:colSizeA);
    AMat = AMat(:,1:K.f); 
    cVectSDP = c(K.f+1:colSizeA,:);
    cVect = c(1:K.f,:); 
    colPointer = 0; 
    for i=1:length(K.s)
        sDim = K.s(i)*K.s(i); 
        LMat = sparse(tril(ones(K.s(i),K.s(i)),-1))*2+speye(K.s(i),K.s(i)); 
        Lvect = reshape(LMat,1,sDim); 
        LMat = diag(Lvect); 
        Lvect = sum(LMat,1); 
        nzCol = find(Lvect > 0); 
        LMat = LMat(:,nzCol);
        for j=1:size(LMat,2)
            tempMat = reshape(LMat(:,j),K.s(i),K.s(i)); 
            tempMat = (tempMat + tempMat')/2; 
            LMat(:,j) = reshape(tempMat,sDim,1);
        end 
        addACols = AMatSDP(:,colPointer+1:colPointer+sDim)*LMat; 
        addcVect = LMat' * cVectSDP(colPointer+1:colPointer+sDim,:); 
        AMat = [AMat, addACols];
        cVect = [cVect; addcVect]; 
        if isfield(K,'f') && ~isempty(K.f)
            K.f = K.f + size(LMat,2);
        else
            K.f = sDim;
        end
        if isfield(J,'s') && ~isempty(J.s)
            J.s = [J.s K.s(i)];
        else
            J.s = K.s(i);
        end
        colPointer = colPointer + sDim;         
    end
    K.s = [];
else
    cVect = c; 
end

LOP.A = AMat;
LOP.b = bVect; 
LOP.c = cVect;
LOP.K.f = K.f; 
LOP.J = J; 

return
