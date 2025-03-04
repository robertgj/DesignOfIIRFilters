function [C,L]=bertsekas_correction(hessE)
% function [C,L]=bertsekas_correction(hessE)
% Find the diagonal correction matrix, C, for which (hessE+C)=LLt is positive
% definite. See Appendix D.2 of "Nonlinear Programming 2nd Edition",
% D. P. Bertsekas, Athena Scientific, 1999, ISBN 1-886529-00-0.

% Copyright (C) 2024-2025 Robert G. Jenssen
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

  if (nargout > 2) || (nargin ~= 1)
    print_usage("[C,L]= bertsekas_correction(hessA)");
  endif

  if (rows(hessE) ~= columns(hessE)) || ~issymmetric(hessE)
    error("hessE is not a symmetric square matrix!");
  endif

  
  % Initialise 
  N=rows(hessE);
  L=zeros(size(hessE));
  C=zeros(1,rows(hessE));
  wk=max(diag(hessE));
  r1=0.01;
  r2=0.1;
  m1=r1*wk;
  m2=r2*wk;
  sqrtm2=sqrt(m2);

  % Calculate the first column of L
  if m1<hessE(1,1)
    L(1,1)=sqrt(hessE(1,1));
  else
    L(1,1)=sqrtm2;
  endif
  L(2:N,1)=hessE(2:N,1)/L(1,1);

  % Loop calculating columns of L
  for p=2:N,
    Ctmp=hessE(p,p)-sum(L(p,1:(p-1)).^2);
    if m1 < Ctmp
      L(p,p)=sqrt(hessE(p,p)-sum(L(p,1:(p-1))).^2);
    else
      L(p,p)=sqrtm2;
      C(p)=m2-Ctmp;
    endif
    for q=(p+1):N
      L(q,p)=(hessE(q,p)-sum(L(p,1:(p-1)).*L(q,1:(p-1))))/L(p,p);
    endfor
  endfor

endfunction
