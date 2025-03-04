function [Asq,T,gradAsq,gradT]= ...
  iir_frm_allpass(w,xk,Vr,Qr,Rr,na,nc,Mmodel,Dmodel)
% [Asq,T,gradAsq,gradT]=iir_frm_allpass(w,xk,Vr,Qr,Rr,na,nc,Mmodel,Dmodel)
% Calculate the squared-amplitude and delay responses and gradients
% of the frequency response for an FRM filter in which the model filter,
% consists of an allpass filter in  parallel with a delay. The FIR
% masking filters are assumed to be odd length (ie: even order) and
% symmetric (ie: linear phase).
% 
% Inputs:
%   w - angular frequencies for response
%   xk - vector containing the filter coefficients:
%      * xk(1:(Vr+Qr)) : allpass model filter poles
%      * xk((1+Vr+Qr+1):(1+Vr+Qr+na) : masking filter
%      * xk((1+Vr+Qr+na+1):(1+Vr+Qr+na+nc) : complementary masking filter
%   Vr - number of real allpass poles
%   Qr - number of complex allpass poles
%   Rr - decimation factor of the allpass filter
%   Mmodel - decimation factor of the allpass model filter
%   Dmodel - delay of the pure delay branch of the model filter
%
% Outputs:
%   Asq - squared-amplitude response at angular frequencies w
%   T - delay response at angular frequencies w
%   gradAsq - gradient of Asq at w
%   gradT - gradient of T at w

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

  %
  % Sanity checks
  %
  if (nargin ~= 9) || (nargout > 4)
    print_usage("[Asq,T,gradAsq,gradT]= ...\n\
  iir_frm_allpass(w,xk,Vr,Qr,Rr,na,nc,Mmodel,Dmodel);");
  endif
  if ~(mod(na,2) && mod(nc,2))
    error("Expected both na and nc to be odd");
  endif

  %
  % Initialise
  %
  if nargout == 0
    return;
  endif
  if isempty(w)
    Asq=[];
    T=[];
    gradAsq=[]; 
    gradT=[];
    return;
  endif;
  w=w(:);
  Nw=length(w);
  %  una - the number of unique masking filter coefficients
  una=(na+1)/2;
  %  unc - the number of unique complementary masking filter coefficients
  unc=(nc+1)/2;
  nfir=una+unc;
  niir=Vr+Qr;
  Nxk=length(xk);
  if Nxk ~= niir+nfir
    error("length(xk) ~= (Vr+Qr+una+unc)");
  endif
  % Extract filter coefficients from xk
  xk=xk(:);
  % Model filter
  rk=xk(1:niir);
  % Masking filter
  aak=xk((niir+1):(niir+una));
  % Complementary filter
  ack=xk((niir+una+1):(niir+una+unc)); 
  % Delay of the masking filters
  d=max(una,unc)-1;
  
  %
  % FRM filter squared-amplitude and zero-phase delay responses
  %

  % Model filter allpass branch phase response
  if nargout <= 2
    Pr = allpassP(w,rk,Vr,Qr,Rr*Mmodel);
  else 
    [Pr,gradPr] = allpassP(w,rk,Vr,Qr,Rr*Mmodel);
  endif
  
  % FIR masking filter amplitude responses
  ca=[ones(Nw,1) 2*cos(kron((1:((na-1)/2)),w))];
  cc=[ones(Nw,1) 2*cos(kron((1:((nc-1)/2)),w))];
  Aa=(ca*aak+cc*ack)/2;
  Ab=(ca*aak-cc*ack)/2;
   
  % Zero-phase model filter phase response with frequency
  PzM=(Mmodel*Dmodel*w)+Pr;
  
  % Precalculate common values
  Aa2=Aa.*Aa;
  Ab2=Ab.*Ab;
  sinPzM=sin(PzM);
  cosPzM=cos(PzM);
  AasinPzM=Aa.*sinPzM;
  AbsinPzM=Ab.*sinPzM;
  AaAbsinPzM=Aa.*AbsinPzM;
  AacosPzM=Aa.*cosPzM; 
  AbcosPzM=Ab.*cosPzM;
  AaAbcosPzM=Aa.*AbcosPzM;

  % Combined squared magnitude response
  Asq=Aa2+Ab2+(2*AaAbcosPzM);
  if nargout == 1
    return;
  endif

  % Model filter allpass branch delay response
  if (nargout == 2) || (nargout == 3)
    Tr = allpassT(w,rk,Vr,Qr,Rr*Mmodel);
  elseif nargout == 4
    [Tr,gradTr] = allpassT(w,rk,Vr,Qr,Rr*Mmodel);
  endif
   
  % Gradient of FIR masking filter amplitude responses with frequency
  sa=-2*kron(ones(Nw,1),(0:(una-1))).*sin(kron(w,(0:(una-1))));
  sc=-2*kron(ones(Nw,1),(0:(unc-1))).*sin(kron(w,(0:(unc-1))));
  delAadelw=(sa*aak+sc*ack)/2;
  delAbdelw=(sa*aak-sc*ack)/2;
  
  % Gradient of zero-phase model filter phase response with frequency
  delPzMdelw=(Mmodel*Dmodel)-Tr;
  
  % Combined delay response
  T=(-((Aa2+AaAbcosPzM).*delPzMdelw) ...
     +(AasinPzM.*delAbdelw)-(AbsinPzM.*delAadelw))./Asq;
  if nargout == 2
    return;
  endif

  % Asq gradients
  delAsqdelr=-2*kron(AaAbsinPzM,ones(1,niir)).*gradPr;
  delAsqdelaa=(kron(Aa+AbcosPzM,ones(1,una)) + ...
               kron(Ab+AacosPzM,ones(1,una))).*ca;
  delAsqdelac=(kron(Aa+AbcosPzM,ones(1,unc)) - ...
               kron(Ab+AacosPzM,ones(1,unc))).*cc;
  gradAsq=[delAsqdelr,delAsqdelaa,delAsqdelac];
  if nargout == 3
    return;
  endif
  
  % T gradients
  delTdelr=(kron(Aa2+AaAbcosPzM,ones(1,niir)).*gradTr) ...
           +(kron(AaAbsinPzM.*delPzMdelw,ones(1,niir)).*gradPr) ...
           +(kron(AacosPzM.*delAbdelw,ones(1,niir)).*gradPr) ...
           -(kron(AbcosPzM.*delAadelw,ones(1,niir)).*gradPr);

  delTdelaa=-(kron(((2*Aa)+AbcosPzM+AacosPzM).*delPzMdelw,ones(1,una)).*ca/2) ...
            +(kron(sinPzM.*(delAbdelw-delAadelw),ones(1,una)).*ca/2) ...
            +(kron(sinPzM.*(Aa-Ab),ones(1,una)).*sa/2);

  delTdelac=-(kron(((2*Aa)+AbcosPzM-AacosPzM).*delPzMdelw,ones(1,unc)).*cc/2) ...
            +(kron(sinPzM.*(delAbdelw+delAadelw),ones(1,una)).*cc/2) ...
            -(kron(sinPzM.*(Aa+Ab),ones(1,unc)).*sc/2);

  gradT=[delTdelr,delTdelaa,delTdelac];
  gradT=(gradT-(gradAsq.*kron(T,ones(1,Nxk))))./kron(Asq,ones(1,Nxk));
  
endfunction  
