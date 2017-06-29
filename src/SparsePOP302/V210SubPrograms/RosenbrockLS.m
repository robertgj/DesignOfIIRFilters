function [objPolyLS,ineqPolySys,lbd,ubd] = RosenbrockLS(nDim,s);
%
% Nonlinear least square formulation of minimization of Rosenbrock function
%
%   minimize 1 + sum_{i=2}^b (10(x_i-x_{i-1}^2))^2 + sum_{i=2}^n (1-x_i)^2
%
% Rosenbrock function, which is
% described in "Newton-Type Minimization via the Lanczos method",
% SIAM J.Numer.Anal., 21, p.770-788.
%
%   1 + \sum_{i=2}^nDim ( 100(x_i-x_{i-1}^2)^2 + (1-x_i)^2 ). 
%
% <Input> 
% nDim: the dimension of the function.
% s 
%   = -1 for the constraint x_1 <= 0,
%   = 0  for no constraint,
%   = 1  for the constraint x_1 >= 0.
%
% <Output>
% objPoly,ineqPolySys,lbd,ubd

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

objIdx = 0;
% 1
objIdx = objIdx+1; 
objPolyLS{objIdx}.typeCone = 1;
objPolyLS{objIdx}.sizeCone = 1;
objPolyLS{objIdx}.dimVar   = nDim;
objPolyLS{objIdx}.degree   = 0;
objPolyLS{objIdx}.noTerms  = 1;
objPolyLS{objIdx}.supports = sparse(objPolyLS{objIdx}.noTerms,objPolyLS{objIdx}.dimVar);
objPolyLS{objIdx}.coef     = [1]; 
% 10(x_i-x_{i-1}^2) = 10x_i-1 - 10x_{i-1}^2 (i=2,3,...,nDim)
for i=2:nDim
    objIdx = objIdx+1;
    objPolyLS{objIdx}.typeCone = 1;
    objPolyLS{objIdx}.sizeCone = 1;
    objPolyLS{objIdx}.dimVar   = nDim;
    objPolyLS{objIdx}.degree   = 2;
    objPolyLS{objIdx}.noTerms  = 2;
    objPolyLS{objIdx}.supports = sparse(objPolyLS{objIdx}.noTerms,objPolyLS{objIdx}.dimVar);
    objPolyLS{objIdx}.supports(1,i) = 1;
    objPolyLS{objIdx}.supports(2,i-1) = 2;    
    objPolyLS{objIdx}.coef     = [10; -10];
end
%   1-x_i. 
for i=2:nDim
    objIdx = objIdx+1;
    objPolyLS{objIdx}.typeCone = 1;
    objPolyLS{objIdx}.sizeCone = 1;
    objPolyLS{objIdx}.dimVar   = nDim;
    objPolyLS{objIdx}.degree   = 2;
    objPolyLS{objIdx}.noTerms  = 2;
    objPolyLS{objIdx}.supports = sparse(objPolyLS{objIdx}.noTerms,objPolyLS{objIdx}.dimVar);
    objPolyLS{objIdx}.supports(2,i) = 1;    
    objPolyLS{objIdx}.coef     = [1; -1];
end

ineqPolySys = [];

lbd = -1.0e+10*ones(1,nDim);
ubd = 1.0e+10*ones(1,nDim);
if nargin == 2
    if s > 0
        lbd(1,1) = 0;
    elseif s < 0 
        ubd(1,1) = 0;
    end
end
return;

% $Header: /home/waki9/CVS_DB/SparsePOPdev/example/POPformat/Rosenbrock.m,v 1.1.1.1 2007/01/11 11:31:50 waki9 Exp $
