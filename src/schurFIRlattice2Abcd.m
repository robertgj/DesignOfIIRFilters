function [A,B,C,D]=schurFIRlattice2Abcd(k)
% [A,B,C,D]=schurFIRlattice2Abcd(k)
% Inputs:
%  k are the Schur FIR lattice filter coefficients
% Outputs:
%  [A,B,C,D] is the state variable description of the Schur FIR lattice filter

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
  if nargin~=1 || nargout~=4
    print_usage("[A,B,C,D]=schurFIRlattice2Abcd(k)");
  endif

  % Initialise
  N=length(k);
  ABCD=[zeros(2,N),ones(2,1);eye(N,N),zeros(N,1)];

  % Nodules 1 to N
  for n=1:N
    Vn=[0  1 0;1  0 k(n);k(n) 0 1];
    nMod=[eye(n-1,n-1),zeros(n-1,(N+2)-(n-1));
          zeros(3,n-1),Vn,zeros(3,(N+2)-(n-1)-3);
          zeros((N+2)-(n-1)-3,(N+2)-(N-n)),eye(N-n,N-n)];
    ABCD=nMod*ABCD;
  endfor

  % Extract state variable description
  A=ABCD(1:N,1:N);
  B=ABCD(1:N,N+1);
  % Construct filter output
  C=ABCD(N+1,1:N);
  D=ABCD(N+1,N+1);

endfunction
