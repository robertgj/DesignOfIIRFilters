function E=WISEJ_OneM(kc,_ki,_ci,_k_max,_k_active,_c_active, ...
                      _wa,_Asqd,_Wa,_wt,_Td,_Wt)

% E=WISEJ_OneM(kc,ki,ci,k_max,k_active,c_active,wa,Asqd,Wa,wt,Td,Wt)
% Objective function for minimising the response error of a tapped Schur 
% lattice filter using the method of Tarczynski et al. See "A WISE
% Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432
% The argument kc is the concatenation of the allpass filter reflection
% coefficients tap coefficients to be optimised.
%
% First initialise the common parameters of the filter structure with:
%  WISEJ_OneM([],ki,ci,k_max,k_active,c_active,wa,Asqd,Wa,wt,Td,Wt)
% The common filter parameters are:
%  ki - initial all-pass reflection coefficients
%  ci - initial tap coefficients
%  k_max - upper limit on reflection coefficient magnitude
%  k_active - indexes of reflection coefficients to be optimised
%  c_active - indexes of tap coefficients to be optimised
%  wa - angular frequencies of the desired squared-amplitude response
%  Asqd - desired filter squared-amplitude response
%  Wa - filter squared-amplitude response weighting factor
%  wt - angular frequencies of the desired group-delay response
%  Td - desired filter group-delay response
%  Wt - filter group-delay response weighting factor

% Copyright (C) 2025 Robert G. Jenssen
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
  persistent ki ci k_max k_active c_active wa Asqd Wa wt Td Wt iter
  persistent init_done=false

  if nargin==12
    ki=_ki;ci=_ci;
    k_max=_k_max;k_active=_k_active;c_active=_c_active;
    wa=_wa;Asqd=_Asqd;Wa=_Wa;wt=_wt;Td=_Td;Wt=_Wt;
    iter=0;
    init_done=true;
    return;
  elseif nargin ~= 1
    print_usage(["E=WISEJ_OneM(kc) \n", ...
 "WISEJ_OneM(kc,ki,ci,k_active,c_active,wa,Asqd,Wa,wt,Td,Wt)"]);
  endif
  if init_done==false
    error("init_done == false!");
  endif
  if length(kc) ~= (length(ki)+length(ci))
    error("length(kc)(%d) ~= (length(ki)(%d)+length(ci)(%d))", ...
          length(kc),length(ki),length(ci));
  endif

  % Find the response
  k=ki;
  k(k_active)=kc(k_active);
  if any(abs(k)>k_max)
    E=100;
    return;
  endif
  c=ci;
  c(c_active)=kc(length(ki)+c_active);

  % Find the amplitude response error
  Asq=schurOneMlatticeAsq(wa,k,ones(size(k)),ones(size(k)),c);
  EAsq = Wa.*((Asq-Asqd).^2);

  % Trapezoidal integration of the weighted error
  intE = sum(diff(wa).*((EAsq(1:(length(EAsq)-1))+EAsq(2:end))/2));
 
  % Find the delay response error
  if length(wt)>1
    t=schurOneMlatticeT(wt,k,ones(size(k)),ones(size(k)),c);
    Et = Wt.*((t-Td).^2);
    intE = intE + sum(diff(wt).*((Et(1:(length(Et)-1))+Et(2:end))/2));
  endif
    
  % Heuristics for the barrier function
  [N,D]=schurOneMlattice2tf(k,ones(size(k)),ones(size(k)),c);
  lambda = 0.01;
  if (length(D)) > 0
    M =30;
    T = 300;
    rho = 255/256;
    % Convert D to state variable form
    Drho=D./(rho.^(0:(length(D)-1))');
    Drho=Drho(:)'/Drho(1);
    nDrho=length(Drho);
    A=[zeros(nDrho-2,1) eye(nDrho-2); -Drho(nDrho:-1:2)];
    B=[zeros(nDrho-2,1);1];
    C=-Drho(nDrho:-1:2);
    % Calculate barrier function
    f = zeros(M,1);
    CA_Tm = C*(A^(T-1));
    for m=1:M
      f(m) = CA_Tm*B;
      CA_Tm = CA_Tm*A;
    endfor
    f = real(f);
    EJ = sum(f.*f);
  else
    EJ = 0;
  endif
  % Done
  E = ((1-lambda)*intE) + (lambda*EJ);
  % Echo
  iter = iter+1;
endfunction
