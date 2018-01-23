function r=schurOneMAPlattice2tf(k,epsilon,p,R)
% r=schurOneMAPlattice2tf(k,epsilon,p,R)
% Find the all-pass filter denominator polynomial, r, of the Schur
% one-multiplier lattice with coefficients k and epsilon, scaling p
% and terms in z^R.

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

  if ((nargin ~= 3) && (nargin ~= 4)) || (nargout ~= 1)
    print_usage("r=schurOneMAPlattice2tf(k,epsilon,p,R)");
  endif
  
  [A,B,Cap,Dap]=schurOneMAPlattice2Abcd(k,epsilon,p);
  [~,r]=Abcd2tf(A,B,Cap,Dap);
  if nargin == 4
    rr=zeros(1,(R*(length(r)-1))+1);
    rr(1:R:end)=r;
    r=rr;
  endif
  
endfunction
