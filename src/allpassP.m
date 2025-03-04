function [P,gradP,diagHessP]=allpassP(w,a,V,Q,R)
% [P,gradP,diagHessP]=allPassP(w,a,V,Q,R)
% Given the V real poles and Q conjugate poles of an allpass IIR
% filter with decimation R find the phase response, P, and gradients
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
%   P - phase response at angular frequencies, w
%   gradP - gradient of phase response at angular frequencies, w,
%           with respect to x
%   diagHessP - diagonal of the Hessian of the phase response at angular
%               frequencies, w, with respect to x
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

  % Sanity checks
  if nargin~=5 || nargout>3
    print_usage ("[P,gradP,diagHessP]=allpassP(w,a,V,Q,R)");
  endif
  if length(a) ~= V+Q
    error ("Expect length(a) == V+Q");
  endif
  if rem(Q,2)
    error ("Expected an even number of conjugate poles");
  endif

  % Sanity checks on a
  if iscomplex(a) ~= 0
    error("Complex coefficient found in a!");
  endif

  % Allow empty frequency vector
  if isempty(w)
    P=[]; gradP=[]; return;
  endif

  % Allow empty coefficient vector
  if isempty(a)
    P=zeros(size(w)); gradP=zeros(size(w)); diagHessP=zeros(size(w)); return;
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

  % Phase

  % Real poles
  kPRp=[];
  if V > 0
    kRp=kron(ones(Nw,1),Rp);
    kRwV=kron(R*w,ones(1,V));
    ksinRwV=sin(kRwV);
    kcosRwV=cos(kRwV);
    kPRp=-atan2(kRp.*ksinRwV,ones(Nw,V)-(kRp.*kcosRwV)) ...
	 -atan2(ksinRwV,kcosRwV-kRp);
  endif

  % Conjugate poles
  kPrp=[];
  if Q > 0
    krp=kron(ones(Nw,1),rp);
    kthetap=kron(ones(Nw,1),thetap);
    kRwQon2=kron(R*w,ones(1,Qon2));
    ksinRwQon2=sin(kRwQon2);
    kcosRwQon2=cos(kRwQon2);
    ksinthetap=sin(kthetap);
    kcosthetap=cos(kthetap);
    ksinRwPthetap=sin(kRwQon2+kthetap);
    ksinRwMthetap=sin(kRwQon2-kthetap);
    kcosRwPthetap=cos(kRwQon2+kthetap);
    kcosRwMthetap=cos(kRwQon2-kthetap);
    kPrp=-atan2(krp.*ksinRwPthetap,ones(Nw,Qon2)-(krp.*kcosRwPthetap)) ...
	 -atan2(ksinRwQon2+(krp.*ksinthetap),kcosRwQon2-(krp.*kcosthetap)) ...
	 -atan2(krp.*ksinRwMthetap,ones(Nw,Qon2)-(krp.*kcosRwMthetap)) ...
	 -atan2(ksinRwQon2-(krp.*ksinthetap),kcosRwQon2-(krp.*kcosthetap));
  endif

  P=unwrap(sum([kPRp kPrp],2));
  if nargout==1
    return;
  endif

  %
  % Gradient of phase
  %
  gradP=zeros(Nw,V+Q);
  % Real poles
  if V > 0
    denRp=((kRp.^2)-(2*kRp.*kcosRwV)+ones(Nw,V));
    gradPRp=(-2*ksinRwV)./denRp;
    gradP(:,1:V)=gradPRp;
  endif

  % Conjugate poles
  if Q > 0
    % Conjugate pole radius
    krp2=krp.^2;
    denrpM=krp2-(2*krp.*kcosRwMthetap)+ones(Nw,Qon2);
    denrpP=krp2-(2*krp.*kcosRwPthetap)+ones(Nw,Qon2);
    gradP(:,(V+1):VQon2)=((-2*ksinRwMthetap)./denrpM)+ ...
                         ((-2*ksinRwPthetap)./denrpP);

    % Conjugate pole angle
    numthetapM=2*(krp2-(krp.*kcosRwMthetap));
    numthetapP=2*(krp2-(krp.*kcosRwPthetap));
    gradP(:,(VQon2+1):end)=-(numthetapM./denrpM)+(numthetapP./denrpP);
  endif
  if nargout==2
    return;
  endif

  %
  % Diagonal of Hessian of phase
  %
  diagHessP=zeros(Nw,V+Q);
  % Real poles
  if V > 0
    diagHessP(:,1:V)=-2*gradPRp.*(kRp-kcosRwV)./denRp;
  endif

  % Conjugate poles
  if Q > 0
    % Conjugate pole radius
    diagHessP(:,(V+1):VQon2)= ...
      (4*ksinRwMthetap.*(krp-kcosRwMthetap)./(denrpM.^2)) + ...
      (4*ksinRwPthetap.*(krp-kcosRwPthetap)./(denrpP.^2));
    % Conjugate pole angle
    diagHessP(:,(VQon2+1):end)= ...
      ( 2*krp.*ksinRwMthetap./denrpM) + ...
      (-2*numthetapM.*krp.*ksinRwMthetap./(denrpM.^2)) + ...
      ( 2*krp.*ksinRwPthetap./denrpP) + ...
      (-2*numthetapP.*krp.*ksinRwPthetap./(denrpP.^2));
  endif
  
endfunction
