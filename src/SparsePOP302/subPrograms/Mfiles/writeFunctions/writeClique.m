function writeClique(fileId,clique)
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
fprintf(fileId,'# Maximal clique structure induced from csp graph\n');
% 2005 03 26
% H.Waki
% field 'NoC', 'maxC' and 'minC' of the structure 'clique' are sparse
% inputs. So, fprint can not output these. 
%
% I converted these into full input 
%
fprintf(fileId,'#Cliques = %d, maxC = %d, minC = %d\n',full(clique.NoC),full(clique.maxC),full(clique.minC));
[rowSize,colSize] = size(clique.Set);
%if issparse(clique.Set)
%	clique.Set = full(clique.Set);
%end
for i=1:rowSize
	fprintf(fileId,'clique %d : ',i);
	idx = find(clique.Set(i, :));
	for j=1:length(idx)
		fprintf(fileId, '%d ', idx(j)); 
	end
	%for j=1:colSize
	%	fprintf(fileId,'%d',clique.Set(i,j));
	%end
	fprintf(fileId,'\n'); 
end
fprintf(fileId,'\n'); 
return

