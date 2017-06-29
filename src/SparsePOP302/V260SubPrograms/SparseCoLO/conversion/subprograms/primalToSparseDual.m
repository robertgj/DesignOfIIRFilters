%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Abar,bbar,Kbar,convMat] = primalToSparseDual(A,c,K,clique)

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

% 20080-06-07 Waki 
% Replace this part by a faster version.
%
% if ORIGINAL == 1
%     % Equality constraint matrix in dual format --->
%     %AbarT = [];
%     Abar = [];
%     bbar = [];
%     sDim = K.s;
%     for row = 1:sDim
%         for col = find(clique.idxMatrix(row,:));
%             posInA = (row-1)*sDim+col;
%             if col == row
%                 bbar = [bbar;-c(posInA,:)];
%                 %            AbarT = [AbarT,A(:,posInA)];
%                 Abar = [Abar; A(:,posInA)'];
%             else
%                 bbar = [bbar; -2*c(posInA,:)];
%                 %            AbarT = [AbarT,2*A(:,posInA)];
%                 Abar = [Abar; 2*A(:,posInA)'];
%             end
%         end
%     end
% elseif ORIGINAL == 0
    if size(c,1) > 1 && size(c,2) > 1
       error('c must be a vector, not a matrix.'); 
    end
    sDim = K.s;
    [J,I] = find(clique.idxMatrix');
    posInA = (I-1)*sDim + J;
    bbar = -2*c(posInA);
    Abar = 2*A(:,posInA);
    eqIdx = find(J == I);
    bbar(eqIdx) = -c(posInA(eqIdx));
    Abar(:,eqIdx) = A(:,posInA(eqIdx));
    Abar = Abar';
% else
%     error('Should set ORIGINAL = 0 or 1.');
% end
% [rowSizeAbarT,colSizeAbarT] = size(AbarT);

%
% 2008-06-07 Waki
% replace this part by a faster version.
%
% The part of "AbarSDPT = [AbarSDPT; -convMat{i}];" is faster than the
% version where we allocate AbarSDPT.
%
%
% if ORIGINAL == 1
%     [rowSizeAbarT,colSizeAbarT] = size(Abar');
%     % <--- Equality constraint matrix in dual format
%     Kbar.s = [];
%     sdpDim = colSizeAbarT;
% 
%     % Sparse SDP constraint matrix in dual format --->
%     for i=1:clique.NoC
%         sDimE = nnz(clique.Set(i,:));
%         Kbar.s = [Kbar.s,sDimE];
%         convMat{i} = sparse(sDimE*sDimE,sdpDim);
%     end
%     for i=1:clique.maxC
%         psdConstMat{i} = [];
%     end
% 
%     AbarSDPT = [];
%     for i=1:clique.NoC
%         idxSet = find(clique.Set(i,:));
%         sDimE = length(idxSet);
%         if isempty(psdConstMat{sDimE})
%             [psdMat] = genPsdConstMat(sDimE);
%             psdConstMat{sDimE} = psdMat;
%         else
%             psdMat = psdConstMat{sDimE};
%         end
%         tempVector = reshape(clique.idxMatrix(idxSet,idxSet)',1,sDimE*sDimE);
%         tempIdx = find(tempVector);
%         idxInAbarSDPT = tempVector(tempIdx);
%         convMat{i}(:,idxInAbarSDPT) = psdMat;
%         AbarSDPT = [AbarSDPT; -convMat{i}];
%     end
%     % <--- Sparse SDP constraint matrix in dual format
%     % AbarT = [AbarT; AbarSDPT];
%     Abar = [Abar, AbarSDPT'];
% elseif ORIGINAL == 0
    [rowSizeAbarT,sdpDim] = size(Abar'); 
    % <--- Equality constraint matrix in dual format 

    % Sparse SDP constraint matrix in dual format --->
    psdConstMat = cell(1,clique.maxC);
    for i=1:clique.maxC
        psdConstMat{i} = [];
    end
    convMat = cell(1,clique.NoC);
    Kbar.s = clique.NoElem;
    idx = 0;
    for i=1:clique.NoC
        sDimE = clique.NoElem(i);
        tmpIdx = clique.Elem(idx+(1:sDimE));
        idx = idx + sDimE;
        tempVector = clique.idxMatrix(tmpIdx,tmpIdx)';
        tempVector = tempVector(:);
        tempVector = tempVector';
        idxInAbarSDPT = tempVector(tempVector ~= 0);
        if isempty(psdConstMat{sDimE})
            [RowIdx, ColIdx] = genPsdConstMat(sDimE);
            convMat{i} = sparse(idxInAbarSDPT(ColIdx),RowIdx,1,sdpDim,sDimE*sDimE,sDimE*sDimE);
        else
            psdMat = psdConstMat{sDimE};
            convMat{i}(idxInAbarSDPT,:) = psdMat';
        end
    end
    AbarSDPT = [convMat{1:clique.NoC}];
    % <--- Sparse SDP constraint matrix in dual format
    % AbarT = [AbarT; AbarSDPT];
    % Abar = [Abar, -AbarSDPT];
    Abar = [Abar, AbarSDPT];
% else
%     error('Should set ORIGINAL = 0 or 1.');
% end
% 
% if MEMORY == 1
%     d = whos('*');
%     for i=1:length(d)
%         mem = mem - d(i).bytes;
%     end
%     fprintf('$$ The total Memory in primalToSparseDual = %4d KB\n',-mem/1024);
% end

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 2008-06-08 Waki 
% Revise genPsdConstMat. Change outputed variable.
%
%
function [RowIdx, ColIdx] = genPsdConstMat(sDimE)

[I,J] = find(ones(sDimE));
RowIdx = (J-1)*sDimE + I;
tmpMat = zeros(sDimE);
idx = 0;
for i=1:sDimE
    tmpMat(i,i:sDimE) = idx + (i:sDimE);
    idx = idx + sDimE -i;
end
ColIdx = triu(tmpMat)+triu(tmpMat,1)';
ColIdx = ColIdx(:);
clear tmpMat
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

