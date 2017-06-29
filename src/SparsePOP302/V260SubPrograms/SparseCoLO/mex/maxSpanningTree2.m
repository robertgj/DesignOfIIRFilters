%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [treeValue,adjacencyMatrixT,edgeCostVectT,incidenceMatrixT,basisIdx,BInv] ... 
    = maxSpanningTree2(clique,adjacencyMatrixC,edgeCostVectC,incidenceMatrixC,randSeed)

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

[treeValue,basisIdx] = mexMaxSpanningTree2(edgeCostVectC,incidenceMatrixC);

% Note that transposed adjacencyMatrix is passed
% due to column-oriented matlab sparse format.
%  [treeValue,basisIdx] = mnkruscal(adjacencyMatrixC');

% basisIdx = sort(basisIdx);

edgeCostVectT = edgeCostVectC(1,basisIdx'); 
incidenceMatrixT = incidenceMatrixC(:,basisIdx'); 

adjacencyMatrixT=sparse(clique.NoC,clique.NoC); 
for p=1:clique.NoC-1
    idx = find(incidenceMatrixT(:,p)'); 
    adjacencyMatrixT(idx(1),idx(2)) = edgeCostVectT(p);
end

BInv = 0;

% full(adjacencyMatrixC')
% full(edgeCostVectC)
% full(incidenceMatrixC)

% basisIdx
% 
% full(adjacencyMatrixT)
% full(edgeCostVectT)
% full(incidenceMatrixT)
 

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

