function [lb, ub]=xConstraints(U,V,M,Q,rhoP,rhoZ)
  % [lb,ub]=xConstraints(U,V,M,Q[,rhoP,rhoZ])

% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Permission is hereby granted, free of charge, to any person
% obtaining a copy of this software and associated documentation
% files (the "Software"), to deal in the Software without restriction,
% including without limitation the rights to use, copy, modify, merge,
% publish, distribute, sublicense, and/or sell copies of the Software,
% and to permit persons to whom the Software is furnished to do so,
% subject to the following conditions: The above copyright notice and
% this permission notice shall be included in all copies or substantial
% portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

if (nargin<4) || (nargin>6) || (nargout~=2)
  print_usage("[lb,ub]=xConstraints(U,V,M,Q[,rhoP,rhoZ])");
endif
Mon2=M/2;
Qon2=Q/2;
bignum=10;
if nargin<5
  rhoP=31/32;
endif
if nargin<6
  rhoZ=bignum;
endif


ub=[ bignum; ...                   % K           <    bignum
     rhoZ*ones(U,1); ...           % Real zero   <      rhoZ
     rhoP*ones(V,1); ...           % Real pole   <      rhoP
     rhoZ*ones(Mon2,1); ...        % Zero radius <      rhoZ
     bignum*ones(Mon2,1); ...      % Zero angle  <    bignum
     rhoP*ones(Qon2,1); ...        % Pole radius <      rhoP
     bignum*ones(Qon2,1); ];       % Pole angle  <    bignum

lb=-ub;

endfunction
