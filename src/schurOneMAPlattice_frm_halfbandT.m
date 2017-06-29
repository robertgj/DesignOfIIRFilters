function [T,gradT] = ...
         schurOneMAPlattice_frm_halfbandT(w,k,epsilon,p,u,v,Mmodel,Dmodel)
% [T,gradT] = ...
%   schurOneMAPlattice_frm_halfbandT(w,k,epsilon,p,u,v,Mmodel,Dmodel)
% Calculate the zero-phase delay response and gradients of the response
% with respect to the coefficients of an FRM half-band filter in
% which the model filter consists of a Schur one-multiplier lattice
% allpass filter in  parallel with a delay. The FIR masking filter is
% assumed to be odd length (ie: even order) and symmetric (ie: linear
% phase). (Mmodel*Dmodel)+1 and length(aa)-1 are assumed to be multiples
% of 4. The polyphase decomposition of the masking filter is
% U(z)+z^(-1)V(z) where U and V are symmetric FIR filters with unique
% coefficients u and v.
% 
% Inputs:
%   w - angular frequencies for response
%   k - allpass filter one-multiplier lattice filter coefficients
%   epsilon, p - one-multiplier lattice scaling coefficients
%   u,v - masking filter coefficients
%   Mmodel - decimation factor of the allpass model filter
%   Dmodel - delay of the pure delay branch of the model filter
%
% Outputs:
%   T - zero-phase group delay response at angular frequencies w
%   gradT - gradient of T at w

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

  %
  % Sanity checks
  %
  if (nargin != 8) || (nargout > 2)
    print_usage("[T,gradT]= ...\n\
  schurOneMAPlattice_frm_halfbandT(w,k,epsilon,p,u,v,Mmodel,Dmodel);");
  endif
  if length(u) ~= (length(v)+1)
    error("length(u) ~= (length(v)+1)");
  endif
  dmask=2*length(v);
  if mod(dmask,2)
    error("dmask must be a multiple of 2");
  endif
  if mod((Mmodel*Dmodel)+1,4)
    error("(Mmodel*Dmodel)+1 must be a multiple of 4");
  endif
  if (length(k) ~= length(epsilon)) || (length(k) ~= length(p))
    error("Expected length(k) == length(epsilon) == length(p)");
  endif
  
  % Do nothing
  if nargout == 0
    return;
  endif
  if isempty(w)
    T=[];
    gradT=[]; 
    return;
  endif;
  
  %
  % Initialise
  %
  nk=length(k);
  nu=length(u);
  nv=length(v);
  u=u(:);
  v=v(:);
  w=w(:);
  nw=length(w);
  
  %
  % FRM filter zero-phase delay response
  %

  % Model filter allpass branch phase response
  if nargout == 1
    Pr=schurOneMAPlatticeP(w,k,epsilon,p,2*Mmodel);
  else 
    [Pr,gradPr]=schurOneMAPlatticeP(w,k,epsilon,p,2*Mmodel);
  endif

  % Zero-phase model filter phase response with frequency
  PzM=(Mmodel*Dmodel*w)+Pr;
  
  % FIR masking filter amplitude response
  kd=dmask:(-2):2;
  kd1=kd-1;
  kdw=kron(kd,w);
  kd1w=kron(kd1,w);
  cu=[2*cos(kdw), ones(nw,1)]; 
  cv=2*cos(kd1w);
  Au=-0.5+(cu*u);
  Bv= 0.5+(cv*v);
  cosPzM=cos(PzM);
  sinPzM=sin(PzM);
  Au2=Au.*Au;
  BvcosPzM=Bv.*cosPzM;
  AuBvcosPzM=Au.*BvcosPzM;

  % Model filter allpass branch delay response
  if nargout == 1
    Tr=schurOneMAPlatticeT(w,k,epsilon,p,2*Mmodel);
  else
    [Tr,gradTr]=schurOneMAPlatticeT(w,k,epsilon,p,2*Mmodel);
  endif
   
  % Gradient of zero-phase model filter phase response with frequency
  delPzMdelw=(Mmodel*Dmodel)-Tr;
  
  % Gradient of FIR masking filter amplitude responses with frequency
  su=[-2*kron(kd,ones(nw,1)).*sin(kdw), zeros(nw,1)];
  sv=-2*kron(kd1,ones(nw,1)).*sin(kd1w);
  delAudelw=su*u;
  delBvdelw=sv*v;
  
  % Overall FRM filter squared magnitude response
  if nargout == 1
    Asq=...
      schurOneMAPlattice_frm_halfbandAsq(w,k,epsilon,p,u,v,Mmodel,Dmodel);
  else 
    [Asq,gradAsq]= ...
      schurOneMAPlattice_frm_halfbandAsq(w,k,epsilon,p,u,v,Mmodel,Dmodel);
  endif
  
  % Combined delay response
  AuBv_bracket=((Bv.*delAudelw) - (Au.*delBvdelw));
  T=-(((Au2+AuBvcosPzM).*delPzMdelw) + (sinPzM.*AuBv_bracket))./Asq;
  if nargout == 1
    return;
  endif

  % T gradients
  AucosPzM=Au.*cosPzM;
  BvsinPzM=Bv.*sinPzM;
  AuBvsinPzM=Au.*BvsinPzM;
  delAudelu=cu;
  delBvdelv=cv;
  del2Audeludelw=su;
  del2Bvdelvdelw=sv;

  delTdelr= (kron(Au2+AuBvcosPzM,ones(1,nk)).*gradTr) ...
           +(kron((AuBvsinPzM.*delPzMdelw),ones(1,nk)).*gradPr) ...
           -(kron(cosPzM.*AuBv_bracket,ones(1,nk)).*gradPr);

  delTdelu=-(kron(((2*Au)+(BvcosPzM)).*delPzMdelw,ones(1,nu)).*delAudelu) ...
           -(kron(BvsinPzM,ones(1,nu)).*del2Audeludelw) ...
           +(kron(sinPzM.*delBvdelw,ones(1,nu)).*delAudelu);

  delTdelv=-(kron(AucosPzM.*delPzMdelw,ones(1,nv)).*delBvdelv) ...
           -(kron(sinPzM.*delAudelw,ones(1,nv)).*delBvdelv) ...
           +(kron(sinPzM.*Au,ones(1,nv)).*del2Bvdelvdelw);

  gradT=[delTdelr,delTdelu,delTdelv];
  gradT=(gradT-(gradAsq.*kron(T,ones(1,nk+nu+nv))))./kron(Asq,ones(1,nk+nu+nv));
  
endfunction  
