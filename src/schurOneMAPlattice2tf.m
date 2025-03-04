function d=schurOneMAPlattice2tf(k,epsilon,p,R)
% d=schurOneMAPlattice2tf(k,epsilon,p,R)
% Find the all-pass filter denominator polynomial, d, of the Schur
% one-multiplier lattice with coefficients k and epsilon, scaling p
% and terms in z^R.

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

  if (nargin == 0) || (nargin > 4) || (nargout ~= 1)
    print_usage("d=schurOneMAPlattice2tf(k,epsilon,p,R)");
  endif
  if nargin < 3
    p=ones(size(k));
  endif
  if nargin < 2
    epsilon=ones(size(k));
  endif

  [A,B,Cap,Dap]=schurOneMAPlattice2Abcd(k,epsilon,p);
  [~,d]=Abcd2tf(A,B,Cap,Dap);
  if nargin == 4
    dd=zeros(1,(R*(length(d)-1))+1);
    dd(1:R:end)=d;
    d=dd;
  endif
  
endfunction
