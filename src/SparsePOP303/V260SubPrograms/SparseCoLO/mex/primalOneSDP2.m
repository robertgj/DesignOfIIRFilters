function [Apc,cPc,Kpc] = primalOneSDP2(clique,sDim,idEqPattern,A,c,K);

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

Kpc.s = clique.NoElem;

if issparse(c) == 0
    c = sparse(c);
end
if issparse(A) == 0
    A = sparse(A);
end

% Note that A and c and idEqPattern should be column orientation
if (size(c,1) == 1) 
    %fprintf('c is transposed');
    [ApcTrans,cPcTrans] = ...
        mexPrimalOneSDP2(clique,sDim,idEqPattern',A',c',K);
else
    [ApcTrans,cPcTrans] = ...
        mexPrimalOneSDP2(clique,sDim,idEqPattern',A',c,K);
end

Apc = ApcTrans';
cPc = cPcTrans';

