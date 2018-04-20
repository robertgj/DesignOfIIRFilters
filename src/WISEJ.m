function E=WISEJ(ND,_nN,_nD,_R,_wd,_Hd,_Wd)
% E=WISEJ(ND,nN,nD,R,wd,Hd,Wd)
% Function for filter response optimisation. A barrier
% function maintains stability by constraining the pole locations to
% be within the unit circle in the z-plane. The argument ND is the
% concatenation of the numerator and denominator polynomials to be
% optimised:
%  N=ND(1:(nN+1));
%  D=[1;ND((nN+2):end)];
% First initialise the common parameters of the filter structure with:
%  WISEJ([],nN,nD,R,wd,Hd,Wd)
% The common filter parameters are:
%  nN    order of numerator polynomial
%  nD    order of undecimated denominator polynomial
%  R     decimation factor for denominator polynomial. The resulting
%        denominator polynomial order is  _R*_nD and it has non-zero
%        coefficients only for powers of z^R
%  wd    angular frequencies at which to calculate the response
%  Hd    desired filter response at _wd. If Hd is complex use abs(Hd-H)
%        to calculate the error. Otherwise uses abs(Hd)-abs(H).
%  Wd    filter response weighting factor at _wd
%
% See "A WISE Method for Designing IIR Filters", A.Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

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

if (nargin ~= 1) && (nargin ~= 7)
  print_usage("E=WISEJ(ND) [Initialise with E=WISEJ([],nN,nD,R,wd,Hd,Wd)]");
endif

persistent nN nD R wd Hd Wd

% Initialisation
if (nargin == 7)
  nN = _nN;
  nD = _nD;
  R  = _R;
  wd = _wd;
  Hd = _Hd;
  Wd = _Wd;
  E=0;
  return;
endif

% Sanity check
if length(ND) ~= (nN+1+nD)
  error("Expected length(ND) = (nN+1+nD)");
endif

% Decimate the denominator
ND=ND(:);
N=ND(1:(nN+1));
DR=[1; kron(ND((nN+2):end), [zeros(R-1,1);1])];

% Find the error of the amplitude response
% (This separate calculation is generally more accurate!).
HNd = freqz(N, 1, wd);
HDRd = freqz(DR, 1, wd);
if any(iscomplex(Hd))
  EHd = Wd.*((abs(Hd-(HNd./HDRd))).^2);
else
  EHd = Wd.*((abs(Hd)-abs(HNd./HDRd)).^2);
endif
% Trapezoidal integration of amplitude response error
intEHd = sum(diff(wd).*(EHd(1:(end-1))+EHd(2:end)))/2;

% Heuristics for the barrier function
lambda = 0.001;
if (nD > 0)
  M = nD*R;
  T = 300;
  rho = 31/32;
  % Calculate barrier function
  DRrho=DR./(rho.^(0:(length(DR)-1))');
  [ADR,bDR,cDR,dDR] = tf2Abcd(1,DRrho);
  f = zeros(M,1);
  cADR_Tk = cDR*(ADR^(T-1));
  for k=1:M
    f(k) = cADR_Tk*bDR;
    cADR_Tk = cADR_Tk*ADR;
  endfor
  f = real(f);
  EJ = sum(f.*f);
else
  EJ = 0;
endif

% Done
E = ((1-lambda)*intEHd) + (lambda*EJ);

endfunction
