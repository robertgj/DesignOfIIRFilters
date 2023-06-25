function [A,B,C,D,Cap,Dap] = schurOneMlatticePipelined2Abcd(k,epsilon,c)
% [A,B,C,D,Cap,Dap] = schurOneMlatticePipelined2Abcd(k,epsilon,c)
% Find the state variable representation of a pipelined Schur one-multiplier
% lattice filter.
%
% Inputs:
%  k       - the lattice filter one-multiplier coefficients
%  epsilon - the sign coefficients for each module
%  c       - the numerator polynomial tap weights in the orthogonal basis
% Outputs:
%  [A,B;C,D] - state variable description of the pipelined Schur lattice filter
%  Cap,Dap   - corresponding matrixes for the all-pass filter
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
  
  % Copyright (C) 2017-2023 Robert G. Jenssen
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

  % Sanity checks
  if nargin~=3 || nargout<4 || nargout>6
    print_usage("[A,B,C,D,Cap,Dap]=schurOneMlatticePipelined2Abcd(k,epsilon,c)");
  endif
  if isempty(k)
    error("k is empty!");
  endif
  if length(k)~=length(epsilon) || ...
     (length(k)+1)~=length(c)
    error("Input coefficient lengths inconsistent!");
  endif
  
  % Initialise
  Nk=length(k);
  Nc=length(c);
  if rem(Nk,2)
    Ns=(3*ceil(Nk/2))-2;
  else
    Ns=3*Nk/2;
  endif

  % Modules 1 to ceil(Nk/2)-1
  ABCD=[c(1),zeros(1,Ns);1,zeros(1,Ns);eye(Ns+1)];
  for n=1:(ceil(Nk/2)-1)
    ABCDm=eye(Ns+3);
    ABCDm((3*(n-1))+(1:5),(3*(n-1))+(1:6))=...
    [0,-k((2*n)-1),0,0,-(1+(k((2*n)-1)*epsilon((2*n-1))))*k(2*n), ...
       (1+(k((2*n)-1)*epsilon((2*n)-1)))*(1+(k(2*n)*epsilon(2*n)));...
     1,0,0,0,-c(2*n)*k(2*n), ...
       c(2*n)*(1+(k(2*n)*epsilon(2*n)));...
     0,1-(k((2*n)-1)*epsilon((2*n)-1)),0,0,-k((2*n)-1)*k(2*n), ...
       k((2*n)-1)*(1+(k(2*n)*epsilon(2*n)));...
     0,0,0,1,0,c((2*n)+1);...
     0,0,0,0,1-(k(2*n)*epsilon(2*n)),k(2*n)];
    ABCD=ABCDm*ABCD;
  endfor
  
  % Final module
  if rem(Nk,2)
    ABCDm=eye(Ns+2);
    ABCDm(Ns-1+(1:3),Ns-1+(1:4))=...
    [0,-k(Nk),0,1+(k(Nk)*epsilon(Nk)); ...
     1,0,0,c(Nc); ...
     0,1-(k(Nk)*epsilon(Nk)),0,k(Nk)];
  else
    ABCDm=eye(Ns+2);
    ABCDm(Ns-3+(1:5),Ns-3+(1:6))=...
    [0,-k(Nk-1),0,0,-(1+(k(Nk-1)*epsilon(Nk-1)))*k(Nk), ...
       (1+(k(Nk-1)*epsilon(Nk-1)))*(1+(k(Nk)*epsilon(Nk)));...
     1,0,0,0,-c(Nc-1)*k(Nk), ...
       c(Nc-1)*(1+(k(Nk)*epsilon(Nk)));...
     0,1-(k(Nk-1)*epsilon(Nk-1)),0,0,-k(Nk-1)*k(Nk), ...
       k(Nk-1)*(1+(k(Nk)*epsilon(Nk)));...
     0,0,0,1,0,c(Nc);...
     0,0,0,0,1-(k(Nk)*epsilon(Nk)),k(Nk)];
  endif
  ABCD=ABCDm*ABCD;

  % Extract the state variable description
  A=ABCD(1:Ns,1:Ns);
  B=ABCD(1:Ns,Ns+1);
  C=ABCD(Ns+1,1:Ns);
  D=ABCD(Ns+1,Ns+1);
  Cap=ABCD(Ns+2,1:Ns);
  Dap=ABCD(Ns+2,Ns+1);

endfunction

