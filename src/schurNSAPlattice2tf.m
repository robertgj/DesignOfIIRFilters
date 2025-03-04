function r=schurNSAPlattice2tf(s20,s00,s02,s22,R)
% r=schurNSAPlattice2tf(s20,s00,s02,s22,R)
% Find the all-pass filter denominator polynomial, r, of the Schur
% scaled-normalised lattice with coefficients s20, s00, s02 and s22
% and terms in z^R.

% Copyright (C) 2022-2025 Robert G. Jenssen
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

  if ((nargin ~= 4) && (nargin ~= 5)) || (nargout ~= 1)
    print_usage("r=schurNSAPlattice2tf(s20,s00,s02,s22,R)");
  endif
  
  [A,B,Cap,Dap]=schurNSAPlattice2Abcd(s20,s00,s02,s22);
  [~,r]=Abcd2tf(A,B,Cap,Dap);
  if nargin == 5
    rr=zeros(1,(R*(length(r)-1))+1);
    rr(1:R:end)=r;
    r=rr;
  endif
  
endfunction
