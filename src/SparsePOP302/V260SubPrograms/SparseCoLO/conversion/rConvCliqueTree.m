%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [LOP,clique] = rConvCliqueTree(A,sPatternVect,b,c,K,J)
% function [LOP,clique,retrieveInfo] = rConvCliqueTree(A,sPatternVect,b,c,K,J)

% The d-space conversion method using basis representation
% 2009/01/10
% Masakazu Kojima
% 
% Input LOP problem 
%   minimize	c^T x
%   subject to	A x - b \in coneJ, x \in coneK

%
% input data
%   A : a matrix
%   b : a column vector
%   c : a column vector
%   K denotes a conic structre of the domain space consisting of 
%       K.f --- the dimension of free variables
%       K.l --- the dimension of LP variables
%       K.q --- the sizes of second-order cone variables
%       K.s --- the sizes of matrix variables
%   J denotes a conic structure of the constraint in the range space
%       J.f --- the dimension of equality constraints 
%       J.l --- the dimension of LP constraints
%       J.q --- the sizes of second-order cone constraints 
%       J.s --- the sizes of LMI constraints 
%       
%   sPetternVect
%       

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is a component of SparseCoLO 
% Copyright (C) 2009 
% Masakazu Kojima Group
% Department of Mathematical and Computing Sciences
% Tokyo Institute of Technology
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

if isfield(J,'s') && ~isempty(J.s)    
%    [LOP,clique,retrieveInfo] = dConvCliqueTree(-A',sPatternVect,-c,-b,J,K);    
    [LOP,clique] = dConvCliqueTree(-A',sPatternVect,-c,-b,J,K);    
    LOP.A = -LOP.A';
    c = -LOP.b;
    LOP.b = -LOP.c;
    LOP.c = c;
    J = LOP.K;
    LOP.K = LOP.J;
    LOP.J = J;    
else
    LOP.A = A;
    LOP.b = b;
    LOP.c = c;
    LOP.K = K;
    LOP.J = J;
    clique = [];
    convMat = [];
end    
    
return
