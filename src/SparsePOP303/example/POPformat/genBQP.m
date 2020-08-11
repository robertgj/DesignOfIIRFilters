function [objPoly, ineqPolySys, lbd, ubd] = genBQP(nDim, sparseSW)
%
% This function generates quardatic optimization problem.
% Specially, the objective function is quadratic and 
% the constraints are only x_i^2 = x_i.
%
% sparseSW = 1 --> coefficient matrix for quadratic temrs is sparse 
% sparseSW = 0 --> coefficient matrix for quadratic temrs is dense 
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
		defaultStream = RandStream.getDefaultStream;
		s = RandStream('mt19937ar','Seed', 3201);
		W = 200*rand(s, nDim) - 100;
		q = 200*rand(s, nDim, 1) - 100;
	else
		rand('twister',3201);
		W = 200*rand(nDim) - 100;
		q = 200*rand(nDim, 1) - 100;
	end
elseif sparseSW == 1
	rand('twister', 3201);
	W = 200*sprand(nDim, nDim, 0.2) - 100;
	q = 200*sprand(nDim, 1, 0.2) - 100;
else
	error('sparseSW should be 0 or 1.');
end
%full(W)
%full(q)
U = triu(W) + tril(W, -1)';

% objPoly 
objPoly.typeCone = 1;
objPoly.dimVar   = nDim;    
objPoly.degree   = 2;    
objPoly.sizeCone = 1;	

kDim2 = nnz(U);
[row, col, val] = find(U);
sup2  = sparse(kDim2, nDim);
coef2 = zeros(kDim2, 1);
for i=1:kDim2
	if row(i) == col(i) 
		sup2(i, row(i)) = 2;
	else
		sup2(i, row(i)) = 1;
		sup2(i, col(i)) = 1;
	end
	coef2(i, 1) = val(i); 
end
%full(sup2)
kDim1 = nnz(q);
[row, col, val] = find(q);
sup1  = sparse(kDim1, nDim);
coef1 = zeros(kDim1, 1);
for i=1:kDim1
	sup1(i, row(i)) = 1;
	coef1(i, 1) = val(i); 
end
%full(sup1)
objPoly.noTerms  = kDim1 + kDim2;
objPoly.supports = [sup2;sup1];
objPoly.coef = [coef2;coef1]; 


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
	ineqPolySys{i}.supports(2, i) = 1;
	ineqPolySys{i}.coef = [1;-1];
end

lbd = repmat(-1.0e+10, 1, nDim);
ubd = repmat( 1.0e+10, 1, nDim);


return
