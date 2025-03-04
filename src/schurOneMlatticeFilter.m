function [yap y xx]=schurOneMlatticeFilter(k,epsilon,p,c,u,rounding)
% [yap y xx]=schurOneMlatticeFilter(k,epsilon,p,c,u,rounding)
% k are the lattice filter multiplier coefficients
% epsilon are sign coefficients for each module
% p scales the gain from input to each node to unity
% c are the numerator polynomial tap weights in the orthogonal basis
% u is the input sequence
% rounding sets the rounding mode. "round" for rounding to nearest
% and "fix" for truncation to zero(2s complement)
%
% The lattice filter structure is:
%       _______          _______                _______       [ii]    
% Out <-|     |<---------|     |<---------...<--|     |<----------
%       |     |  ______  |     |  ______        |     |  ______  |
%  In ->|  N  |->|z^-1|->| N-1 |->|z^-1|->...-->|  1  |->|z^-1|->o
%       |     |  ------  |     |  ------        |     |  ------  |
%  AP <-|     |<---------|     |<---------...<--|     |<----------
% Out   -------          -------                -------        [i]
%
% Each module 1,..,N is implemented as:
%                      
%     <-----------+<---------------<
%                 ^         
%                c|
%                 |
%         ------->o-------------
%         |                    |
%         |     k    epsilon   V
%     >---o->+---->o---------->+--->
%             ^\  /  
%               \/       
%               /\
%              /  \-epsilon
%             v    \
%     <------+<-----o--------------<
%

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

% Sanity check
if nargin ~= 6
  print_usage("[yap y xx]=schurOneMlatticeFilter(k,epsilon,p,c,u,rounding)");
endif

% Rounding
rounding=rounding(1:3);
if rounding == "rou"
  % Rounding to nearest
  rtype=1;
elseif rounding == "fix"
  % Rounding to zero (2s complement)
  rtype=2;
else
  rtype=0;
endif

% Filter states
u=u(:);
c=c(:)';
epsilon=epsilon(:)';
k=k(:)';
p=p(:)';
N=length(u);
M=length(k);
x=zeros(1,M);
nextx=zeros(1,M);
y=zeros(N,1);
yap=zeros(N,1);
xx=zeros(N+1,M);
for n = 1:N
 
  % Scale the output of each state
  x=x.*p;

  % Calculate the lattice elements
  star=x(1);
  for m = 1:M-1
    tmp = k(m)*(x(m+1) - (epsilon(m)*star));
    nextx(m) = (tmp*epsilon(m))+x(m+1); 
    star = tmp+star;

    % Simulate scaling and truncation at each node
    star = star/p(m+1);
    if rtype == 1
      star = round(star);
    elseif rtype == 2
      star = fix(star);
    endif
    star = star*p(m+1);
  endfor

  % Outputs
  tmp = k(M)*(u(n) - (epsilon(M)*star));
  nextx(M) = (tmp*epsilon(M))+u(n); 
  yap(n) = tmp+star; 
  
  % Scale the state and truncate it 
  x=nextx./p;
  if rtype == 1
    x = round(x);
  elseif rtype == 2
    x = fix(x);
  endif

  % Store the state
  xx(n+1,:) = x;
    
endfor

% Output. Simulate scaling with a large accumulator
y=[xx(1:N,:), u]*((c.*[p,1])');

% Truncate the outputs
if rtype == 1
  y = round(y);
  yap = round(yap);
elseif rtype == 2
  y = fix(y);
  yap = fix(yap);
endif

endfunction
