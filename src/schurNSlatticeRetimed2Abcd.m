function [A,B,C,D,ng,Aap,Bap,Cap,Dap,ngap]=...
  schurNSlatticeRetimed2Abcd(s10,s11,s20,s00,s02,s22)
% [A,B,C,D,ng,Aap,Bap,Cap,Dap,ngap]=...
%   schurNSlatticeRetimed2Abcd(s10,s11,s20,s00,s02,s22)
% Inputs:
%  s10,s11,s20,s00,s02,s22 are the lattice filter multiplier coefficients
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
%       |     |  -----        |     |  ------  |     |  ------  |
%       |     |  _x3N__       |     |  __x6__  |     |  __x3__  |
%  In ->|  N  |->|z^-1|->...->|  2  |->|z^-1|->|  1  |->|z^-1|->o
%       |     |  ------       |     |  ------  |     |  ------  |
%       |     |  x3N-2_       |     |  __x4__  |     |  __x1__  |
%  AP <-|     |<-|z^-1|<-...<-|     |<-|z^-1|<-|     |<-|z^-1|<--
% Out   -------  ------       -------  ------  -------  ------
%
% Each module 1,..,N is implemented as:
%                      
%       <---------+<----------------<
%                 ^     s11       
%              s10|
%                 |
%       >---------o--o------>+------>
%                    |  s00  ^
%                 s20|       |s02 
%                    V  s22  |
%       <------------+<------o------<

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
if nargin~=6 || nargout~=10
  print_usage(strcat("[A,B,C,D,ng,Aap,Bap,Cap,Dap,ngap]="), ...
        strcat("schurNSlatticeRetimed2Abcd(s10,s11,s20,s00,s02,s22)"));
endif
if length(s10)~=length(s11) || ...
   length(s10)~=length(s20) || ...
   length(s10)~=length(s00) || ...
   length(s10)~=length(s02) || ...
   length(s10)~=length(s22)
  error("Input vector lengths inconsistent!");
endif

%
% Filter
%

% Initialise
N=length(s22);
A=zeros((N*3),(N*3));
B=zeros(N*3,1);
C=zeros(1,N*3);

% Modules 1 to N-1, 3 states per module
A(1,3) = 1;
A(2,3) = 1;
col=1;
row=3;
for n=1:(N-1)
  % All-pass rotation
  A(row  ,col)   = s02(n);
  A(row  ,col+5) = s00(n);
  A(row+1,col)   = s22(n);
  A(row+1,col+5) = s20(n);
  % Pipelined output row
  A(row+2,col+1) = s11(n);
  A(row+2,col+5) = s10(n);
  % Step
  col = col+3;
  row = row+3;
endfor
% Input and output
A(row,col) = s02(N);
B(row)     = s00(N);
C(row-1)   = s11(N);
D          = s10(N);

% Find the output noise gain due to roundoff noise at the states
[K W]=KW(A,B,C,D);
% States 3-N*N contribute to output noise
selectX=[0 0 ones(1,(N*3)-2)]';
ng=sum(diag(K).*diag(W).*selectX);

%
% All pass filter
%

% Yap=Cap*X+Dap*U
selectABCap = find(kron(ones(1,N),[1 0 1]) ~= 0);
% Only use the all-pass states
Aap = A(selectABCap,selectABCap);
Bap = B(selectABCap);
Cap = zeros(1,N*3);
Cap((3*N)-2) = s22(N);
Cap = Cap(selectABCap);
Dap = s20(N);

% Find the allpass output noise gain due to roundoff noise at the states
[Kap Wap]=KW(Aap,Bap,Cap,Dap);
selectXap=[0 ones(1,(N*2)-1)]';
ngap=sum(diag(Kap).*diag(Wap).*selectXap);

endfunction
