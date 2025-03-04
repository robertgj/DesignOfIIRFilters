function [Ea,Eb,Ec,Ed]=directFIRsymmetric_sdp_basis(n)
% If n=2k:
%  [E0k,E0km1,E1km1,E2km1]=directFIRsymmetric_sdp_basis(n)
% else:
%  [E0k,E1k]=directFIRsymmetric_sdp_basis(n)
%
% Return the basis matrixes for the moment matrix:
%   cos(l*omega)*(1,cos(omega),...,cos(n*omega)'*(1,cos(omega),...,cos(n*omega)
% with y_p <-> cos(p*omega) and l=0,1,2
%
% For n=2k we need:
%   E0k   - coefficients of y_0, ..., y_2k
%   E0km1 - coefficients of y_0, ..., y_2k-2
%   E1km1 - coefficients of y_0, ..., y_2k-1
%   E2km1 - coefficients of y_0, ..., y_2k
%
% For n=2k+1 we need:
%   E0k - coefficients of y_0, ..., y_2k
%   E1k - coefficients of y_0, ..., y_2k+1
%
% See Appendix 1 of:
% "Efficient Large-Scale Filter/Filterbank Design via LMI Characterization
% of Trigonometric Curves", H. D. Tuan et al, IEEE Transactions on Signal
% Processing, Vol. 55, No. 9, September 2007, pp. 4393-4404
 
% Copyright (C) 2021-2025 Robert G. Jenssen
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
  if (nargin~=1) || (round(n)<=0) || ...
     ((nargout~=4)&&(rem(n,2)==0)) || ...
     ((nargout~=2)&&(rem(n,2)==1))
    print_usage("n is a positive non-zero integer.\n\If n=2k: \n\
  [E0k,E0km1,E1km1,E2km1]=directFIRsymmetric_sdp_basis(n) \n\
else: \n\
  [E0k,E1k]=directFIRsymmetric_sdp_basis(n)");  
  endif

  n=round(n);
  k=floor(n/2);
  delta_ipj=abs((0:k)'+(0:k));
  delta_imj=abs((0:k)'-(0:k));

  E0k=cell(1,n+1);
  for m=0:n,
    E0k{m+1}=sparse(zeros(k+1,k+1));
    ij=find(delta_ipj==m);
    E0k{m+1}(ij)=E0k{m+1}(ij)+1;
    ij=find(delta_imj==m);
    E0k{m+1}(ij)=E0k{m+1}(ij)+1;
    E0k{m+1}=E0k{m+1}/2;
  endfor
  
  E0km1=cell(1,n+1);
  for m=0:(n-2),
    E0km1{m+1}=E0k{m+1}(1:k,1:k);
  endfor
  for m=(n-1):n,
    E0km1{m+1}=sparse(zeros(k,k));
  endfor

  l=1;
  delta_ipjp1=abs(delta_ipj+l);
  delta_ipjm1=abs(delta_ipj-l);
  delta_imjp1=abs(delta_imj+l);
  delta_imjm1=abs(delta_imj-l);
  E1k=cell(1,n+1);
  for m=0:n,
    E1k{m+1}=sparse(zeros(k+1,k+1));
    ij=find(delta_ipjp1==m);
    E1k{m+1}(ij)=E1k{m+1}(ij)+1;
    ij=find(delta_ipjm1==m);
    E1k{m+1}(ij)=E1k{m+1}(ij)+1;
    ij=find(delta_imjp1==m);
    E1k{m+1}(ij)=E1k{m+1}(ij)+1;
    ij=find(delta_imjm1==m);
    E1k{m+1}(ij)=E1k{m+1}(ij)+1;
    E1k{m+1}=E1k{m+1}/4;
  endfor

  if rem(n,2)==1
    Ea=E0k;
    Eb=E1k;
    return;
  endif

  E1km1=cell(1,n+1);
  for m=0:(n-1),
    E1km1{m+1}=E1k{m+1}(1:k,1:k);
  endfor
  E1km1{n+1}=sparse(zeros(k,k));

  l=2;
  delta_ipjp2=abs(delta_ipj(1:k,1:k)+l);
  delta_ipjm2=abs(delta_ipj(1:k,1:k)-l);
  delta_imjp2=abs(delta_imj(1:k,1:k)+l);
  delta_imjm2=abs(delta_imj(1:k,1:k)-l);
  E2km1=cell(1,n+1);
  for m=0:n,
    E2km1{m+1}=sparse(zeros(k,k));
    ij=find(delta_ipjp2==m);
    E2km1{m+1}(ij)=E2km1{m+1}(ij)+1;
    ij=find(delta_ipjm2==m);
    E2km1{m+1}(ij)=E2km1{m+1}(ij)+1;
    ij=find(delta_imjp2==m);
    E2km1{m+1}(ij)=E2km1{m+1}(ij)+1;
    ij=find(delta_imjm2==m);
    E2km1{m+1}(ij)=E2km1{m+1}(ij)+1;
    E2km1{m+1}=E2km1{m+1}/4;
  endfor

  Ea=E0k;
  Eb=E0km1;
  Ec=E1km1;
  Ed=E2km1;

endfunction
