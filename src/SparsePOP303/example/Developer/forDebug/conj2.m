function [objPoly,ineqPolySys,lbd,ubd] = conj2(nDim);

%
% Square equality constraints ---> a unique feasible solution 
%
% <Input> 
% nDim: The dimension of the function
%
% <Output>
% objPoly,ineqPolySys,lbd,ubd

%Objective Function%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rand('state',3201);
objPoly.typeCone = 1;
objPoly.sizeCone = 1;
objPoly.dimVar   = 2*nDim;
objPoly.degree   = 2*nDim;
objPoly.noTerms  = 1;
objPoly.supports = ones(1, 2*nDim);
objPoly.coef     = 1;

for i=1:2*nDim
ineqPolySys{i}.typeCone = -1;
ineqPolySys{i}.sizeCone = 1;
ineqPolySys{i}.dimVar   = 2*nDim;
ineqPolySys{i}.degree   = 2;
ineqPolySys{i}.noTerms  = 2;
ineqPolySys{i}.supports = sparse([1;2], [i;i], [1;2], 2, 2*nDim); 
ineqPolySys{i}.coef     = [1;-1];
end

lbd = -1.0e+10*ones(1,2*nDim);
ubd  =  1.0e+10*ones(1,2*nDim);
return;

