%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Some information of the PDSDP and LSDP relaxation problem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SDPinfo = getSDPinfo(A,K, reduceAMatSW, infeasibleSW, SDPinfo)

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is a component of SparsePOP 
% Copyright (C) 2007 SparsePOP Project
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
if nargin == 4
	SDPinfo = [];
end
[SDPinfo.rowSizeA, SDPinfo.colSizeA] = size(A);
SDPinfo.nonzerosInA = nnz(A);
SDPinfo.noOfFreevar = 0;
if isfield(K,'f')
    SDPinfo.noOfFreevar = K.f;
end
SDPinfo.noOfLPvariables = 0;
if isfield(K,'l')
	SDPinfo.noOfLPvariables = K.l;
end
SDPinfo.SOCPblock = [];
if isfield(K,'q')
	SDPinfo.SOCPblock = K.q;
end
SDPinfo.SDPblock = [];
if isfield(K,'s')
	SDPinfo.SDPblock = K.s;
end
if nargin == 2
	SDPinfo.reduceAMatSW = 0;
	SDPinfo.infeasibleSW = 0;
else
	SDPinfo.reduceAMatSW = reduceAMatSW;
	SDPinfo.infeasibleSW = infeasibleSW;
end
return

