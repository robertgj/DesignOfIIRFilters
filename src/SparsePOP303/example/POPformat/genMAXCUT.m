function [objPoly, ineqPolySys, lbd, ubd] = genMAXCUT(nDim, sparseSW)
%
% This function generates MAX CUT problem. Because SparsePOP cannot deal 
% with maximization for POP format, we multiply -1 into the objective function.  
%
% sparseSW = 1 --> generate sparse graph, i.e., a graph with few edges
% sparseSW = 0 --> generate dense graph (maybe, complete graph) 
%
% 2011-06-22 H.Waki
%

if nargin == 1 
	sparseSW = 0;
end

% W is weighted ajacency matrix
if sparseSW == 0
	mv= ver('matlab');
	mv = str2num(mv.Version);
	if mv > 7.7
		s = RandStream('mt19937ar','Seed', 3201);
		W = 200*rand(s, nDim) - 100;
	else
		rand('twister',3201);
		W = 200*rand(nDim) - 100;
	end
elseif sparseSW == 1
	rand('twister', 3201);
	W = 200*sprand(nDim, nDim, 0.2) - 100;
else
	error('sparseSW should be 0 or 1.');
end
W = round(W);
W = (W+W')/2;
for i=1:nDim
	W(i, i) = 0.0;
end
d = diag(W*ones(nDim, 1));
% L is Laplacian
L =  d - W;
% For maximization
L = -L;
U = triu(L) + tril(L, -1)';

% objPoly 
objPoly.typeCone = 1;
objPoly.dimVar   = nDim;    
objPoly.degree   = 2;    
objPoly.sizeCone = 1;	

kDim = nnz(U);
objPoly.noTerms  = kDim;

objPoly.support = sparse(kDim, nDim);
objPoly.coef = zeros(kDim, 1);
[row, col, val] = find(U);
for i=1:kDim
	objPoly.supports(i, row(i)) = 1;
	objPoly.supports(i, col(i)) = 1;
	objPoly.coef(i, 1) = val(i); 
end

% ineqPolySys
ineqPolySys = cell(1,nDim);
for i=1:nDim
	ineqPolySys{i}.typeCone = -1;
	ineqPolySys{i}.sizeCone = 1;
	ineqPolySys{i}.dimVar   = nDim;    
	ineqPolySys{i}.degree   = 2;    
	ineqPolySys{i}.noTerms  = 2;
	ineqPolySys{i}.supports = sparse(2, nDim);
	ineqPolySys{i}.supports(1, i) = 2;
	ineqPolySys{i}.coef = [1;-1];
	%full([ineqPolySys{i}.supports, ineqPolySys{i}.coef])
end

lbd = repmat(-1.0e+10, 1, nDim);
ubd = repmat( 1.0e+10, 1, nDim);

return
