function E=WISEJ_PAB(ab,_ma,_mb,_Ad,_Wa,_Td,_Wt,_Pd,_Wp)
% E=WISEJ_PAB(ab,ma,mb,Ad,Wa,Td,Wt)
% E=WISEJ_PAB(ab,ma,mb,Ad,Wa,Td,Wt,Pd,Wp)
% Objective function for minimising the response error of parallel
% allpass filters using the method of Tarczynski et al. The argument ab
% is the concatenation of the two allpass filter denominator polynomials
% to be optimised.
%
% First initialise the common parameters of the filter structure with:
%  WISEJ([],ma,mb,Ad,Wa,Td,Wt)
% The common filter parameters are:
%  ma - order of first allpass filter
%  mb - order of second allpass filter
%  Ad - desired filter amplitude response
%  Wa - filter amplitude response weighting factor
%  Td - desired filter group-delay response
%  Wt - filter group-delay response weighting factor
%  Pd - desired filter phase response
%  Wp - filter phase response weighting factor
%
% See "A WISE Method for Designing IIR Filters", A.Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

% Copyright (C) 2017-2023 Robert G. Jenssen
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
  
  persistent ma mb Ad Wa Td Wt Pd Wp
  persistent init_done=false

  if (nargin ~= 1) && (nargin ~= 7) && (nargin ~= 9)
    print_usage("E=WISEJ_PAB(ab[,ma,mb,Ad,Wa,Td,Wt,Pd,Wp])");
  endif
  if nargin>=7
    ma=_ma; mb=_mb; Ad=_Ad; Wa=_Wa; Td=_Td; Wt=_Wt; Pd=[]; Wp=[];
    if (length(Ad) ~= length(Wa))
      error("Expected length(Ad) == length(Wa)!");
    endif
    if (length(Ad) ~= length(Td))
      error("Expected length(Ad) == length(Td)!");
    endif 
    if (length(Td) ~= length(Wt))
      error("Expected length(Td) == length(Wt)!");
    endif
    if nargin == 7
      init_done=true;
    endif
  endif
  if nargin==9
    Pd=_Pd; Wp=_Wp;
    if (length(Ad) ~= length(Pd))
      error("Expected length(Ad) == length(Pd)!");
    endif 
    if (length(Pd) ~= length(Wp))
      error("Expected length(Pd) == length(Wp)!");
    endif
    init_done=true;
  endif
  if init_done==false
    error("init_done == false!");
  endif
  if isempty(ab)
    return;
  endif
  
  % Sanity checks
  if (length(ab) ~= (ma+mb))
    error("Expected length(ab) == (ma+mb)!");
  endif
  
  % Find the allpass denominator polynomials
  ab=ab(:);
  Da=[1;ab(1:ma)];
  Db=[1;ab((ma+1):end)];
  D=conv(Da,Db);
  N=(conv(flipud(Da),Db)-conv(flipud(Db),Da))/2;
  
  % Find the amplitude response error
  [H,wa]=freqz(N,D,length(Ad));
  EAd = Wa.*(abs(abs(H)-Ad).^2);

  % Find the group delay response error
  [T,wt]=delayz(N,D,length(Td));
  ETd = Wt.*(abs(T-Td).^2);

  % Find the phase response error
  if ~isempty(Pd)
    wp = wa;
    EPd = Wp.*(abs(unwrap(arg(H))-Pd).^2);
  endif

  % Trapezoidal integration of the weighted error
  intEd = (sum(diff(wa).*(EAd(1:(length(EAd)-1))+EAd(2:end))) + ...
           sum(diff(wt).*(ETd(1:(length(ETd)-1))+ETd(2:end))))/2;
  if ~isempty(Pd)
    intEd = intEd + (sum(diff(wp).*(EPd(1:(length(EPd)-1))+EPd(2:end)))/2);
  endif

  % Heuristics for the barrier function
  lambda = 0.001;
  if (ma+mb) > 0
    M = (ma+mb);
    t = 300;
    rho = 31/32;
    % Convert to state variable form
    Drho=D./(rho.^(0:(length(D)-1)))';
    Drho=Drho(:)'/Drho(1);
    nDrho=length(Drho);
    AD=[zeros(nDrho-2,1) eye(nDrho-2); -Drho(nDrho:-1:2)];
    bD=[zeros(nDrho-2,1);1];
    cD=-Drho(nDrho:-1:2);
    dD=1;
    % Calculate barrier function
    f = zeros(M,1);
    cAD_t = cD*(AD^(t-1));
    for k=1:M
      f(k) = cAD_t*bD;
      cAD_t = cAD_t*AD;
    endfor
    f = real(f);
    EJ = sum(f.*f);
  else
    EJ = 0;
  endif
  % Done
  E = ((1-lambda)*intEd) + (lambda*EJ);
endfunction
