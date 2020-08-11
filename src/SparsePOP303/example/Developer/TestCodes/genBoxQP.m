function [objPoly, inEqPolySys, lbd, ubd] = genBoxQP(nDim, density, seed)

if nargin == 1 
	seed = 3201;
	density = 1;
elseif nargin == 2 
	seed = 3201;
end
rand('state',seed);
rmat = sprand(nDim, nDim, density);
[row, col, val] = find(rmat);
val = 50*(2*val-1);
coefQ = sparse(row, col, val, nDim, nDim);
coefQ = (coefQ+coefQ')/2;
rvec  = sprand(nDim, 1, density);
[row, col, val] = find(rvec);
val = 50*(2*val-1);
coefc = sparse(row, col, val, nDim, 1);

nnzCoef = nnz(triu(coefQ)) + nnz(coefc);

objPoly.typeCone = 1;
objPoly.sizeCone = 1;	
objPoly.dimVar   = nDim;    
objPoly.degree   = 2;    
objPoly.noTerms  = nnzCoef; 
objPoly.supports = sparse(objPoly.noTerms, objPoly.dimVar);
objPoly.coef     = sparse(objPoly.noTerms, 1);


mat = triu(coefQ);
[row, col] = find(mat);
p=length(row);
for k=1:p
	if row(k) == col(k)
		objPoly.supports(k, col(k)) = 2;
		objPoly.coef(k) = coefQ(col(k), col(k)); 	
	else
		objPoly.supports(k, row(k)) = 1;
		objPoly.supports(k, col(k)) = 1;
		objPoly.coef(k) = 2*coefQ(row(k), col(k)); 	
	end
end
[row, col] = find(coefc);
for k=1:length(row)
	objPoly.supports(k+p, row(k)) = 1;
	objPoly.coef(k+p) = coefc(k);
end
%full(coefQ)
%full([objPoly.supports, objPoly.coef])

inEqPolySys = [];

lbd = zeros(1, nDim);
ubd =  ones(1, nDim);
return
