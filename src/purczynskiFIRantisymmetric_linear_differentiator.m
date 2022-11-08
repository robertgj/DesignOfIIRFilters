function h=purczynskiFIRantisymmetric_linear_differentiator(N,p)
% h=purczynskiFIRantisymmetric_linear_differentiator(N,p)
% Purczynski and Pawelczak's implementation of Kumar and Roy's algorithm for
% the closed-form design of an even-order, odd-length, anti-symmetric,
% linear-phase, maximally-linear at omega=pi/p, FIR differentiator filter.
% where N-1 is a multiple of 4 and p is even.
%
% Inputs:
%   N - N=4m+1 and filter length is 1+((N-1)*p/2) with p interpolated zeros
%   p - p even and the differentiator is maximally linear at omega=pi/p
%
% Outputs:
%   h - coefficients of the anti-symmetric FIR differentiator filter

% Copyright (C) 2020-2022 Robert G. Jenssen
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

  if (nargin<2) || (nargout>1)
    print_usage("h=purczynskiFIRantisymmetric_linear_differentiator(N,p);");
  endif

  % Sanity checks
  if N<=0
    error("N<=0");
  endif
  if mod(N-1,4)
    error("Expect N=4*M+1 !");
  endif
  if p<=0
    error("p<=0");
  endif
  if mod(p,2)
    error("Expect p a multiple of 2!");
  endif     
  
  % Calculation of the filter d coefficients
  n=(N-1)/2;
  m=n/2;
  d=zeros(n,1);
  d(1)=(m/(4^((2*m)-1)))*(bincoeff(2*m,m)^2);
  d(2)=-(2*m)/(m+1);
  for k=2:m,
    d(2*k-1)=d(2*k-3)*(2*k-3)*(m-k+1)/((2*k-1)*(m+k-1));
    d(2*k)=d(2*k-2)*(k-1)*(m-k+1)/(k*(m+k));
  endfor

  % Build filter impulse response
  d(1:2:(2*m)-1)=d(1:2:(2*m)-1)*(pi/p);
  d(2:2:(2*m))=d(2:2:(2*m))/p;
  h=[flipud(d);0;-d]/2;
  h=kron(h,[1;zeros((p/2)-1,1)]);
  h=h(1:(((N-1)*p/2)+1));

endfunction
