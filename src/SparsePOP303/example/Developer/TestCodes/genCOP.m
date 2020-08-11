function [objPoly, inEqPolySys, lbd, ubd] = genCOP(nDim, seed)

if nargin == 1
	seed = 3201;
end
objPoly.typeCone = -1;
objPoly.sizeCone = 1;	
objPoly.dimVar   = nDim;    
objPoly.degree   = 2;    
objPoly.noTerms  = nDim*(nDim+1)/2; 
objPoly.supports = sparse(objPoly.noTerms, objPoly.dimVar);
objPoly.coef     = sparse(objPoly.noTerms, 1);
coefQ = setDiag(nDim, seed);
coefQ = (coefQ + coefQ')/2;

mat = triu(ones(nDim));
[row, col] = find(mat);
for k=1:length(row)
	if row(k) == col(k)
		objPoly.supports(k, col(k)) = 2;
		objPoly.coef(k) = coefQ(col(k), col(k)); 	
	else
		objPoly.supports(k, row(k)) = 1;
		objPoly.supports(k, col(k)) = 1;
		objPoly.coef(k) = 2*coefQ(row(k), col(k)); 	
	end
end
%full(coefQ)
%full([objPoly.supports, objPoly.coef])

inEqPolySys = cell(1,1);
inEqPolySys{1}.typeCone = -1;
inEqPolySys{1}.sizeCone = 1;	
inEqPolySys{1}.dimVar   = nDim; 
inEqPolySys{1}.degree   = 1;
inEqPolySys{1}.noTerms  = nDim + 1; 
inEqPolySys{1}.supports = sparse(inEqPolySys{1}.noTerms, inEqPolySys{1}.dimVar);
inEqPolySys{1}.coef     = sparse(inEqPolySys{1}.noTerms, 1);
inEqPolySys{1}.supports(1:nDim, :) = inEqPolySys{1}.degree*speye(nDim);
inEqPolySys{1}.coef(1:nDim,1) = -1;
inEqPolySys{1}.coef(nDim+1,1) = 1;
%full([inEqPolySys{1}.supports, inEqPolySys{1}.coef])

lbd = zeros(1, nDim);
ubd = +1.0e+10*ones(1, nDim);
return

function coefQ = setDiag(nDim, seed)
rand('state',seed);
while 1
	%coefQ = 2*rand(nDim) -1;%For uniform distribution
	coefQ = randn(nDim);%For Gaussian distribution
	coefQ = (coefQ+coefQ')/2;
	for i=1:nDim
		coefQ(i, i) = sqrt(nDim)/2;
	end
	[V, D] = eig(coefQ);
	lambda = diag(D);
	if min(lambda) < -1.0e-3
		break;
	else
		disp('lambda = ');
		disp(lambda');
	end
end
%disp(lambda');
return
