function [a,ha,Qa,wQa]=zolotarevFIRcascade_wr2T(wr,p,wmax,nplot)
% [a]=zolotarevFIRcascade_wr2T(wr,p)
% [a,ha]=zolotarevFIRcascade_wr2T(wr,p)
% [a,ha]=zolotarevFIRcascade_wr2T(wr,p,wmax)
% [a,ha,Qa,wQa]=zolotarevFIRcascade_wr2T(wr,p,wmax,nplot)
%
% Helper function. Given the roots, wr, in the w-domain, of the zero-phase
% transfer function, Q, calculate the coefficients of the expansion of that
% polynomial in Chevbyshev polynomials of the first kind. If requested,
% return the normalised z-domain impulse response. See:
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

  if ((nargin<1) && (nargin>4)) ...
     || (nargout>4) ...
     || ((nargout>=3) && (nargin~=4))
    print_usage("a=zolotarevFIRcascade_wr2T(wr,p)\n\
a=zolotarevFIRcascade_wr2T(wr,p,wmax)\n\
[a,ha]=zolotarevFIRcascade_wr2T(wr,p)\n\
[a,ha]=zolotarevFIRcascade_wr2T(wr,p,wmax)\n\
[a,ha,Qa,wQa]=zolotarevFIRcascade_wr2T(wr,p,wmax,nplot)");
  endif

  % Given the roots of a polynomial in the w-domain, calculate the
  % coefficients of the expansion of that polynomial in Chevbyshev
  % polynomials of the first kind
  a=roots2T(wr);
  if any(isnan(a)) || any(isinf(a))
    error("a undefined");
  endif
  a=a*((-1)^p);
  
  % If requested, calculate the corresponding z-domain impulse response
  if nargout>=2
    c=length(wr)+1;
    ha=zeros(1,(2*(length(wr)))+1);
    ha(c)=a(1);
    ha(1:(c-1))=fliplr(a(2:end))/2;
    ha((c+1):end)=a(2:end)/2;
  endif

  % If requested, normalise the z-domain impulse response
  if nargout>=2 && nargin>=3
    Hamax=freqz(ha,1,[acos(wmax),0])(1);
    ha=ha/abs(Hamax);
  endif

  % If requested, calculate the z-domain zero-phase response
  if nargout>=3 && nargin==4
    [Ha,wQa]=freqz(ha,1,nplot);
    Qa=real(Ha.*(e.^(j*wQa*(c-1))));
  endif
  
endfunction
