function [Asq,gradAsq] = ...
         schurOneMAPlattice_frm_halfbandAsq(w,k,epsilon,p,u,v,Mmodel,Dmodel)
% [Asq,gradAsq] = ...
%   schurOneMAPlattice_frm_halfbandAsq(w,k,epsilon,p,u,v,Mmodel,Dmodel)
% Calculate the zero-phase squared-amplitude response and
% gradients of the response with respect to the coefficients of an FRM
% half-band filter in which the model filter consists of a Schur
% one-multiplier lattice allpass filter in  parallel with a delay. The FIR
% masking filter is assumed to be odd length (ie: even order) and symmetric
% (linear phase). (Mmodel*Dmodel)+1 and length(aa)-1 are assumed to be
% multiples of 4. The polyphase decomposition of the masking filter is
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
%   Asq - zero-phase squared-amplitude response at angular frequencies w
%   gradAsq - gradient of Asq at w

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
    print_usage("[Asq,gradAsq]= ...\n\
  schurOneMAPlattice_frm_halfbandAsq(w,k,epsilon,p,u,v,Mmodel,Dmodel);");
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
    Asq=[];
    gradAsq=[]; 
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
  % FRM filter squared-amplitude response
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
   
  % Combined squared magnitude response
  cosPzM=cos(PzM);
  Au2=Au.*Au;
  Bv2=Bv.*Bv;
  BvcosPzM=Bv.*cosPzM;
  AuBvcosPzM=Au.*BvcosPzM;
  Asq=Au2+Bv2+(2*AuBvcosPzM);
  if nargout == 1
    return;
  endif

  % Asq gradients
  AucosPzM=Au.*cosPzM;
  sinPzM=sin(PzM);
  BvsinPzM=Bv.*sinPzM;
  AuBvsinPzM=Au.*BvsinPzM;
  delAudelu=cu;
  delBvdelv=cv;
  delAsqdelr=-2*kron(AuBvsinPzM,ones(1,nk)).*gradPr;
  delAsqdelu=2*kron(Au+BvcosPzM,ones(1,nu)).*delAudelu;
  delAsqdelv=2*kron(Bv+AucosPzM,ones(1,nv)).*delBvdelv;
  gradAsq=[delAsqdelr,delAsqdelu,delAsqdelv];
  
endfunction  
