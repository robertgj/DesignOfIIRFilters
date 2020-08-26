function [Asq,P,T,gradAsq,gradP,gradT] = ...
         schurOneMAPlattice_frm(w,k,epsilon,p,u,v,Mmodel,Dmodel)
% [Asq,P,T,gradAsq,gradP,gradT] = ...
%   schurOneMAPlattice_frm(w,k,epsilon,p,u,v,Mmodel,Dmodel)
% Calculate the squared-magnitude and zero-phase phase and delay response and
% gradients of the response with respect to the coefficients of an FRM
% filter in which the model filter consists of a Schur one-multiplier
% lattice all-pass filter in  parallel with a delay. The FIR masking filter
% is assumed to be odd length (ie: even order) and symmetric (ie: linear phase).
% 
% Inputs:
%   w - angular frequencies for response
%   k - filter one-multiplier lattice filter coefficients
%   epsilon, p - one-multiplier lattice scaling coefficients
%   u,v - distinct symmetric, even order FIR masking filter coefficients
%         (with aa=[u(end:-1:2);u] and ac=[v(end:-1:2);v])
%   Mmodel - decimation factor of the all-pass model filter
%   Dmodel - delay of the pure delay branch of the model filter
%
% Outputs:
%   Asq - squared-magnitude response at angular frequencies w
%   P - zero-phase phase response at angular frequencies w
%   T - zero-phase group delay response at angular frequencies w
%   gradAsq - gradient of Asq at w
%   gradP - gradient of P at w
%   gradT - gradient of T at w

% Copyright (C) 2019 Robert G. Jenssen
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
  if (nargin ~= 8) || (nargout > 6)
    print_usage("[Asq,P,T,gradAsq,gradP,gradT]= ...\n\
      schurOneMAPlattice_frm(w,k,epsilon,p,u,v,Mmodel,Dmodel);")
  endif
  if length(u) ~= length(v)
    error("length(u) ~= length(v)");
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
    P=[];
    T=[];
    gradAsq=[];
    gradP=[];
    gradT=[]; 
    return;
  endif;
  
  %
  % Initialise
  %
  nk=length(k);
  nuv=length(u);
  dmask=length(u)-1;
  u=u(:);
  v=v(:);
  w=w(:);
  nw=length(w);
  
  %
  % FRM filter zero-phase delay response
  %

  % Model filter lowpass branch phase response
  if nargout == 1
    Pr=schurOneMAPlatticeP(w,k,epsilon,p,Mmodel);
  else 
    [Pr,gradPr]=schurOneMAPlatticeP(w,k,epsilon,p,Mmodel);
  endif

  % Zero-phase model filter phase response with frequency
  PzM=(Mmodel*Dmodel*w)+Pr;
  
  % FIR masking filter amplitude response
  cuv=[ones(nw,1) 2*cos(kron(1:(nuv-1),w))];
  Auv=cuv*(u+v)/2;
  Buv=cuv*(u-v)/2;

  % Precalculate common values
  Auv2=Auv.*Auv;
  Buv2=Buv.*Buv;
  sinPzM=sin(PzM);
  cosPzM=cos(PzM);
  AuvsinPzM=Auv.*sinPzM;
  BuvsinPzM=Buv.*sinPzM;
  AuvBuvsinPzM=Auv.*BuvsinPzM;
  AuvcosPzM=Auv.*cosPzM; 
  BuvcosPzM=Buv.*cosPzM;
  AuvBuvcosPzM=Auv.*BuvcosPzM;
   
  % Combined squared-magnitude response
  cosPzM=cos(PzM);
  Auv2=Auv.*Auv;
  Buv2=Buv.*Buv;
  BuvcosPzM=Buv.*cosPzM;
  AuvBuvcosPzM=Auv.*BuvcosPzM;
  Asq=Auv2+Buv2+(2*AuvBuvcosPzM);
  if nargout == 1
    return;
  endif
 
  % Zero-phase model filter phase response with frequency
  P=unwrap(atan2(AuvsinPzM,AuvcosPzM+Buv));
  if nargout == 2
    return;
  endif

  % Zero-phase model filter group delay response with frequency
  if nargout == 3
    Tr=schurOneMAPlatticeT(w,k,epsilon,p,Mmodel);
  else
    [Tr,gradTr]=schurOneMAPlatticeT(w,k,epsilon,p,Mmodel);
  endif

  % Combined group delay response
  delPzMdelw=(Mmodel*Dmodel)-Tr;
  suv=-2*kron(ones(nw,1),(0:(nuv-1))).*sin(kron(w,(0:(nuv-1))));
  delAuvdelw=suv*(u+v)/2;
  delBuvdelw=suv*(u-v)/2;
  T=-((Auv2+(Auv.*Buv.*cosPzM)).*delPzMdelw) ...
    -(Buv.*sinPzM.*delAuvdelw) ...
    +(Auv.*sinPzM.*delBuvdelw);
  T=T./Asq;
  if nargout == 3
    return;
  endif

  % Asq gradients
  AuvcosPzM=Auv.*cosPzM;
  sinPzM=sin(PzM);
  BuvsinPzM=Buv.*sinPzM;
  AuvBuvsinPzM=Auv.*BuvsinPzM;
  delAuvdelu=cuv/2;
  delAuvdelv=delAuvdelu;
  delBuvdelu=delAuvdelu;
  delBuvdelv=-delAuvdelu;
  delAsqdelr=-2*kron(AuvBuvsinPzM,ones(1,nk)).*gradPr;
  delAsqdelu=(2*kron(Auv+BuvcosPzM,ones(1,nuv)).*delAuvdelu) + ...
             (2*kron(Buv+AuvcosPzM,ones(1,nuv)).*delBuvdelu);
  delAsqdelv=(2*kron(Auv+BuvcosPzM,ones(1,nuv)).*delAuvdelv) + ...
             (2*kron(Buv+AuvcosPzM,ones(1,nuv)).*delBuvdelv);
  gradAsq=[delAsqdelr,delAsqdelu,delAsqdelv];
  if nargout == 4
    return;
  endif

  % P gradients
  delPdelr=kron(Auv.*(Auv+BuvcosPzM),ones(1,nk)).*gradPr;
  delPdelu=(kron(sinPzM.*Buv,ones(1,nuv)).*delAuvdelu) - ...
           (kron(sinPzM.*Auv,ones(1,nuv)).*delBuvdelu); 
  delPdelv=(kron(sinPzM.*Buv,ones(1,nuv)).*delAuvdelv) - ...
           (kron(sinPzM.*Auv,ones(1,nuv)).*delBuvdelv);
  gradP=[delPdelr,delPdelu,delPdelv]./kron(Asq,ones(1,nk+nuv+nuv));  
  if nargout == 5
    return;
  endif

  % T gradients
  del2Auvdeludelw=suv/2;
  del2Auvdelvdelw=del2Auvdeludelw;
  del2Buvdeludelw=del2Auvdeludelw;
  del2Buvdelvdelw=-del2Auvdeludelw;
  
  delTdelr=+(kron(Auv2+AuvBuvcosPzM,ones(1,nk)).*gradTr) ...
           +(kron(AuvBuvsinPzM.*delPzMdelw,ones(1,nk)).*gradPr) ...
           +(kron(AuvcosPzM.*delBuvdelw,ones(1,nk)).*gradPr) ...
           -(kron(BuvcosPzM.*delAuvdelw,ones(1,nk)).*gradPr);

  delTdelu=-(kron(((2*Auv)+BuvcosPzM).*delPzMdelw,ones(1,nuv)).*delAuvdelu) ...
           -(kron(Auv.*cosPzM.*delPzMdelw,ones(1,nuv)).*delBuvdelu) ...
           +(kron(sinPzM.*delBuvdelw,ones(1,nuv)).*delAuvdelu) ...
           -(kron(sinPzM.*delAuvdelw,ones(1,nuv)).*delBuvdelu) ...
           +(kron(AuvsinPzM,ones(1,nuv)).*del2Buvdeludelw) ...
           -(kron(BuvsinPzM,ones(1,nuv)).*del2Auvdeludelw);              

  delTdelv=-(kron(((2*Auv)+BuvcosPzM).*delPzMdelw,ones(1,nuv)).*delAuvdelv) ...
           -(kron(Auv.*cosPzM.*delPzMdelw,ones(1,nuv)).*delBuvdelv) ...
           +(kron(sinPzM.*delBuvdelw,ones(1,nuv)).*delAuvdelv) ...
           -(kron(sinPzM.*delAuvdelw,ones(1,nuv)).*delBuvdelv) ...
           +(kron(AuvsinPzM,ones(1,nuv)).*del2Buvdelvdelw) ...
           -(kron(BuvsinPzM,ones(1,nuv)).*del2Auvdelvdelw);              

  gradT=[delTdelr,delTdelu,delTdelv];
  gradT=gradT-(gradAsq.*kron(T,ones(1,nk+nuv+nuv)));
  gradT=gradT./kron(Asq,ones(1,nk+nuv+nuv));

endfunction  
