function [T,gradT,diagHessT]=allpassT(w,a,V,Q,R)
% [T,gradT,diagHessT]=allPassT(w,a,V,Q,R)
% Given the V real poles and Q conjugate poles of an allpass IIR
% filter with decimation R find the delay response, T, and gradients
% at angular frequencies w. a is the vector [Rp rp thetap] of
% coefficients of the filter. Rp is a vector of V real pole radiuses,
% rp is a vector of Q/2 complex pole radiuses and thetap is a vector
% of Q/2 complex pole angles. Each pole corresponds to a zero of the
% allpass filter so that x defines V real poles, V real zeros, Q
% complex poles and Q complex zeros.
%
% Inputs:
%   w - vector of angular frequencies
%   a - coefficient vector [Rp(1:V) abs(rp(1:Qon2)) angle(rp(1:Qon2))];
%   V - number of real poles
%   Q - number of conjugate pole pairs
%   R - decimation factor, pole-zero pairs are for z^R
%
% Outputs:
%   T - delay response at angular frequencies, w
%   gradT - gradient of delay response at angular frequencies, w,
%           with respect to x
%   diagHessT - diagonal of the Hessian of the group delay response
%               at angular frequencies, w, with respect to x
%
% !!! NOTE WELL !!! :
%
%   1. For multiple frequencies results are returned with
%      frequency varying in dimension 1.
%
%   2. The gradients are with respect to the filter coefficients, 
%      NOT the frequency.
%
% 
% References:
% [1] A.G.Deczky, "Synthesis of recusive digital filters using the
% minimum p-error criterion" IEEE Trans. Audio Electroacoust.,
% Vol. AU-20, pp. 257-263, October 1972
% [2] M.A.Richards, "Applications of Deczkys Program for Recursive
% Filter Design to the Design of Recursive Decimators" IEEE Trans.
% ASSP-30 No. 5, pp. 811-814, October 1982

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
  if nargin!=5 || nargout>3
    print_usage ("[T,gradT,diagHessT]=allpassT(w,a,V,Q,R)");
  endif
  if length(a) ~= V+Q
    error ("Expect length(a) == V+Q");
  endif
  if rem(Q,2)
    error ("Expected an even number of conjugate poles");
  endif

  % Sanity checks on a
  if iscomplex(a) != 0
    error("Complex coefficient found in a!");
  endif

  % Allow empty frequency vector
  if isempty(w)
    T=[]; gradT=[]; return;
  endif

  % Allow empty coefficient vector
  if isempty(a)
    T=zeros(size(w)); gradT=zeros(size(w)); return;
  endif

  % Constants
  w=w(:);
  Nw=length(w);
  Qon2=Q/2;
  VQon2=V+Qon2;

  % Extract coefficients from x
  Rp=a(1:V);
  Rp=Rp(:)';
  rp=a((V+1):(VQon2));
  rp=rp(:)';
  thetap=a((VQon2+1):end);
  thetap=thetap(:)';

  % In the following, the real pole coefficients are organised as NwxV,
  % and the conjugate pole polynomial coefficients are organised as
  % NwxQon2. Recall that w is a column vector and Rp, rp and thetap are
  % row vectors.

  %
  % Group delay
  %
  
  % Real poles
  if V == 0
    kTRp=[];
  else
    kRp=kron(ones(Nw,1),Rp);
    kRp2=kron(ones(Nw,1),Rp.^2);
    kRp2M1=kRp2-ones(Nw,V);
    kRp2P1=kRp2+ones(Nw,V);
    kRwV=kron(R*w,ones(1,V));
    kcosRwV=cos(kRwV);
    kRpcosRwV=kRp.*kcosRwV;
    kRp2P1McosRwV=kRp2P1-(2*kRpcosRwV);
    kTRp=kRp2M1./kRp2P1McosRwV;
  endif
  % Conjugate poles
  if Q == 0
    kTrp=[];
  else
    krp=kron(ones(Nw,1),rp);
    krpM1=krp-ones(Nw,Qon2);
    krp2=kron(ones(Nw,1),rp.^2);
    krp2M1=krp2-ones(Nw,Qon2);
    krp2P1=krp2+ones(Nw,Qon2);
    kthetap=kron(ones(Nw,1),thetap);
    kRwQon2=kron(R*w,ones(1,Qon2));
    kcosRwMthetap=cos(kRwQon2-kthetap);
    kcosRwPthetap=cos(kRwQon2+kthetap);
    krpcosRwMthetap=krp.*kcosRwMthetap;
    krpcosRwPthetap=krp.*kcosRwPthetap;
    krp2P1McosRwMthetap=(krp2P1-(2*krpcosRwMthetap));
    krp2P1McosRwPthetap=(krp2P1-(2*krpcosRwPthetap));
    kTrp=(krp2M1./krp2P1McosRwMthetap)+(krp2M1./krp2P1McosRwPthetap);
  endif
  T=-R*sum([kTRp, kTrp],2);
  if nargout==1
    return;
  endif

  %
  % Gradient of group delay
  %
  
  % Real poles
  if V == 0
    gradTRp=[];
  else
    gradTRp=((kRp2P1.*kcosRwV)-(2*kRp))./(kRp2P1McosRwV.^2);
  endif
  % Conjugate poles
  if Q == 0
    gradTrp=[];
    gradTthetap=[];
  else
    k2rp2P1McosRwMthetap=krp2P1McosRwMthetap.^2;
    k2rp2P1McosRwPthetap=krp2P1McosRwPthetap.^2;
    gradTrp=(((krp2P1.*kcosRwPthetap)-(2*krp))./(k2rp2P1McosRwPthetap)) + ...
            (((krp2P1.*kcosRwMthetap)-(2*krp))./(k2rp2P1McosRwMthetap));
    ksinRwMthetap=sin(kRwQon2-kthetap);
    ksinRwPthetap=sin(kRwQon2+kthetap);
    gradTthetap=((krp.*krp2M1.*ksinRwPthetap)./(k2rp2P1McosRwPthetap)) - ...
                ((krp.*krp2M1.*ksinRwMthetap)./(k2rp2P1McosRwMthetap));
  endif
  gradT=2*R*[gradTRp, gradTrp, gradTthetap];
  if nargout==2
    return;
  endif

  %
  % Diagonal of Hessian of group delay
  %

  % Real poles
  if V == 0
    diagHessTRp=[];
  else
    kRp3=kron(ones(Nw,1),Rp.^3);
    k2cosRwV=kcosRwV.^2;
    diagHessTRp=((kRp3.*kcosRwV)-(3*kRp2)+(3*kRpcosRwV)+ ...
                 (ones(Nw,V)-(2*k2cosRwV)))./(kRp2P1McosRwV.^3);
  endif
  % Conjugate poles
  if Q == 0
    diagHessTrp=[];
    diagHessTthetap=[];
  else
    krp3=kron(ones(Nw,1),rp.^3);
    k2cosRwPthetap=kcosRwPthetap.^2; 
    k2cosRwMthetap=kcosRwMthetap.^2;
    k2sinRwPthetap=ksinRwPthetap.^2;
    k2sinRwMthetap=ksinRwMthetap.^2;
    k3rp2P1McosRwMthetap=k2rp2P1McosRwMthetap.*krp2P1McosRwMthetap;
    k3rp2P1McosRwPthetap=k2rp2P1McosRwPthetap.*krp2P1McosRwPthetap;
    diagHessTrp= ...
      (((krp3.*kcosRwPthetap)-(3*krp2)+(3*krpcosRwPthetap)+ ...
        ones(Nw,Qon2)-(2*k2cosRwPthetap))./k3rp2P1McosRwPthetap) + ...
      (((krp3.*kcosRwMthetap)-(3*krp2)+(3*krpcosRwMthetap)+ ...
        ones(Nw,Qon2)-(2*k2cosRwMthetap))./k3rp2P1McosRwMthetap);
    diagHessTthetap= ...
      (((krp3.*krp2.*kcosRwPthetap)- ...
        (2*krp2.*krp2M1.*(ones(Nw,Qon2)+k2sinRwPthetap)) - ...
        krpcosRwPthetap)./k3rp2P1McosRwPthetap) + ...
      (((krp3.*krp2.*kcosRwMthetap)- ...
        (2*krp2.*krp2M1.*(ones(Nw,Qon2)+k2sinRwMthetap)) - ...
        krpcosRwMthetap)./k3rp2P1McosRwMthetap);
  endif
  diagHessT=2*R*[-2*diagHessTRp, -2*diagHessTrp, diagHessTthetap];
endfunction
