function [clique,sDim,idEqPattern,A,c,K] = samplePrimalOneInput;

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

clique.NoC = 3;
clique.Set{1} = [1 2 4 5 9 10];
clique.Set{2} = [2 5 8];
clique.Set{3} = [3 5 6 7 9];
clique.Elem = [];
clique.NoElem = [];
for p=1:clique.NoC
  clique.Elem = [clique.Elem clique.Set{p}];
  clique.NoElem = [clique.NoElem size(clique.Set{p},2)];
end
clique.maxC = max(clique.NoElem);
clique.minC = min(clique.NoElem);

K.s = 10;
sDim = K.s;
idEqPattern = sparse(2,3);
idEqPattern(1,1) = 3;
idEqPattern(1,2) = 3;
idEqPattern(2,1) = 3;
idEqPattern(2,3) = 3;

m = 7;
A = sparse(m, K.s * K.s);

A( 1,( 1-1)*10+ 1) =  2.0;
A( 1,( 4-1)*10+10) =  3.0;
A( 1,(10-1)*10+ 4) =  3.0;
A( 1,( 2-1)*10+ 5) =  4.0;
A( 1,( 2-1)*10+ 5) =  4.0;

A( 2,( 2-1)*10+ 2) =  5.0;
A( 2,( 2-1)*10+ 2) =  5.0;
A( 2,( 2-1)*10+ 5) =  6.0;
A( 2,( 5-1)*10+ 2) =  6.0;

A( 3,( 1-1)*10+ 2) =  7.0;
A( 3,( 2-1)*10+ 1) =  7.0;
A( 3,( 2-1)*10+ 2) =  8.0;
A( 3,( 5-1)*10+ 5) =  9.0;
A( 3,( 5-1)*10+ 8) = 10.0;
A( 3,( 8-1)*10+ 5) = 10.0;

A( 4,( 3-1)*10+ 5) = 11.0;
A( 4,( 5-1)*10+ 3) = 11.0;
A( 4,( 6-1)*10+ 7) = 12.0;
A( 4,( 7-1)*10+ 6) = 12.0;
A( 4,( 5-1)*10+ 5) = 13.0;

A( 5,( 1-1)*10+10) = 14.0;
A( 5,(10-1)*10+ 1) = 14.0;
A( 5,( 2-1)*10+ 9) = 15.0;
A( 5,( 9-1)*10+ 2) = 15.0;
A( 5,( 5-1)*10+ 8) = 16.0;
A( 5,( 8-1)*10+ 5) = 16.0;
A( 5,( 3-1)*10+ 6) = 17.0;
A( 5,( 6-1)*10+ 3) = 17.0;
A( 5,( 7-1)*10+ 7) = 18.0;
A( 5,( 5-1)*10+ 5) = 19.0;

A( 6,( 2-1)*10+ 4) = 20.0;
A( 6,( 4-1)*10+ 2) = 20.0;
A( 6,( 5-1)*10+ 9) = 21.0;
A( 6,( 9-1)*10+ 5) = 21.0;

A( 7,( 5-1)*10+ 5) = 22.0;


c = sparse(1, K.s * K.s);
c( 1,( 1-1)*10+ 5) = 23.0;
c( 1,( 5-1)*10+ 1) = 23.0;
c( 1,( 1-1)*10+ 9) = 24.0;
c( 1,( 9-1)*10+ 1) = 24.0;
c( 1,( 2-1)*10+ 2) = 25.0;
c( 1,( 2-1)*10+ 8) = 25.0;
c( 1,( 8-1)*10+ 2) = 26.0;
c( 1,( 3-1)*10+ 5) = 27.0;
c( 1,( 5-1)*10+ 3) = 27.0;
c( 1,( 4-1)*10+ 9) = 28.0;
c( 1,( 9-1)*10+ 4) = 28.0;
c( 1,( 5-1)*10+ 5) = 29.0;
c( 1,( 5-1)*10+ 7) = 30.0;
c( 1,( 7-1)*10+ 5) = 30.0;
c( 1,( 5-1)*10+ 9) = 31.0;
c( 1,( 9-1)*10+ 5) = 31.0;
c( 1,( 6-1)*10+ 6) = 32.0;
c( 1,( 6-1)*10+ 9) = 33.0;
c( 1,( 9-1)*10+ 6) = 33.0;
c( 1,( 7-1)*10+ 7) = 34.0;
c( 1,( 9-1)*10+ 9) = 35.0;
c( 1,( 9-1)*10+10) = 36.0;
c( 1,(10-1)*10+ 9) = 36.0;
c( 1,(10-1)*10+10) = 37.0;




