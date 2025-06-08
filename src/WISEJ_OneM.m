function E=WISEJ_OneM(kc,_ki,_ci,_k_max,_k_active,_c_active, ...
                      _wa,_Asqd,_Wa,_wt,_Td,_Wt, ...
                      _wp,_Pd,_Wp,_wd,_Dd,_Wd)
% E=WISEJ_OneM(kc,ki,ci,k_max,k_active,c_active,wa,Asqd,Wa,wt,Td,Wt)
% Objective function for minimising the response error of a tapped Schur 
% lattice filter using the method of Tarczynski et al. 
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
%  wp - angular frequencies of the desired phase response
%  Pd - desired filter phase response
%  Wp - filter phase response weighting factor
%  wd - angular frequencies of the desired dAsqdw response
%  Dd - desired filter dAsqdw response
%  Wd - filter dAsqdw response weighting factor

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
  
  persistent ki ci k_max k_active c_active
  persistent wa Asqd Wa wt Td Wt wp Pd Wp wd Dd Wd
  persistent iter
  persistent init_done=false
  persistent verbose=false

  if (nargin ~= 1) && ...
     (nargin ~= 9) && (nargin ~= 12) && (nargin ~= 15) && (nargin ~= 18)
    print_usage ...
(["E=WISEJ_OneM(kc)\n", ...
  "WISEJ_OneM(kc,ki,ci,k_max,k_active,c_active,wa,Asqd,Wa)\n", ...
  "WISEJ_OneM(kc,ki,ci,k_max,k_active,c_active,wa,Asqd,Wa,wt,Td,Wt)\n", ...
  "WISEJ_OneM(kc,ki,ci,k_max,k_active,c_active,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp\n"]);
  endif

  if nargin >= 9
    ki=_ki;ci=_ci;k_max=_k_max;

    k_active=_k_active;c_active=_c_active;
    if any(k_active) > length(ki)
      error("any(k_active) > length(ki)");
    endif
    if any(c_active) > length(ci)
      error("any(c_active) > length(ci)");
    endif

    wa=_wa;Asqd=_Asqd;Wa=_Wa;
    wt=[];Td=[];Wt=[];wp=[];Pd=[];Wp=[];wd=[];Dd=[];Wd=[];
    if length(wa) ~= length(Asqd)
      error("length(wa)(%d) ~= (length(Asqd)(%d)",length(wa),length(Asqd));
    endif
    if length(Asqd) ~= length(Wa)
      error("length(Asqd)(%d) ~= (length(Wa)(%d)",length(Asqd),length(Wa));
    endif
    if nargin >= 12
      wt=_wt;Td=_Td;Wt=_Wt;
      if length(wt) ~= length(Td)
        error("length(wt)(%d) ~= (length(Td)(%d)",length(wt),length(Td));
      endif
      if length(Td) ~= length(Wt)
        error("length(Td)(%d) ~= (length(Wt)(%d)",length(Td),length(Wt));
      endif
    endif
    if nargin >= 15
      wp=_wp,Pd=_Pd;Wp=_Wp;
      if length(wp) ~= length(Pd)
        error("length(wp)(%d) ~= (length(Pd)(%d)",length(wp),length(Pd));
      endif
      if length(Pd) ~= length(Wp)
        error("length(Pd)(%d) ~= (length(Wp)(%d)",length(Pd),length(Wp));
      endif
    endif
    if nargin == 18
      wd=_wd;Dd=_Dd;Wd=_Wd;
      if length(wd) ~= length(Dd)
        error("length(wd)(%d) ~= (length(Dd)(%d)",length(wd),length(Dd));
      endif
      if length(Dd) ~= length(Wd)
        error("length(Dd)(%d) ~= (length(Wd)(%d)",length(Dd),length(Wd));
      endif
    endif
    iter=0;
    init_done=true;
    return;
  endif
  if init_done==false
    error("init_done == false!");
  endif
  if length(kc) ~= (length(k_active)+length(c_active))
    error("length(kc)(%d) ~= (length(k_active)(%d)+length(c_active)(%d))", ...
          length(kc),length(k_active),length(c_active));
  endif

  % Select the active coefficients
  k=zeros(1,length(ki));
  k(k_active)=kc(1:length(k_active));
  if any(abs(k)>k_max)
    E=100;
    return;
  endif
  c=zeros(1,length(ci));
  c(c_active)=kc((length(k_active)+1):(length(k_active)+length(c_active)));
  if verbose
    fprintf(stderr,"k=[ ");printf("%g ",k);printf(" ]\n");
    fprintf(stderr,"c=[ ");printf("%g ",c);printf(" ]\n");
  endif
  
  % Error
  Esq=schurOneMlatticeEsq(k,ones(size(k)),ones(size(k)),c, ...
                          wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

  % Heuristics for the barrier function
  [N,D]=schurOneMlattice2tf(k,ones(size(k)),ones(size(k)),c);
  lambda = 0.01;
  if (length(D)) > 0
    M =30;
    t = 300;
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
    CA_t = C*(A^(t-1));
    for m=1:M
      f(m) = CA_t*B;
      CA_t = CA_t*A;
    endfor
    f = real(f);
    EJ = sum(f.*f);
  else
    EJ = 0;
  endif
  % Done
  E = ((1-lambda)*Esq) + (lambda*EJ);
  % Echo
  iter = iter+1;
endfunction
