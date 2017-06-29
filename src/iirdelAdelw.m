function [delAdelw,graddelAdelw]=iirdelAdelw(w,x,U,V,M,Q,tol)
% [delAdelw,graddelAdelw]=iirdelAdel(w,x,U,V,M,Q,tol)
% Given the U real zeros, V real poles, M conjugate zeros and 
% Q conjugate poles of an IIR filter find the gradient of the
% magnitude response with frequency, delAdelw, and the gradients
% with respect to the coefficients at the angular frequencies w.
% x is the vector [K R0 Rp r0 theta0 rp thetap] of coefficients
% of the filter. K is a gain factor. R0 is a vector of U real
% zero radiuses, Rp is a vector of V real pole radiuses. r0 is a
% vector of M/2 zero radiuses and theta0 is a vector of M/2 zero
% angles that together define M/2 conjugate pairs of zeros. 
% Likewise, rp is a vector of Q/2 pole radiuses and thetap is a 
% vector of Q/2 pole angles that together define Q/2 conjugate 
% pairs of poles. The tol argument allows for errors in the complex 
% number calculations required if the real or complex poles have 
% radius less than zero.
%
% Inputs:
%   w - vector of angular frequencies
%   x - coefficient vector 
%       [k; 
%        zR(1:U); 
%        pR(1:V); 
%        abs(z(1:Mon2)); angle(z(1:Mon2)); 
%        abs(p(1:Qon2)); angle(p(1:Qon2))];
%       where k is the gain coefficient, zR and pR represent real
%       zeros and poles and z and p represent conjugate zero and pole
%       pairs. 
%   U - number of real zeros
%   V - number of real poles
%   M - number of conjugate zero pairs
%   Q - number of conjugate pole pairs
%   tol - tolerance for maximum imaginary component of a real value
%
% Outputs:
%   A - gradient of the amplitude with frequency at angular frequencies, w
%   gradA - gradient of the gradient of the amplitude response with frequency
%           with respect to x at angular frequencies w,
%
% !!! NOTE WELL !!! :
%
%   1. For multiple frequencies results are returned with
%      frequency varying in dimension 1.
%
%   2. The gradients are with respect to the filter coefficients, 
%      NOT the frequency.
%
%   3. This function calls iirA() and assumes that R=1 (ie: no decimation of
%      the denominator polynomial).
%
%   4. NaN is quietly set to 0

% Copyright (C) 2017 Robert G. Jenssen
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

  % Sanity checks
  if nargin<6 || nargout>2
    print_usage ("[delAdelw,graddelAdelw]=iirdelAdelw(w,x,U,V,M,Q,tol)");
  endif
  if nargin == 6
    tol=1e-9;
  endif
  if length(x) ~= 1+U+V+Q+M
    error ("Expect length(x) == 1+U+V+Q+M");
  endif
  if rem(M,2)
    error ("Expected an even number of conjugate zeros");
  endif
  if rem(Q,2)
    error ("Expected an even number of conjugate poles");
  endif

  % Allow empty frequency vector
  if isempty(w)
    delAdelw=[]; graddelAdelw=[]; return;
  endif
  % For K==0
  if x(1)==0
    delAdelw=zeros(length(w),1);
    graddelAdelw=zeros(length(w),length(x));
    return;
  endif

  % Constants
  w=w(:);
  Nw=length(w);
  Mon2=M/2;
  Qon2=Q/2;
  UV=U+V;
  UVMon2=UV+Mon2;
  UVM=UV+M;
  UVMQon2=UVM+Qon2;
  UVMQ=UVM+Q;

  % Extract coefficients from x
  K=x(1);
  R0=x((1+1):(1+U));
  R0=R0(:)';
  Rp=x((1+U+1):(1+UV));
  Rp=Rp(:)';
  r0=x((1+UV+1):(1+UVMon2));
  r0=r0(:)';
  theta0=x((1+UVMon2+1):(1+UVM));
  theta0=theta0(:)';
  rp=x((1+UVM+1):(1+UVMQon2));
  rp=rp(:)';
  thetap=x((1+UVMQon2+1):(1+UVMQ));
  thetap=thetap(:)';

  % Sanity checks on x
  if (max(abs(imag(x))) > tol)
    error("Complex coefficient > tol found in x!");
  endif
  if (iscomplex(x) && (max(abs(imag(x))) <= tol))
    warning("Complex coefficient <= tol found in x! Taking real parts!");
    x=real(x);
  endif

  %
  % delAdelw
  %

  % Magnitude response and gradients of A
  [A,gradA]=iirA(w,x,U,V,M,Q,1,tol);

  % Real zeros
  kwR0=kron(w,ones(1,U));
  kcoswR0=kron(cos(w),ones(1,U));
  ksinwR0=kron(sin(w),ones(1,U));
  kR0=kron(ones(Nw,1),R0);
  kR02=kron(ones(Nw,1),R0.^2);
  numAR0=kR0.*ksinwR0;
  denomAR0=1-(2*kR0.*kcoswR0)+kR02;
  if any(any(denomAR0 == 0))
    error("denomAR0 has zero entry");
  endif

  % Real poles
  kRp=kron(ones(Nw,1),Rp);
  kRp2=kron(ones(Nw,1),Rp.^2);
  kcoswRp=kron(cos(w),ones(1,V));
  ksinwRp=kron(sin(w),ones(1,V));
  numARp=kRp.*ksinwRp;
  denomARp=1-(2*kRp.*kcoswRp)+kRp2;
  if any(any(denomARp == 0))
    error("denomARp has zero entry");
  endif

  % Conjugate zeros
  kr0=kron(ones(Nw,1),r0);
  kr02=kron(ones(Nw,1),r0.^2);
  ktheta0=kron(ones(Nw,1),theta0);
  kwr0=kron(w,ones(1,Mon2));
  kcoswr0Ptheta0=cos(kwr0+ktheta0);
  kcoswr0Mtheta0=cos(kwr0-ktheta0);
  ksinwr0Ptheta0=sin(kwr0+ktheta0);
  ksinwr0Mtheta0=sin(kwr0-ktheta0);
  numAr0Ptheta0=kr0.*ksinwr0Ptheta0;
  numAr0Mtheta0=kr0.*ksinwr0Mtheta0;
  denomAr0Ptheta0=1-(2*kr0.*kcoswr0Ptheta0)+kr02;
  if any(any(denomAr0Ptheta0 == 0))
    error("denomAr0Ptheta0 has zero entry");
  endif
  denomAr0Mtheta0=1-(2*kr0.*kcoswr0Mtheta0)+kr02;
  if any(any(denomAr0Mtheta0 == 0))
    error("denomAr0Mtheta0 has zero entry");
  endif

  % Conjugate poles
  krp=kron(ones(Nw,1),rp);
  krp2=kron(ones(Nw,1),rp.^2);
  kwrp=kron(w,ones(1,Qon2));
  kthetap=kron(ones(Nw,1),thetap);
  kcoswrpPthetap=cos(kwrp+kthetap);
  kcoswrpMthetap=cos(kwrp-kthetap);
  ksinwrpPthetap=sin(kwrp+kthetap);
  ksinwrpMthetap=sin(kwrp-kthetap);
  numArpPthetap=krp.*ksinwrpPthetap;
  numArpMthetap=krp.*ksinwrpMthetap;
  denomArpPthetap=1-(2*krp.*kcoswrpPthetap)+krp2;
  if any(any(denomArpPthetap == 0))
    error("denomArpPthetap has zero entry");
  endif
  denomArpMthetap=1-(2*krp.*kcoswrpMthetap)+krp2;
  if any(any(denomArpMthetap == 0))
    error("denomArpMthetap has zero entry");
  endif

  % delAdelw
  delAdelw=A.*( sum(numAR0./denomAR0,2) ...
                -sum(numARp./denomARp,2) ...
                +sum(numAr0Ptheta0./denomAr0Ptheta0,2) ...
                +sum(numAr0Mtheta0./denomAr0Mtheta0,2) ...
                -sum(numArpPthetap./denomArpPthetap,2) ...
                -sum(numArpMthetap./denomArpMthetap,2));
  
  % Sanity checks on delAdelw
  delAdelw=fixResultNaN(delAdelw);
  if any(isinf(delAdelw))
    error("delAdelw has inf!");
  endif
  if nargout==1
    return;
  endif

  %
  % Gradient of delAdelw with coefficients
  %

  % For real zeros
  numAR0delR0=(ones(Nw,U)-(kR0.^2)).*ksinwR0;
  denomAR0delR0=denomAR0.^2;
  del2AdelwdelR0=numAR0delR0./denomAR0delR0;

  % For real poles
  numARpdelRp=(ones(Nw,V)-(kRp.^2)).*ksinwRp;
  denomARpdelRp=denomARp.^2;
  del2AdelwdelRp=-numARpdelRp./denomARpdelRp;

  % For conjugate zero radiuses
  numAr0Ptheta0delr0=(ones(Nw,Mon2)-(kr0.^2)).*ksinwr0Ptheta0;
  numAr0Mtheta0delr0=(ones(Nw,Mon2)-(kr0.^2)).*ksinwr0Mtheta0;
  denomAr0Ptheta0delx=denomAr0Ptheta0.^2;
  denomAr0Mtheta0delx=denomAr0Mtheta0.^2;
  del2Adelwdelr0=(numAr0Ptheta0delr0./denomAr0Ptheta0delx) ...
                 +(numAr0Mtheta0delr0./denomAr0Mtheta0delx);

  % For conjugate zero angles
  numAr0Ptheta0deltheta0=(kr0.*(ones(Nw,Mon2)+kr02).*kcoswr0Ptheta0) - (2*kr02);
  numAr0Mtheta0deltheta0=(kr0.*(ones(Nw,Mon2)+kr02).*kcoswr0Mtheta0) - (2*kr02);
  del2Adelwdeltheta0=(numAr0Ptheta0deltheta0./denomAr0Ptheta0delx) ...
                     -(numAr0Mtheta0deltheta0./denomAr0Mtheta0delx);

  % For conjugate pole radiuses
  numArpPthetapdelrp=(ones(Nw,Qon2)-(krp.^2)).*ksinwrpPthetap;
  numArpMthetapdelrp=(ones(Nw,Qon2)-(krp.^2)).*ksinwrpMthetap;
  denomArpPthetapdelx=denomArpPthetap.^2;
  denomArpMthetapdelx=denomArpMthetap.^2;
  del2Adelwdelrp=-(numArpPthetapdelrp./denomArpPthetapdelx) ...
                 -(numArpMthetapdelrp./denomArpMthetapdelx);

  % For conjugate pole angles
  numArpPthetapdelthetap=(krp.*(ones(Nw,Qon2)+krp2).*kcoswrpPthetap) - (2*krp2);
  numArpMthetapdelthetap=(krp.*(ones(Nw,Qon2)+krp2).*kcoswrpMthetap) - (2*krp2);
  del2Adelwdelthetap=-(numArpPthetapdelthetap./denomArpPthetapdelx) ...
                     +(numArpMthetapdelthetap./denomArpMthetapdelx);

  % Make graddelAdelw
  graddelAdelw=[zeros(Nw,1), ...
                del2AdelwdelR0, ...
                del2AdelwdelRp, ...
                del2Adelwdelr0, ...
                del2Adelwdeltheta0, ...
                del2Adelwdelrp, ...
                del2Adelwdelthetap];
  graddelAdelw=(kron(A,ones(1,length(x))).*graddelAdelw) ...
               +(kron(delAdelw./A,ones(1,length(x))).*gradA);

  % Sanity checks on graddelAdelw
  graddelAdelw=fixResultNaN(graddelAdelw);
  if any(any(isinf(graddelAdelw)))
    error("graddelAdelw has inf!");
  endif

endfunction
