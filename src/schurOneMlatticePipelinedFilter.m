function [yap y xx]=schurOneMlatticePipelinedFilter(k,epsilon,px,c,u,rounding)
% [yap y xx]=schurOneMlatticePipelinedFilter(k,epsilon,px,c,u,rounding)
% k are the lattice filter multiplier coefficients
% epsilon are sign coefficients for each module
% px scales the gain from input to each state to unity
% c are the numerator polynomial tap weights in the orthogonal basis
% u is the input sequence
% rounding sets the rounding mode. "round" for rounding to nearest
% and "fix" for truncation to zero(2s complement)
%
% This function is really a reimplementation of svf.m specific to the
% pipelined Schur one-multiplier lattice.
%
% The lattice filter structure is, for N odd and Y=3*ceil(N/2)-2:
%                                           
%       _______                 _______   __x2__   _______  
% Out <-|     |<----------...<--|     |<--|z^-1|<--|     |<---------|
%       |     |                 |     |   ------   |     |          | c(1)=c0
%       |     |   __xY__        |     |            |     |  __x1__  |
%  In ->|  N  |-->|z^-1|->...-->|  2  |->--------->|  1  |->|z^-1|->o
%       |     |   ------        |     |            |     |  ------  |
%       |     |                 |     |   __x3__   |     |          |
%  AP <-|     |<----------...<--|     |<--|z^-1|<--|     |<---------|
% Out   -------                 -------   ------   -------
%
% The lattice filter structure is:
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
  
% Copyright (C) 2023 Robert G. Jenssen
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
  print_usage ...
    ("[yap y xx]=schurOneMlatticePipelinedFilter(k,epsilon,px,c,u,rounding)");
endif

Nu=length(u);
Nk=length(k);
if rem(Nk,2)
  Nx=(3*ceil(Nk/2))-2;
else
  Nx=3*Nk/2;
endif

if length(epsilon) ~= Nk
  error("length(epsilon) ~= Nk");
endif
if length(c) ~= (Nk+1)
  error("length(c) ~= (Nk+1)");
endif
if length(px) ~= Nx
  error("length(px) ~= Nx");
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
px=px(:)';
x=zeros(1,Nx);
nextx=zeros(1,Nx);
y=zeros(Nu,1);
yap=zeros(Nu,1);
xx=zeros(Nu+1,Nx);

% For convenience
pek=ones(size(k))+(epsilon.*k);
mek=ones(size(k))-(epsilon.*k);
  
for n = 1:Nu
 
  % Scale the output of each state
  x=x.*px;

  % Calculate the lattice elements
  y(n)=c(1)*x(1);
  yap(n)=x(1);
  for m = 1:(ceil(Nk/2)-1)
    nextx((3*m)-2)=-(k((2*m)-1)*yap(n)) ...
                   -(pek((2*m)-1)*k(2*m)*x(3*m)) ...
                   +(pek((2*m)-1)*pek(2*m)*x((3*m)+1));
    nextx((3*m)-1)=y(n) ...
                   -(c(2*m)*k(2*m)*x(3*m)) ...
                   +(c(2*m)*pek(2*m)*x((3*m)+1));
    nextx(3*m)=(mek((2*m)-1)*yap(n)) ...
               -(k((2*m)-1)*k(2*m)*x(3*m)) ...
               +(k((2*m)-1)*pek(2*m)*x((3*m)+1));
    y(n)=x((3*m)-1)+(c((2*m)+1)*x((3*m)+1));
    yap(n)=(mek(2*m)*x(3*m)) ...
           +(k(2*m)*x((3*m)+1));
  endfor
  if rem(Nk,2)
    nextx(Nx)=-(k(Nk)*yap(n))+(pek(Nk)*u(n));
    y(n)=y(n)+(c(Nk+1)*u(n));
    yap(n)=(mek(Nk)*yap(n))+(k(Nk)*u(n));
  else 
    nextx(Nx-2)=-(k(Nk-1)*yap(n)) ...
                -(pek(Nk-1)*k(Nk)*x(Nx)) ...
                +(pek(Nk-1)*pek(Nk)*u(n));
    nextx(Nx-1)=y(n) ...
                -(c(Nk)*k(Nk)*x(Nx)) ...
                +(c(Nk)*pek(Nk)*u(n));
    nextx(Nx)=(mek(Nk-1)*yap(n)) ...
              -(k(Nk-1)*k(Nk)*x(Nx)) ...
              +(k(Nk-1)*pek(Nk)*u(n));
    y(n)=x(Nx-1)+(c(Nk+1)*u(n));
    yap(n)=(mek(Nk)*x(Nx))+(k(Nk)*u(n));   
  endif
  
  % Scale the state and truncate it 
  x=nextx./px;
  if rtype == 1
    x = round(x);
  elseif rtype == 2
    x = fix(x);
  endif

  % Store the state
  xx(n+1,:) = x;
    
endfor

% Truncate the outputs
if rtype == 1
  y = round(y);
  yap = round(yap);
elseif rtype == 2
  y = fix(y);
  yap = fix(yap);
endif

endfunction
