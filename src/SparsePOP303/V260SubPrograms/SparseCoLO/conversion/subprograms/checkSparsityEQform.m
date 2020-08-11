function [matrixA,SDPcone,coSpMat] = checkSparsityEQform(A,b,c,K)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input
%   An equality standard form LOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

[mDim,nDim] = size(A);
matrixA.size = [mDim,nDim];
matrixA.nnz = nnz(A);
% fprintf('size(A) = [%d,%d], nnz(A) = %d\n',mDim,nDim,nnz(A));

% Aggregated sparsity ---> 
colPointer = 0;
if isfield(K,'f') && ~isempty(K.f) && (K.f > 0)
    colPointer = colPointer+K.f; 
end
if isfield(K,'l') && ~isempty(K.l) && (K.l > 0)
    colPointer = colPointer+K.l; 
end
if isfield(K,'q') && ~isempty(K.q) && (sum(K.q) > 0)
    colPointer = colPointer+sum(K.q); 
end
if isfield(K,'r') && ~isempty(K.q) && (sum(K.r) > 0)
    colPointer = colPointer+sum(K.r); 
end

aggregateVec = [c'+sum( abs(A),1)];
aggregateAMat = [];
sDim = 0;
sizeMax = 0;
sizeMin = 1.0e10;
sizeAve = 0; 
if isfield(K,'s') && ~isempty(K.s)% && (length(K.s) > 0)
    sumSize1 = 0; 
    sumSize2 = 0; 
    sumSize3 = 0; 
    noOfCones = length(K.s); 
    for p=1:noOfCones
        temp = K.s(p); 
        sumSize1 = sumSize1 + temp; 
        temp = temp*temp;
        sumSize2 = sumSize2 + temp; 
        sumSize3 = sumSize3 + temp*K.s(p); 
        sizeMax = max([sizeMax,K.s(p)]);
        sizeMin = min([sizeMin,K.s(p)]);
        sizeAve = sizeAve + K.s(p); 
        if sDim == 0
            aggregateAMat = reshape(aggregateVec(1,colPointer+1:colPointer+K.s(p)*K.s(p)),K.s(p),K.s(p));
        else
            aggregateAMat = [aggregateAMat,sparse(sDim,K.s(p));...
                [sparse(K.s(p),sDim),reshape(aggregateVec(1,colPointer+1:colPointer+K.s(p)*K.s(p)),K.s(p),K.s(p))]];
        end
        sDim = sDim + K.s(p); 
        colPointer = colPointer+K.s(p)*K.s(p);
    end
end
sizeAve = sizeAve/noOfCones; 
SDPcone.sizeMax = sizeMax;
SDPcone.sizeMin = sizeMin;
SDPcone.sizeAve = sizeAve;
SDPcone.length = sumSize1;
SDPcone.area = sumSize2;
SDPcone.volSDP = sumSize3;
SDPcone.noOfCones = noOfCones;

% fprintf('## noOfSdpCones = %d, sizeMax = %d, sizeAve = %7.3e, sizeMin = %d\n',... 
%     noOfCones,sizeMax,sizeAve,sizeMin);
% fprintf('## sumSize1 = %7.3e, sumSize2 = %7.3e, sumSize3 = %7.3e\n',... 
%     sumSize1,sumSize2,sumSize3);
% kkk = size(aggregateAMat,1); 
% aggregateAMat = spones(aggregateAMat) + (kkk+1)*speye(sDim,sDim);
% 
% I = symamd(aggregateAMat);
% 
% LMat = chol(aggregateAMat(I,I)); 
% 
% nnzLplusLprime = 2*nnz(LMat)-size(LMat,1); 
% fprintf('## size(agSpMatForSdp) = %d, nnz(agSpMatForSdp) = %d, nnz(LMat+LMatT) = %d\n',...
%     size(aggregateAMat,1),nnz(aggregateAMat),nnzLplusLprime);
% 
% fprintf('## Graph %d = a sparse Cholesky factorization of the aggregated sparsity pattern\n',figNo0+2);
% figure(figNo0+2);
% spy(LMat);

% Correlative sparsity ---> 
coSpMat.size = size(A,1); 
A = spones(A); 
aggregateAMat = [];
colPointer = 0;
if isfield(K,'f') && ~isempty(K.f) && (K.f > 0)
    aggregateAMat = [aggregateAMat, abs(A(:,colPointer+1:colPointer+K.f))]; 
    colPointer = colPointer+K.f; 
end
if isfield(K,'l') && ~isempty(K.l) && (K.l > 0)
    aggregateAMat = [aggregateAMat, abs(A(:,colPointer+1:colPointer+K.l))]; 
    colPointer = colPointer+K.l; 
end
%%%%%%%%%
if isfield(K,'q') && ~isempty(K.q)
    noOfCones = length(K.q); 
    for p=1:noOfCones
        aggregateAMat = [aggregateAMat, sum(abs( A(:,colPointer+1:colPointer+K.q(p)) ),2)];
        colPointer = colPointer+K.q(p);
    end
end

if isfield(K,'r') && ~isempty(K.q) && (K.r > 0)
    noOfCones = length(K.r); 
    for p=1:noOfCones
        aggregateAMat = [aggregateAMat, sum(abs( A(:,colPointer+1:colPointer+K.r(p)) ),2)];
        colPointer = colPointer+K.r(p);
    end
end
%%%%%%%%%%
if isfield(K,'s') && ~isempty(K.s)% && (length(K.s) > 0)
    noOfCones = length(K.s); 
    for p=1:noOfCones
        aggregateAMat = [aggregateAMat, sum(abs( A(:,colPointer+1:colPointer+K.s(p)*K.s(p)) ),2)];
        colPointer = colPointer+K.s(p)*K.s(p);
    end
end

%%%%%
matrixA.constSComp = sum(sum(aggregateAMat*aggregateAMat',1),2); 
%%%%%

aggregateAMat = spones(aggregateAMat);

% a lower bound of the number of nonzeros in the coSpMat
coSpMat.lbdNnz = max(sum(aggregateAMat,1)); 

if 1 == 1 % (coSpMat.lbdNnz < coSpMat.size/4) || (coSpMat.lbdNnz <= 5000)
    coSpMat.lbdNnz = coSpMat.lbdNnz*coSpMat.lbdNnz; 
    % aggregateAMat = spones(aggregateAMat);
    aggregateAMat = aggregateAMat*aggregateAMat';
    % aggregateAMat = spones(aggregateAMat);
    coSpMat.nnz = nnz(aggregateAMat); 
    
    aggregateAMat = aggregateAMat + 1000*(mDim+1)*speye(mDim,mDim);
    
    I = symamd(aggregateAMat);    
    LMat = spones(chol(aggregateAMat(I,I))');
    
    
    LVect = sum(LMat,1); 
    
    coSpMat.Chol = full(sum((LVect - ones(1,mDim)) .* (LVect +2*ones(1,mDim))))/2; 
    
    coSpMat.nnzLMat = nnz(LMat); 
    
%    nnzLplusLprime = 2*nnz(LMat)-size(LMat,1);
else
    coSpMat.lbdNnz = coSpMat.lbdNnz*coSpMat.lbdNnz; 
    coSpMat.nnz = 0;
    coSpMat.nnzLMat = 0;
end

return


