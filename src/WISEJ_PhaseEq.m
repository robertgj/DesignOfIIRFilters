function E=WISEJ_PhaseEq(a,_Va,_Qa,_Ra,_x,_Ux,_Vx,_Mx,_Qx,_Rx,_w,_tp)
% E=WISEJ_PhaseEq(a,Va,Qa,Ra,x,Ux,Vx,Mx,Qx,Rx,w,tp)
% Objective function for equalising the group delay of the response
% of an IIR filter with gain, zeros and poles given by x, Ux, Vx, Mx,
% Qx, Rx, and nominal group delay, tp, over angular frequencies, w, using
% the method of Tarczynski et al. See "A WISE Method for Designing IIR
% Filters", A. Tarczynski et al., IEEE Transactions on Signal Processing,
% Vol. 49, No. 7, pp. 1421-1432

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

  persistent Va Qa Ra x Ux Vx Mx Qx Rx w tp
  persistent Px init_done=false

  if (nargin ~= 1) && (nargin ~= 12)
    print_usage("E=WISEJ_PhaseEq(a[,Va,Qa,Ra,x,Ux,Vx,Mx,Qx,Rx,w,tp])");
  elseif nargin==12
    Va=_Va;Qa=_Qa;Ra=_Ra;
    x=_x;Ux=_Ux;Vx=_Vx;Mx=_Mx;Qx=_Qx;Rx=_Rx;
    w=_w(:);tp=_tp;
    Px=iirP(w,x,Ux,Vx,Mx,Qx,Rx);
    init_done=true;
     return;
  elseif ~init_done
    error("~init_done");    
  endif

  % Calculate phase or group delay error
  Pa=allpassP(w,a,Va,Qa,Ra);
  E=(Pa+Px+(tp*w)).^2;
  intE=sum(diff(w).*(E(1:(end-1))+E(2:end)))/2;
  
  % Heuristics for the barrier function
  [~,Da]=a2tf(a,Va,Qa,Ra);
  Da=Da(:)';
  nDa=length(Da)-1;
  lambda = 0.001;
  T = 300;
  rho = 31/32;
  % Calculate barrier function state-variable filter
  Drho=Da./(rho.^(0:nDa));
  Drho=Drho/Drho(1);
  nDrho=length(Drho);
  AD=[zeros(nDrho-2,1) eye(nDrho-2); -Drho(nDrho:-1:2)];
  bD=[zeros(nDrho-2,1);1];
  cD=-Drho(nDrho:-1:2);
  dD=1;
  % Calculate barrier function error
  f = zeros(nDa,1);
  cAD_Tk = cD*(AD^(T-1));
  for k=1:nDa
    f(k) = cAD_Tk*bD;
    cAD_Tk = cAD_Tk*AD;
  endfor
  f = real(f);
  EJ = sum(f.*f);

  % Return error
  E=((1-lambda)*intE)+(lambda*EJ); 
endfunction
