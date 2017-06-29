%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sparsityPatternMat] = genSparsityPatternMat(A,c,K)

% Modified by M. Kojima,March 25, 2010

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

sparsityPatternMat = [];

if ~isfield(K,'s') || isempty(K.s)  
    fprintf('## K.s is not assigned.\n');
    return
elseif length(K.s) > 1
    fprintf('## length(K.s) = 1 is assumed in this implementation.\n');
    return
end

fDim = 0;
if isfield(K,'f') && ~isempty(K.f) && K.f > 0 
    fDim = K.f;  
end

ellDim = 0;
if isfield(K,'l') && ~isempty(K.l) && K.l > 0 
    ellDim = K.l;
end

qDim = 0;
if isfield(K,'q') && ~isempty(K.q)
    qDim = sum(K.q); 
end

rDim = 0;
if isfield(K,'r') && ~isempty(K.r)
    rDim = sum(K.r); 
end

nonSDPdim = fDim+ellDim+qDim+rDim; 

%mDim = size(A,1); 
% Dimensions of SDP variables
sDim = 0; 
if isfield(K,'s') && ~isempty(K.s)
    sDim = sum(K.s);
end

if size(c,2) > size(c,1)
    c = c';
end
% Construction of sparsityPatternMat

% Modified by M. Kojima,March 25, 2010 ---> 
% modifySW = 2;
% if modifySW == 0
%     sparsityPatternMat = speye(sDim);    
%     if isfield(K,'s') && ~isempty(K.s)
%         pointer = 0;
%         for p=1:length(K.s)
%             kDim = K.s(p);
%             tempVec = abs(c(nonSDPdim+pointer+(1:kDim*kDim),1))';
%             tempVec = tempVec + sum(abs(A(:,nonSDPdim+pointer+(1:kDim*kDim))),1);
%             tempMat = reshape(tempVec,kDim,kDim);
%             sparsityPatternMat(pointer+(1:kDim),pointer+(1:kDim)) = sparsityPatternMat(pointer+(1:kDim),pointer+(1:kDim)) + tempMat;
%             pointer = pointer + kDim;
%         end
%     end
%     sparsityPatternMat = spones(sparsityPatternMat);
%     debugSW = 1;
%     if debugSW == 1
%         figure(10);
%         spy(sparsityPatternMat);
%     end
% elseif modifySW == 1
%     sparsityPatternMat = [];
%     if isfield(K,'s') && ~isempty(K.s)
%         pointer = 0;
%         for p=1:length(K.s)
%             kDim = K.s(p);
%             tempVec = abs(c(nonSDPdim+pointer+(1:kDim*kDim),1))';
%             tempVec = tempVec + sum(abs(A(:,nonSDPdim+pointer+(1:kDim*kDim))),1);
%             % tempMat = [sparse(pointer,kDim);reshape(tempVec,kDim,kDim);sparse(sDim-pointer-kDim,kDim)];
%             tempMat = [sparse(kDim,kDim), reshape(tempVec,kDim,kDim), sparse(kDim,sDim-pointer-kDim)];            
%             % sparsityPatternMat(pointer+(1:kDim),pointer+(1:kDim)) = sparsityPatternMat(pointer+(1:kDim),pointer+(1:kDim)) + tempMat;
%             sparsityPatternMat = [sparsityPatternMat,tempMat'];
%             pointer = pointer + kDim;                   
%         end        
%     end 
%     sparsityPatternMat = spones(sparsityPatternMat);
% elseif modifySW == 2
    if isfield(K,'s') && ~isempty(K.s)
        nDim = size(c,1);
        tempVect = spones(abs(c(nonSDPdim+1:nDim,1))+ sum(abs(A(:,nonSDPdim+1:nDim)),1)'); 
        pointer = 0;
        pointer2 = 0; 
        sparsityPatternMat = [];        
        for p=1:length(K.s); 
            kDim = K.s(p);
            kDim2 = kDim*kDim; 
            tempMat = [sparse(kDim,pointer), reshape(tempVect(pointer2+1:kDim2,1),kDim,kDim), sparse(kDim,sDim-pointer-kDim)];            
            sparsityPatternMat = [sparsityPatternMat,tempMat'];
            pointer = pointer + kDim; 
            pointer2 = pointer2 + kDim2;                             
        end                
    else 
        sparsityPatternMat = [];            
    end
    % debugSW = 1; 
    % if debugSW == 1
    %     figure(30);
    %     spy(sparsityPatternMat);
    % end
% end
% <--- Modified by M. Kojima,March 25, 2010

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%