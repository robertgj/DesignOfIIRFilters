function E=WISEJ_ND(ND,_nN,_nD,_R,_Ad,_Wa)
% E=WISEJ_ND(ND,nN,nD,R,Ad,Wa)
% Function for IIR filter response optimisation when I do not care
% about the phase of the response. A barrier function maintains
% stability by constraining the pole locations to be within the unit
% circle in the z-plane. The argument ND is the concatenation of the
% numerator and denominator polynomials to be optimised:
%  N=ND(1:(nN+1));
%  D=[1;ND((nN+2):end)];
% First initialise the common parameters of the filter structure with:
%  WISEJ_ND([],nN,nD,R,Ad,Wa,Td,Wt)
% The common filter parameters are:
%  nN - order of numerator polynomial
%  nD - order of undecimated denominator polynomial
%  R  - decimation factor for denominator polynomial. The resulting
%       denominator polynomial order is  R*nD and it has non-zero
%       coefficients only for powers of z^R
%  Ad - desired filter amplitude response 
%  Wa - filter amplitude response weighting factor
%
% See "A WISE Method for Designing IIR Filters", A.Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

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
  
  persistent nN nD R Ad Wa
  persistent init_done=false
  if nargin == 6
    nN=_nN;nD=_nD;R=_R;Ad=_Ad;Wa=_Wa;
    if length(Ad) ~= length(Wa)
      error("Expected length(Ad) == length(Wa)!");
    endif
    init_done=true;
    return;
  elseif nargin ~=1
    print_usage("E=WISEJ_ND(ND[,nN,nD,R,Ad,Wa])");
  elseif init_done==false
    error("init_done==false");
  endif
  % Sanity checks
  if (length(ND) ~= (1+nN+nD))
    error("Expected length(ND) == (1+nN+nD)!");
  endif
  
  % Decimate the denominator
  N=ND(1:(nN+1));
  DR=[1;kron(ND((nN+2):(nN+1+nD)), [zeros(R-1,1);1])];
  
  % Find the amplitude response error
  [HNDRd,wa] = freqz(N,DR,length(Ad));
  EAd = Wa.*((abs(Ad)-abs(HNDRd)).^2);
  % Trapezoidal integration of the amplitude response error
  intEAd = sum(diff(wa).*(EAd(1:(length(EAd)-1))+EAd(2:end))/2);

  % Heuristics for the barrier function
  lambda = 0.001;
  if (nD > 0)
    M = nD*R;
    t = 300;
    rho = 31/32;
    % Convert to state variable form
    DRrho=DR./(rho.^(0:(length(DR)-1))');
    [ADR,bDR,cDR,dDR] = tf2Abcd(1,DRrho);
    % Calculate barrier function
    f = zeros(M,1);
    cADR_t = cDR*(ADR^(t-1));
    for k=1:M
      f(k) = cADR_t*bDR;
      cADR_t = cADR_t*ADR;
    endfor
    f = real(f);
    EJ = sum(f.*f);
  else
    EJ = 0;
  endif
  % Done
  E = ((1-lambda)*intEAd) + (lambda*EJ);
endfunction
