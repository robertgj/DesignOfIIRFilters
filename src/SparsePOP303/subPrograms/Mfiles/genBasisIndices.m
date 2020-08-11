function [basisIndices, basisCliqueNo, ineqPolySysNew] = genBasisIndices(objPoly,...
    		ineqPolySys,cliqueSet,param)

%
% function genBasisIndices
% This function outputs index sets of variables that consists of each
% localizing and moment matrices induced from a maximal clique sets.
%
% Input:
% objPoly --- objective function. Here, we use only this in order to
% dimension of POP.
% ineqPolySys --- constraints of POP.
% cliqueSet --- a maximal clique set found by csp matrix.
% param --- Here, use only param.multiCliquesFactor. This decides the rate
% of mixing some cliques.
%
% Output:
% basisIndices --- Index sets of variables of consisisting of localizing and
% moment matrices.
% basisCliqueNo ---  
%   basisCliqueNo(1,p) = q if basisIndices{p} associated with an inequality
%       constraint or a moment matrix uses qth clique.
%   basisCliqueNo(1,p) = -q if basisIndices{p} associated with an equality
%       constraint uses qth clique.
%

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

%$%$ Modified by Kojima 2007/08/05 --->
%   Added   param.reduceEqualitiesSW as an input;
%               if param.reduceEqualitiesSW >= 1 then the modified parts necessary for
%               exploiting equalities are carried out. 
%           basisCliqueNo as an output;
%   basisCliqueNo(1,p) = q if basisIndices{p} associated with an inequality
%       constraint or a moment matrix uses qth clique.
%   basisCliqueNo(1,p) = -q if basisIndices{p} associated with an equality
%       constraint uses qth clique.
%$%$ <--- Kojima 2007/08/05
%
useAllCliquesSW = 1;
if param.reduceEqualitiesSW == 1 || param.reduceEqualitiesSW == 2
	fprintf('## useAllCliquesSW = %d at genBasisIndices\n',useAllCliquesSW); 
end
%$%$ Kojima 2007/08/05 ---> 
% For each inequality and equality, all the cliques that covers its 
% variables are used to create a polynomial SDP

% the number of variables in POP
nDim = objPoly.dimVar;
rowSize = size(ineqPolySys,2);
%the number of maximal cliques of the csp graph induced from POP.
nClique = size(cliqueSet,1);

% the dense case
if param.sparseSW == 0 
	if param.reduceEqualitiesSW ~= 0  && useAllCliquesSW == 1
		[basisIndices, basisCliqueNo, ineqPolySysNew] = genIndicesForDenseWithEqualities(ineqPolySys, cliqueSet, nDim, rowSize, nClique, param); 
	else
		[basisIndices, basisCliqueNo, ineqPolySysNew] = genIndicesForDense(ineqPolySys, cliqueSet, nDim, rowSize, nClique, param);
	end
elseif param.sparseSW == 1% the sparse case
	%$%$ Kojima 2007/08/05 ---> 
	% For each inequality and equality, all the cliques that covers its 
	% variables are used to create a polynomial SDP
	% 
	if param.reduceEqualitiesSW ~= 0  && useAllCliquesSW == 1
		[basisIndices, basisCliqueNo, ineqPolySysNew] = genIndicesForSparseWithEqualities(ineqPolySys, cliqueSet, rowSize, nClique, param);
	else
		[basisIndices, basisCliqueNo, ineqPolySysNew] = genIndicesForSparse(ineqPolySys, cliqueSet, rowSize, nClique, param); 
	end
elseif param.sparseSW == 2
	%{
	fprintf('## New SDP relaxation based on Dense relaxation. (2011-08-03)\n');
	fprintf('## The following Mfiles are revised for this purpose:\n');
	fprintf('## sparsePOP.m\n');
	fprintf('## defaultParameter.m\n');
	fprintf('## checkPOP.m\n');
	fprintf('## genClique.m\n');
	fprintf('## genBasisIndices.m\n');
	fprintf('## genBasisSupports.m\n');
	fprintf('## param.sparseSW == 2 is new dense sdp relaxation\n');
	fprintf('## param.sparseSW == 3 is new sparse sdp relaxation\n');
	%}
	if param.reduceEqualitiesSW ~= 0  && useAllCliquesSW == 1
		[basisIndices, basisCliqueNo, ineqPolySysNew] = genIndicesForDenseWithEqualities(ineqPolySys, cliqueSet, nDim, rowSize, nClique, param); 
	else
		[basisIndices, basisCliqueNo, ineqPolySysNew] = genIndicesForDense(ineqPolySys, cliqueSet, nDim, rowSize, nClique, param);
	end
elseif param.sparseSW == 3
	%{
	fprintf('## New SDP relaxation based on Sparse relaxation. (2011-08-03)\n');
	fprintf('## The following Mfiles are revised for this purpose:\n');
	fprintf('## sparsePOP.m\n');
	fprintf('## defaultParameter.m\n');
	fprintf('## checkPOP.m\n');
	fprintf('## genClique.m\n');
	fprintf('## genBasisIndices.m\n');
	fprintf('## genBasisSupports.m\n');
	fprintf('## param.sparseSW == 2 is new dense sdp relaxation\n');
	fprintf('## param.sparseSW == 3 is new sparse sdp relaxation\n');
	%}
	%$%$ Kojima 2007/08/05 ---> 
	% For each inequality and equality, all the cliques that covers its 
	% variables are used to create a polynomial SDP
	% 
	if param.reduceEqualitiesSW ~= 0  && useAllCliquesSW == 1
		[basisIndices, basisCliqueNo, ineqPolySysNew] = genIndicesForSparseWithEqualities(ineqPolySys, cliqueSet, rowSize, nClique, param);
	else
		[basisIndices, basisCliqueNo, ineqPolySysNew] = genIndicesForSparse(ineqPolySys, cliqueSet, rowSize, nClique, param); 
	end
end
return

function [basisIndices, basisCliqueNo, ineqPolySysNew] = genIndicesForDense(ineqPolySys, cliqueSet, nDim, rowSize, nClique, param)
basisCliqueNo = sparse(1,rowSize+1); 
for i=1:rowSize
	basisIndices{i} = 1:nDim;
end
basisIndices{rowSize+1} = 1:nDim;
ineqPolySysNew = ineqPolySys; 
return
function [basisIndices, basisCliqueNo, ineqPolySysNew] = genIndicesForDenseWithEqualities(ineqPolySys, cliqueSet, nDim, rowSize, nClique, param)
%basisCliqueNo = sparse(1,rowSize+1); 
for i=1:rowSize
	basisIndices{i} = 1:nDim;
	if ineqPolySys{i}.typeCone == -1;
		basisCliqueNo(1,i) = -nDim; 
	else
		basisCliqueNo(1,i) = nDim; 
	end    
end
basisIndices{rowSize+1} = 1:nDim;
basisCliqueNo(1,rowSize+1) = nDim; 
ineqPolySysNew = ineqPolySys; 
return 

function [basisIndices, basisCliqueNo, ineqPolySysNew] = genIndicesForSparseWithEqualities(ineqPolySys, cliqueSet, rowSize, nClique, param)

maxSizeClique = max(sum(cliqueSet,2));
pointer = 0;
for i=1:rowSize
	% the n-dimensional row vector whose positive elements indicate
	% nonzeros.
	nzIndicator = any(ineqPolySys{i}.supports,1);
	IntersectClique = cliqueSet*nzIndicator';
	candidates = find(IntersectClique == nnz(nzIndicator));
	% the cliques each of which covers nzIndicator =
	% the candidate of cliques whose union replaces nzIndicator.
	noCandidates = length(candidates);
	for j=1:noCandidates
		pointer = pointer + 1;
		ineqPolySysNew{pointer} = ineqPolySys{i};
		if ineqPolySys{i}.typeCone == -1;
			basisCliqueNo(1,pointer) = -candidates(j); 
		else
			basisCliqueNo(1,pointer) = candidates(j); 
		end    
		nzIndicator = cliqueSet(candidates(j),:);
		basisIndices{pointer} = find(nzIndicator);
		% pointer, basisIndices{pointer}
	end
end
for i=(1:nClique)
	basisIndices{i+pointer} = find(cliqueSet(i,:));
	basisCliqueNo(1,i+pointer)= i; 
end
%$%$ <--- Kojima 2007/08/05
return

function [basisIndices, basisCliqueNo, ineqPolySysNew] = genIndicesForSparse(ineqPolySys, cliqueSet, rowSize, nClique, param) 

ineqPolySysNew = ineqPolySys;
% the maximum size of the maximaz cliques.
basisIndices = cell(1,rowSize+nClique);
maxSizeClique = max(sum(cliqueSet,2));
%$%$ Kojima 2007/08/05 --->
basisCliqueNo = sparse(1,rowSize+nClique); 
%$%$ <--- Kojima 2007/08/05
for i=1:rowSize
	% the n-dimensional row vector whose positive elements indicate
	% nonzeros.
	nzIndicator = any(ineqPolySys{i}.supports,1);
	IntersectClique = cliqueSet*nzIndicator';
	candidates = find(IntersectClique == nnz(nzIndicator));
	% the cliques each of which covers nzIndicator =
	% the candidate of cliques whose union replaces nzIndicator.
	noCandidates = length(candidates);

	nzIndicator = cliqueSet(candidates(1),:);
	%$%$ Kojima 2007/08/05 --->
	if param.reduceEqualitiesSW ~= 0 
		maxSize = 0; 
		noOfNz = 1; 
		if ineqPolySys{i}.typeCone == -1;
			basisCliqueNo(1,i) = -candidates(1); 
		else
			basisCliqueNo(1,i) = candidates(1); 
		end
	end
	noOfNz = nnz(nzIndicator);
	maxSize = maxSizeClique * param.multiCliquesFactor;                
	%$%$ <--- Kojima 2007/08/05
	j = 2;
	% expanding nzIndicator until its size does not exceed maxSize.
	while (j <= noCandidates) && (noOfNz < maxSize)
		newNzIndicator = nzIndicator + cliqueSet(candidates(j),:);
		newNoOfNz = nnz(newNzIndicator);
		if newNoOfNz <= maxSize
			nzIndicator = newNzIndicator;
			noOfNz = newNoOfNz;
		end
		j = j+1;
	end
	basisIndices{i} = find(nzIndicator);
end
for i=(1:nClique)+rowSize
	basisIndices{i} = find(cliqueSet(i-rowSize,:));
	%$%$ Kojima 2007/08/05 --->
	if param.reduceEqualitiesSW ~= 0 
		basisCliqueNo(1,i)= i-rowSize; 
	end            
	%$%$ <--- Kojima 2007/08/05
end
return
