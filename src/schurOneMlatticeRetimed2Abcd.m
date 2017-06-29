function [A,B,C,D,ng,Aap,Bap,Cap,Dap,ngap]=...
  schurOneMlatticeRetimed2Abcd(k,epsilon,p,c,filterStr)
% [A,B,C,D,ng,Aap,Bap,Cap,Dap,ngap]=...
%   schurOneMlatticeRetimed2Abcd(k,epsilon,p,c,filterStr)
% Inputs:
%  k are the lattice filter multiplier coefficients
%  epsilon are sign coefficients for each module
%  p are the state scaling factors
%  c are the numerator polynomial tap weights in the orthogonal basis
%  filterStr is a string describing the filter implementation,
%    selecting the states to be included in the round-off noise gain 
%    estimate. 
% Outputs:
%  [A,B,C,D] is the state variable description of the lattice filter
%  ng is the noise gains of the lattice filter
%  [Aap,Bap,Cap,Dap] is the state variable description of the
%  ngap is the noise gain of the allpass filter
%
% The filter returned is the slowed and retimed form of the lattice. 
% The lattice filter structure is:
%       _______  x3N-1_       _______  __x5__  _______  __x2__
% Out <-|     |<-|z^-1|<-...<-|     |<-|z^-1|<-|     |<-|z^-1|<--
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
%   "schur"     - the Schur lattice implementation in 
%                 schurOneMlatticeFilter.m
%   "ABCD"      - the state-variable implementation in svf.m
%   "decimator" - a state-variable filter with denominator
%                 polynomial in z^2 retimed and pipelined

% Copyright (C) 2017 Robert G. Jenssen
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
if nargin ~= 5 || nargout~=10
  print_usage(strcat("[A,B,C,D,ng,Aap,Bap,Cap,Dap,ngap]=...\n"), ...
        strcat("schurOneMlatticeRetimed2Abcd(k,epsilon,p,c,filterStr)"));
endif
if length(k)~=length(epsilon) ...
   || length(k)~=length(p)    ...
   || (1+length(k))~=length(c)
  error("Input vector lengths inconsistent!");
endif
% Filter type
fchoice=filterStr(1:4);
if fchoice == "schu"
  ftype=1;
elseif fchoice == "ABCD"
  ftype=2; 
elseif fchoice == "deci"
  ftype=3;
else
  error("Expected \"schur\", \"ABCD\" or \"decimator\" filter!");
endif

%
% Filter
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
A(2,3) = 1;
A(5,2) = c(1);
% Input and output
A(row,col) = -k(N);
B(row)     = pek(N);
C(row-1)   = 1;
D          = c(N);

% Scale the filter states (not including x1 and x2)
pR2=kron(p(:),ones(3,1)); 
T=diag(pR2);
A=inv(T)*A*T;
B=inv(T)*B;
C=C*T;

% Find the output noise gain due to roundoff noise at the states
if ftype==1
  % In schurOneMlatticeFilter.m the upper filter output
  % is calculated in a wide accumulator so states on the upper
  % row are omitted from the noise gain calculation. The all-pass
  % output is calculated with a truncation at each intermediate
  % step. States x1 and x2 have no roundoff.
  % 
  selectX=[0 0 1 kron(ones(1,N-1),[1 0 1])]'; 
elseif ftype==2
  % In the state variable filter both outputs are calculated in a 
  % wide accumulator. Only include the original filter states.
  selectX=kron(ones(1,N),[0 0 1])'; 
elseif ftype==3
  % In the retimed and pipelined decimator filter with a state for 
  % each node, states 3-3*N contribute to output noise (x5 includes
  % the c0=c(1) coefficient instead of x2) so dont include x1 and x2: 
  selectX=[0 0 ones(1,(N*3)-2)]';
else
  error("Unknown ftype! Should not get to here!!!");
endif
[K W]=KW(A,B,C,D); 
ng=sum(diag(K).*diag(W).*selectX);

%
% All pass filter
%

% Yap=Cap*X+Dap*U, only use the all-pass states
selectABCap = find(kron(ones(1,N),[1 0 1]));
Aap = A(selectABCap,selectABCap);
Bap = B(selectABCap);
Cap = zeros(1,N*3);
Cap((3*N)-2) = mek(N)*p(N);
Cap = Cap(selectABCap);
Dap = k(N);

% All-pass noise gain
[Kap Wap]=KW(Aap,Bap,Cap,Dap);  
if ftype==1
  % In schurOneMlatticeFilter.m the all-pass filter output
  % is calculated with intermediate truncations at each stage
  selectXap=[0 ones(1,(N*2)-1)]'; 
elseif ftype==2
  % In svf.m the all-pass output is calculated in a wide accumulator
  selectXap=kron(ones(1,N),[0 1])'; 
elseif ftype==3
  % For the retimed pipelined decimator filter use all states but x1
  selectXap=[0 1 ones(1,(N-1)*2)]';
else
  error("Unknown ftype! Should not get to here!!!");
endif
ngap=sum(diag(Kap).*diag(Wap).*selectXap);

endfunction
