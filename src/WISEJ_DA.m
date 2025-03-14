function E=WISEJ_DA(a,_R,_D,_poly,_Ad,_Wa,_Td,_Wt)
% E=WISEJ_DA(a[,R,D,poly,w,Ad,Wa,Td,Wt])
% Objective function for minimising the response error of the parallel
% combination of an allpass filter and a pure delay using the method of
% Tarczynski et al. See "A WISE Method for Designing IIR Filters",
% A. Tarczynski et al., IEEE Transactions on Signal Processing,
% Vol. 49, No. 7, pp. 1421-1432
%
% The filter transfer function is:
%   H(z)=(z^(-D)+a(z))/2
%
% For the polyphase combination:
%   H(z)=(z^(-D*R)+z^(-1)*a(z^R))/2

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
  
  persistent R D polyphase Ad Wa Td Wt
  persistent init_done=false

  if (nargin ~= 1) && (nargin ~= 8)
    print_usage("E=WISEJ_DA(a[,R,D,poly,Ad,Wa,Td,Wt])");
  endif
  if nargin==8
    R=_R; D=_D; polyphase=_poly; Ad=_Ad; Wa=_Wa; Td=_Td; Wt=_Wt;
    init_done=true;
  endif
  if isempty(a)
    return;
  endif
  if init_done==false
    error("init_done == false!");
  endif
  
  % Sanity checks
  if (polyphase == true) && (R > 2)
    error("Expected ((polyphase == true) && (R <= 2))!");
  endif
  if (length(Ad) ~= length(Wa))
    error("Expected length(Ad) == length(Wa)!");
  endif 
  if (length(Td) ~= length(Wt))
    error("Expected length(Td) == length(Wt)!");
  endif
  
  % Find the allpass denominator polynomials
  a=a(:);
  if R>1
    DaR=[1;kron(a,[zeros(R-1,1);1])];
  else
    DaR=[1;a];
  endif
  
  % Find the error response in the passband
  [Ha_aR,wa]=freqz(flipud(DaR),DaR,length(Ad));
  if polyphase
    Ha=0.5*(exp(-j*D*R*wa)+(exp(-j*wa).*Ha_aR));
  else
    Ha=0.5*(exp(-j*D*R*wa)+Ha_aR);
  endif
  EAd = Wa.*abs((abs(Ha)-abs(Ad)).^2);

  % Find the group delay error response
  [Ta_aR,wt]=delayz(flipud(DaR),DaR,length(Td));
  if polyphase
    T=0.5*((D*R)+Ta_aR+1);
  else
    T=0.5*((D*R)+Ta_aR);
  endif
  ETd = Wt.*((T-Td).^2);

  % Trapezoidal integration of the weighted error
  intEd = sum(diff(wa).*((EAd(1:(length(EAd)-1))+EAd(2:end))/2)) + ...
          sum(diff(wt).*((ETd(1:(length(ETd)-1))+ETd(2:end))/2));
  
  % Heuristics for the barrier function
  lambda = 0.001;
  if (D+length(a)) > 0
    M = (D+length(a))*R;
    T = 300;
    rho = 31/32;
    % Convert to state variable form
    Drho=DaR./(rho.^(0:(length(DaR)-1)))';
    Drho=Drho(:)'/Drho(1);
    nDrho=length(Drho);
    AD=[zeros(nDrho-2,1) eye(nDrho-2); -Drho(nDrho:-1:2)];
    bD=[zeros(nDrho-2,1);1];
    cD=-Drho(nDrho:-1:2);
    dD=1;
    % Calculate barrier function
    f = zeros(M,1);
    cAD_Tk = cD*(AD^(T-1));
    for k=1:M
      f(k) = cAD_Tk*bD;
      cAD_Tk = cAD_Tk*AD;
    endfor
    f = real(f);
    EJ = sum(f.*f);
  else
    EJ = 0;
  endif
  % Done
  E = ((1-lambda)*intEd) + (lambda*EJ);
endfunction
