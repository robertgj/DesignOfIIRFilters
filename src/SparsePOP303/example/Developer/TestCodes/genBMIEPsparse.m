function [objPoly, ineqPolySys, lbd, ubd] = genBMIEPsparse(n, m, k, sparseSW, seed)

if nargin < 5
	seed = 3201;
end
if nargin < 4
	sparseSW = 0;
end

mDim = (n+1)*(m+1) + 1;
rng(seed,'twister');
%B = 2*rand(k*k, mDim)-1;%For uniform distribution
B = randn(k*k, mDim);%For Gaussian distribution
tmpmat = eye(k);
B(:, 1) = tmpmat(:);
for i=2:mDim
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
p = 1;
for i=1:n
	for j=n+1:n+m
		p = p+1;
		sup(p, i) = 1;
		sup(p, j) = 1;	
	end
end
sup(p+1:end-1, 1:n+m) = speye(n+m);

% ineqPolySys
ineqPolySys = cell(1,1);
ineqPolySys{1}.typeCone = 3;
ineqPolySys{1}.sizeCone = k;
ineqPolySys{1}.dimVar   = nDim;    
ineqPolySys{1}.degree   = 2;    
ineqPolySys{1}.noTerms  = mDim;
ineqPolySys{1}.supports = sup;
ineqPolySys{1}.coef = B';

%full(ineqPolySys{1}.supports)
%ineqPolySys{1}.coef 


ineqPolySys{1} = simplifyPolynomial(ineqPolySys{1});

lbd = sparse(1, nDim);
%lbd = -50*rand(1, nDim);
%lbd = -ones(1, nDim);
lbd(1, nDim)= -1.0e+12;
ubd = ones(1, nDim);
%ubd = 50*rand(1, nDim);
ubd(1, nDim)=  1.0e+12;

%full(lbd)
%full(ubd)

return
