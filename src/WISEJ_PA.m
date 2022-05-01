function E=WISEJ_PA(ab,_ma,_mb,_R,_poly,_Ad,_Wa,_Td,_Wt)
% E=WISEJ_PA(ab[,ma,mb,R,poly,w,Ad,Wa,Td,Wt])
% Objective function for minimising the response error of parallel
% allpass filters using the method of Tarczynski et al. See "A WISE
% Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

% Copyright (C) 2017-2022 Robert G. Jenssen
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

  persistent ma mb R polyphase Ad Wa Td Wt
  persistent init_done=false

  if (nargin ~= 1) && (nargin ~= 9)
    print_usage("E=WISEJ_PA(ab[,ma,mb,R,poly,Ad,Wa,Td,Wt])");
  endif
  if nargin==9
    ma=_ma; mb=_mb; R=_R; polyphase=_poly; Ad=_Ad; Wa=_Wa; Td=_Td; Wt=_Wt;
    init_done=true;
  endif
  if isempty(ab)
    return;
  endif
  if init_done==false
    error("init_done == false!");
  endif
  
  % Sanity checks
  if (length(ab) ~= (ma+mb))
    error("Expected length(ab) == (ma+mb)!");
  endif
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
  ab=ab(:);
  Da=[1;kron(ab(1:ma),[zeros(R-1,1);1])];
  Db=[1;kron(ab((ma+1):end),[zeros(R-1,1);1])];
  D=conv(Da,Db);
  
  % Find the amplitude response error
  [Ha_a,wa]=freqz(flipud(Da),Da,length(Ad));
  if any(find(isnan(Ha_a)))
    Ha_a(find(isnan(Ha_a))) = 0;
  endif
  [Ha_b,wa]=freqz(flipud(Db),Db,length(Ad));
  if any(find(isnan(Ha_b)))
    Ha_b(find(isnan(Ha_b))) = 0;
  endif
  if polyphase
    Ha=0.5*(Ha_a+(exp(-j*wa).*Ha_b));
  else
    Ha=0.5*(Ha_a+Ha_b);
  endif
  EAd = Wa.*abs((abs(Ha)-abs(Ad)).^2);

  % Find the group delay response error
  [Ta,wt]=grpdelay(flipud(Da),Da,length(Td));
  [Tb,wt]=grpdelay(flipud(Db),Db,length(Td));
  if polyphase
    T=0.5*(Ta+Tb+1);
  else
    T=0.5*(Ta+Tb);
  endif
  ETd = Wt.*((T-Td).^2);

  % Trapezoidal integration of the weighted error
  intEd = sum(diff(wa).*((EAd(1:(length(EAd)-1))+EAd(2:end))/2)) + ...
          sum(diff(wt).*((ETd(1:(length(ETd)-1))+ETd(2:end))/2));
  
  % Heuristics for the barrier function
  lambda = 0.001;
  if (ma+mb) > 0
    M = (ma+mb)*R;
    T = 300;
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

  if isnan(E)
    error("isnan(E)");
  endif
endfunction
