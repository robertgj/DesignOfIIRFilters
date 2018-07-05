function [ng,ngap]=schurOneMlatticeRetimedNoiseGain(k,epsilon,p,c,filterStr)
% [ng,ngap]=schurOneMlatticeRetimedNoiseGain(k,epsilon,p,c,filterStr)
% Inputs:
%  k are the lattice filter multiplier coefficients
%  epsilon are sign coefficients for each module
%  p are the state scaling factors
%  c are the numerator polynomial tap weights in the orthogonal basis
%  filterStr is a string describing the filter implementation,
%    selecting the states to be included in the round-off noise gain 
%    estimate. 
% Outputs:
%  ng is the noise gain of the lattice filter
%  ngap is the noise gain of the allpass lattice filter
%
% The lattice filter structure is:
%                                             ___move_c1_to_here___
%                                            |                     |
%       _______  x3N-1_       _______  __x5__V _______  __x2__     | 
% Out <-|     |<-|z^-1|<-...<-|     |<-|z^-1|<-|     |<-|z^-1|<--  |
%       |     |  -----        |     |  ------  |     |  ------  | c(1)
%       |     |  _x3N__       |     |  __x6__  |     |  __x3__  |  =c0
%  In ->|  N  |->|z^-1|->...->|  2  |->|z^-1|->|  1  |->|z^-1|->o
%       |     |  ------       |     |  ------  |     |  ------  |
%       |     |  x3N-2_       |     |  __x4__  |     |  __x1__  |
%  AP <-|     |<-|z^-1|<-...<-|     |<-|z^-1|<-|     |<-|z^-1|<--
% Out   -------  ------       -------  ------  -------  ------
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
% In the retimed and pipelined implementation above, each node has a
% state. The noise gain of different implementations can be estimated
% by including the appropriate states. The choices available are: 
%   "schur"     - Schur lattice filter implemented in schurOneMlatticeFilter.m
%   "ABCD"      - Schur lattice filter implemented in svf.m
%   "pipelined" - Schur lattice filter with extra states to control latency
%   "decimator" - Schur lattice filter calculated at twice the sample rate

% Copyright (C) 2017,2018 Robert G. Jenssen
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
  if nargin ~= 5 || nargout~=2
    print_usage ...
      ("[ng,ngap]=schurOneMlatticeRetimedNoiseGain(k,epsilon,p,c,filterStr)");
  endif
  if length(k)~=length(epsilon) ...
     || length(k)~=length(p)    ...
     || (1+length(k))~=length(c)
    error("Input vector lengths inconsistent!");
  endif
  % Filter type
  fchoice=tolower(filterStr(1:4));
  if (fchoice ~= "schu") && (fchoice ~= "pipe") && ...
     (fchoice ~= "deci") && (fchoice ~= "abcd")
    error("Expected \"schur\",\"pipelined\",\"decimator\" or \"abcd\" filter!");
  endif

  %
  % Construct the retimed filter
  %

  % Initialise
  N=length(k);
  A=zeros((N*3),(N*3));
  B=zeros(N*3,1);
  C=zeros(1,N*3);
  pek=ones(size(k))+(epsilon.*k);
  mek=ones(size(k))-(epsilon.*k);

  % Modules 1 to N-1, 3 states per module
  A(1,3) = 1;
  A(2,3) = c(1);
  col=1;
  row=3;
  for n=1:(N-1)
    % One-multiplier section
    A(row  ,col)   = -k(n);
    A(row  ,col+5) = pek(n);
    A(row+1,col)   = mek(n);
    A(row+1,col+5) = k(n);
    % Pipelined output row
    A(row+2,col+1) = 1;
    A(row+2,col+5) = c(n+1);
    % Step
    col = col+3;
    row = row+3;
  endfor

  % Move c0=c(1) from the calculation of x2 to x5
  % ie : x2=x3, x5=c0x2+c1x6 instead of x2=c0x3,x5=x2+c1x6
  if N>1
    A(2,3) = 1;
    A(5,2) = c(1);
  endif
  % Input and output
  A(row,col) = -k(N);
  B(row)     = pek(N);
  C(row-1)   = 1;
  D          = c(N);

  % Scale the filter states
  pR2=kron(p(:),ones(3,1));
  T=diag(pR2);
  A=inv(T)*A*T;
  B=inv(T)*B;
  C=C*T;

  % Construct the retimed all-pass lattice filter output, Yap=Cap*X+Dap*U
  Cap = zeros(1,N*3);
  Cap((3*N)-2) = mek(N)*p(N);
  Dap = k(N);

  %
  % Select the lattice filter states used to calculate the noise gain
  %
  if fchoice=="schu"
    % The upper filter output is calculated in a wide accumulator so
    % states on the upper row are omitted from the noise gain calculation.
    % The all-pass output is calculated with a truncation at each
    % intermediate step. State x1 has no roundoff.
    selectX=kron(ones(N,1),[1;0;1]);
    selectX(1)=0;
    % The all-pass filter output is calculated with intermediate
    % truncations at each stage
    selectXap=kron(ones(N,1),[1;0;1]);
    selectXap(1)=0;
  elseif fchoice=="abcd"
    % In svf.m both outputs are calculated in a wide accumulator.
    selectX=kron(ones(N,1),[0;0;1]); 
    selectXap=selectX;
  elseif fchoice=="deci"
    % In the retimed and pipelined decimator filter with a state for 
    % each node, states 3-3*N contribute to output noise (x5 includes
    % the c0=c(1) coefficient instead of x2) so dont include x1 and x2: 
    selectX=[0;0;ones((N*3)-2,1)];
    % For the retimed pipelined decimator all-pass filter use all states but x1
    selectXap=kron(ones(N,1),[1;0;1]);
    selectXap(1)=0;
  elseif fchoice=="pipe"
    % The pipelined filter alternates between 1 and 2 states per section.
    if rem(N,2)
      selectX=[kron(ones((N-1)/2,1),[0;0;1;1;1;0]);0;0;1];
      selectXap=[kron(ones((N-1)/2,1),[0;0;1;1;0;0]);0;0;1];
    else
      selectX=kron(ones(N/2,1),[0;0;1;1;1;0]);
      selectXap=kron(ones(N/2,1),[0;0;1;1;0;0]);
    endif
  else
    error("Unknown ftype! Should not get to here!!!");
  endif

  %
  % Calculate the noise gains
  %
  [K W]=KW(A,B,C,D); 
  ng=sum(diag(K).*diag(W).*selectX);
  [Kap Wap]=KW(A,B,Cap,Dap);  
  ngap=sum(diag(Kap).*diag(Wap).*selectXap);

endfunction
