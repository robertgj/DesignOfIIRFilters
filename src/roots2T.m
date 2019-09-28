function a=roots2T(r)
% Helper function for zolotarevFIRcascade_test.m. Given the all real
% roots of a polynomial, calculate the coefficients of  the expansion
% of that polynomial in Chevbyshev polynomials of the first kind. See:
% [1] "Cascade Structure of Narrow Equiripple Bandpass FIR Filters",
% P.Zahradnik, M.Susta,B.Simak and M.Vlcek, IEEE Transactions on Circuits
% and Systems-II:Express Briefs, Vol. 64, No. 4, April 2017, pp. 407-411
  
% Copyright (C) 2019 Robert G. Jenssen
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
  
  warning("Using Octave m-file version of function roots2T()!");

  if (nargin~=1) || (nargout>1)
   print_usage("a=roots2T(r)");
  endif

  if isempty(r)
    a=[];
    return;
  endif
  
  if length(r)==1
    a=[-r(1) 1];
    return;
  endif;
  
  scale=1;
  lasta=zeros(size(r));
  lasta(1+0)=-r(1+0);
  lasta(1+1)=1;
  for m=1:(length(r)-1)
    a=zeros(1,length(r)+1);
    lasta(1+m+1)=0;
    a(1+0)=(lasta(1+1)-(2*r(1+m)*lasta(1+0)));
    a(1+1)=(lasta(1+2)+(2*lasta(1+0))-(2*r(1+m)*lasta(1+1)));
    a(1+(2:m))=lasta(1+(2:m)-1)+lasta(1+(2:m)+1)-(2*r(1+m)*lasta(1+(2:m)));
    a(1+m+1)=lasta(1+m);
    a=a/scale;
    lasta=a;
  endfor
  
endfunction
