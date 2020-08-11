function [objPoly,ineqPolySys,lbd,ubd] = BroydenTriLS(nDim);
% 
% Nonlinear least square version of minimization of the Broyden Tridiagonal
% function: 
%   minimize   \sum_{i=1}^n objPoly{i}^2
%   subject to inequPolySys = []; x_1 >= 0
% Here
%   objPoly{1} = (3Å|2x_1)x_1Å|2x_2+1
%   objPoly{i} = (3Å|2x_i)x_iÅ|x_{iÅ|1}Å| 2x_{i+1}+1 (i=2,...,n-1)
%   objPoly{n} = (3Å|2x_n)x_nÅ|x_{nÅ|1}+1
% 
% 
% [] = solveBroydenTri(nDim);
% 
% The Broyden Tridiagonal function, which is
% described in "Testing Unconstrained Optimization Software",
% J.J.More et.al, ACM Trans. Math. Soft., 7, p.17-41
%
% <Input> 
% nDim: The dimension of the function
%
% <Output>
% objPoly,ineqPolySys,lbd,ubd

%Objective Function%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
objPoly{1}.typeCone = 1;
objPoly{1}.sizeCone = 1;
objPoly{1}.dimVar   = nDim;
objPoly{1}.degree   = 2;
objPoly{1}.noTerms  = 4;
objPoly{1}.supports = sparse(objPoly{1}.noTerms,objPoly{1}.dimVar);
objPoly{1}.supports(1,1) = 1;
objPoly{1}.supports(2,1) = 2;
objPoly{1}.supports(3,2) = 1;
objPoly{1}.coef     = [3;-2;-2;1];

for i=2:nDim-1
  objPoly{i}.typeCone = 1;
  objPoly{i}.sizeCone = 1;
  objPoly{i}.dimVar   = nDim;
  objPoly{i}.degree   = 2;
  objPoly{i}.noTerms  = 5;
  objPoly{i}.supports = sparse(objPoly{i}.noTerms,objPoly{i}.dimVar);
  objPoly{i}.supports(1,i) = 1;
  objPoly{i}.supports(2,i) = 2;
  objPoly{i}.supports(3,i-1) = 1;
  objPoly{i}.supports(4,i+1) = 1;
  objPoly{i}.coef     = [3;-2;-1;-2;1];
end

objPoly{nDim}.typeCone = 1;
objPoly{nDim}.sizeCone = 1;
objPoly{nDim}.dimVar   = nDim;
objPoly{nDim}.degree   = 2;
objPoly{nDim}.noTerms  = 4;
objPoly{nDim}.supports = sparse(objPoly{nDim}.noTerms,objPoly{nDim}.dimVar);
objPoly{nDim}.supports(1,nDim) = 1;
objPoly{nDim}.supports(2,nDim) = 2;
objPoly{nDim}.supports(3,nDim-1) = 1;
objPoly{nDim}.coef     = [3;-2;-1;1];

ineqPolySys = [];
lbd = -1.0e+10*ones(1,nDim);
lbd(1,1) = 0;
ubd  =  1.0e+10*ones(1,nDim);
return;

% $Header: /home/waki9/CVS_DB/SparsePOPdev/example/POPformat/BroydenTri.m,v 1.1.1.1 2007/01/11 11:31:50 waki9 Exp $
