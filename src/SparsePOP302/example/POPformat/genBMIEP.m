function [objPoly, ineqPolySys, lbd, ubd] = genBMIEP(n, m, k, sparseSW)

if nargin < 4
	sparseSW = 0;
end

mDim = (n+1)*(m+1) + 1;
%s= RandStream('mt19937ar', 'Seed', 3201);
%	B = 2*rand(s, k*k, mDim)-1;
rand('twister',3201);
B = 2*rand(k*k, mDim)-1;
%B = rand(s, k*k, mDim);
tmpmat = speye(k);
B(:, mDim) = tmpmat(:);
for i=1:mDim-1
	tmpmat = B(:, i);
	tmpmat = reshape(tmpmat, k, k);
	tmpmat = (tmpmat + tmpmat')/2;
	B(:, i) = -tmpmat(:); 
end

nDim = n+m+1;

% objPoly 
objPoly.typeCone = 1;
objPoly.dimVar   = nDim;    
objPoly.degree   = 1;    
objPoly.sizeCone = 1;	
objPoly.noTerms  = 1;
objPoly.coef = 1;
objPoly.supports = sparse(1, nDim);
objPoly.supports(1, end) = 1;

sup = sparse(mDim, nDim);
sup(1, end) = 1;
sup(2:n+m+1, 1:n+m) = speye(n+m);
p = n+m+1;
for i=1:n
	for j=n+1:n+m
		p = p+1;
		sup(p, i) = 1;
		sup(p, j) = 1;	
	end
end

% ineqPolySys
ineqPolySys = cell(1,1);
ineqPolySys{1}.typeCone = 3;
ineqPolySys{1}.sizeCone = k;
ineqPolySys{1}.dimVar   = nDim;    
ineqPolySys{1}.degree   = 2;    
ineqPolySys{1}.noTerms  = mDim;
ineqPolySys{1}.supports = sup;
ineqPolySys{1}.coef = B';
 
ineqPolySys{1} = simplifyPolynomial(ineqPolySys{1});

lbd = sparse(1, nDim);
lbd(nDim)= -1.0e+10;
ubd = ones(1, nDim);
ubd(nDim)=  1.0e+10;


return
