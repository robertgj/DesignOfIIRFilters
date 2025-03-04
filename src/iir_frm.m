function [Asq,T,gradAsq,gradT]=iir_frm(w,xk,U,V,M,Q,na,nc,Mmodel,Dmodel)
% [Asq,T,gradAsq,gradT]=iir_frm(w,xk,U,V,M,Q,na,nc,Mmodel,Dmodel)
% Calculate the squared-amplitude and group delay responses and their
% gradients for the zero-phase frequency response of an FRM filter
% in which the IIR model filter is represented in gain-pole-zero form
% and the masking filters are linear phase FIR filters.
% 
% Inputs:
%   w - angular frequencies for response
%   xk - vector containing the filter coefficients:
%      * xk(1:(1+U+V+M+Q)) : IIR model filter gain-zero-poles
%      * xk((1+U+V+M+Q+1):(1+U+V+M+Q+na) : aa mask filter
%      * xk((1+U+V+M+Q+na+1):(1+U+V+M+Q+na+nc) : ac mask filter
%   Mmodel - decimation factor of the IIR model filter
%   Dmodel - passband delay of the IIR model filter
%
% Outputs:
%   Asq - squared-amplitude response at angular frequencies w
%   T - delay response at angular frequencies w
%   gradAsq - gradient of Asq with respect to the coefficients at w
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
  if (nargin ~= 10) || (nargout > 4)
    print_usage("[Asq,T,gradAsq,gradT]=\
iir_frm(w,xk,U,V,M,Q,na,nc,Mmodel,Dmodel);");
  endif
  na_is_odd=(mod(na,2)==1);
  nc_is_odd=(mod(nc,2)==1);
  if na_is_odd ~= nc_is_odd
    error("na_is_odd ~= nc_is_odd");
  endif
  %  una - the number of unique masking filter coefficients
  if na_is_odd
    una=(na+1)/2;
  else
    una=na/2;
  endif 
  %  unc - the number of unique complementary masking filter coefficients
  if nc_is_odd
    unc=(nc+1)/2;
  else
    unc=nc/2;
  endif 
  nfir=una+unc;
  niir=1+U+V+M+Q;
  if length(xk) ~= niir+nfir
    error("length(x) ~= (1+U+V+M+Q+una+unc)");
  endif
  if isempty(w)
    Asq=[];
    T=[];
    gradAsq=[];
    gradT=[];
    return;
  endif;

  %
  % Extract filter coefficients from xk
  %
  xk=xk(:);
  % Model filter
  rk=xk(1:niir);
  % Masking filter
  aak=xk((niir+1):(niir+una));
  % Complementary masking filter
  ack=xk((niir+una+1):(niir+una+unc));

  % Initialise
  w=w(:);
  Nw=length(w);

  % Model filter amplitude, phase and delay response and gradients
  if nargout == 1
    Rrk=iirA(Mmodel*w,rk,U,V,M,Q,1);
    Prk=iirP(Mmodel*w,rk,U,V,M,Q,1);
    gradRrk=[];gradPrk=[];Trk=[];gradTrk=[];delRrkdelw=[];graddelRrkdelw=[];
  elseif nargout == 2
    Rrk=iirA(Mmodel*w,rk,U,V,M,Q,1);
    Prk=iirP(Mmodel*w,rk,U,V,M,Q,1);
    Trk=iirT(Mmodel*w,rk,U,V,M,Q,1);
    delRrkdelw=iirdelAdelw(Mmodel*w,rk,U,V,M,Q);
    gradRrk=[];gradPrk=[];gradTrk=[];graddelRrkdelw=[];
  elseif nargout == 3
    [Rrk,gradRrk]=iirA(Mmodel*w,rk,U,V,M,Q,1);
    [Prk,gradPrk]=iirP(Mmodel*w,rk,U,V,M,Q,1);
    Trk=iirT(Mmodel*w,rk,U,V,M,Q,1);
    delRrkdelw=iirdelAdelw(Mmodel*w,rk,U,V,M,Q);
    gradTrk=[];graddelRrkdelw=[];
  else
    [Rrk,gradRrk]=iirA(Mmodel*w,rk,U,V,M,Q,1);
    [Prk,gradPrk]=iirP(Mmodel*w,rk,U,V,M,Q,1);
    [Trk,gradTrk]=iirT(Mmodel*w,rk,U,V,M,Q,1);
    [delRrkdelw,graddelRrkdelw]=iirdelAdelw(Mmodel*w,rk,U,V,M,Q);
  endif
  % Adjust for factor of Mmodel in partial derivative with respect to w
  Trk=Mmodel*Trk;
  gradTrk=Mmodel*gradTrk;
  delRrkdelw=Mmodel*delRrkdelw;
  graddelRrkdelw=Mmodel*graddelRrkdelw;

  % Model filter trig functions
  phiZ=(Dmodel*Mmodel*w)+Prk;
  cosphiZ=cos(phiZ);
  sinphiZ=cos(phiZ);

  % Masking filter trig functions
  if na_is_odd
    Nna=(1:((na-1)/2));
    ca=[ones(Nw,1), 2*cos(kron(Nna,w))];
  else
    Nna=((1/2):((na-1)/2));
    ca=2*cos(kron(Nna,w));
  endif

  % Complementary masking filter trig functions
  if nc_is_odd
    Nnc=(1:((nc-1)/2));
    cc=[ones(Nw,1), 2*cos(kron(w,Nnc))];
  else
    Nnc=((1/2):((nc-1)/2));
    cc=2*cos(kron(w,Nnc));
  endif 

  % FIR masking filter zero phase response
  A=ca*aak-cc*ack;

  % FIR complementary masking filter zero phase response
  B=cc*ack;

  % Trig functions
  phiZMmodelw=(Dmodel*Mmodel*w)+Prk;
  cosphiZ=cos(phiZMmodelw);
  sinphiZ=sin(phiZMmodelw);
  
  %
  % FRM filter squared-amplitude response
  %
  A2R2=(A.*Rrk).^2;
  B2=B.^2;
  RcosphiZ=Rrk.*cosphiZ;
  BRcosphiZ=B.*RcosphiZ;
  ABRcosphiZ=A.*BRcosphiZ;
  Asq=A2R2+B2+(2*ABRcosphiZ);
  if nargout == 1
    return;
  endif
  
  %
  % FRM filter zero-phase group delay response
  %
  if na_is_odd
    sa=-2*[zeros(Nw,1), kron(ones(Nw,1),Nna).*sin(kron(w,Nna))];
  else
    sa=-2*kron(ones(Nw,1),Nna).*sin(kron(w,Nna));
  endif
  if nc_is_odd
    sc=-2*[zeros(Nw,1), kron(ones(Nw,1),Nnc).*sin(kron(w,Nnc))];
  else
    sc=-2*kron(ones(Nw,1),Nnc).*sin(kron(w,Nnc));
  endif
  delphiZdelw=(Dmodel*Mmodel)-Trk;
  BsinphiZ=B.*sinphiZ;
  ABsinphiZ=A.*BsinphiZ;
  RsinphiZ=Rrk.*sinphiZ;
  delAdelw=sa*aak-sc*ack;
  delBdelw=sc*ack;
  AdelBdelwMBdelAdelw=(A.*delBdelw)-(B.*delAdelw);
  T=(-((A2R2+ABRcosphiZ).*delphiZdelw) ...
     -(ABsinphiZ.*delRrkdelw) ...
     +(RsinphiZ.*AdelBdelwMBdelAdelw))./Asq;
  if nargout == 2
    return;
  endif

  %
  % FRM filter squared-amplitude response gradient with respect to coefficients
  %
  A2R=A.*A.*Rrk;
  AR2=A.*Rrk.*Rrk;
  BcosphiZ=B.*cosphiZ;
  ABcosphiZ=A.*BcosphiZ;
  RcosphiZ=Rrk.*cosphiZ;
  ARcosphiZ=A.*RcosphiZ;
  ABRsinphiZ=Rrk.*ABsinphiZ;
  delAdela=[ca,-cc];
  delBdela=[zeros(size(ca)),cc];
  oneiir=ones(1,niir);
  onefir=ones(1,nfir);
  delAsqdelr=(2*kron(A2R+ABcosphiZ,oneiir).*gradRrk) ...
             -(2*kron(ABRsinphiZ,oneiir).*gradPrk);
  delAsqdela=(2*kron(AR2+BRcosphiZ,onefir).*delAdela) ...
             +(2*kron(B+ARcosphiZ,onefir).*delBdela);
  gradAsq=[delAsqdelr,delAsqdela];
  if nargout == 3
    return;
  endif
  
  %
  % FRM filter group delay response gradient with respect to coefficients
  %
  AsinphiZ=A.*sinphiZ;
  ARsinphiZ=Rrk.*AsinphiZ;
  BsinphiZ=B.*sinphiZ;
  BRsinphiZ=Rrk.*BsinphiZ;
  graddelAdelw=[sa,-sc];
  graddelBdelw=[zeros(Nw,una),sc];
  AsqdelTdelr=-(kron(T,oneiir).*delAsqdelr) ...
              +(kron(A2R2+ABRcosphiZ,oneiir).*gradTrk) ...
              -(kron(((2*A2R)+ABcosphiZ).*delphiZdelw,oneiir).*gradRrk) ...
              +(kron(ABRsinphiZ.*delphiZdelw,oneiir).*gradPrk) ...
              -(kron(ABcosphiZ.*delRrkdelw,oneiir).*gradPrk) ...
              -(kron(ABsinphiZ,oneiir).*graddelRrkdelw) ...
              +(kron(sinphiZ.*AdelBdelwMBdelAdelw,oneiir).*gradRrk) ...
              +(kron(RcosphiZ.*AdelBdelwMBdelAdelw,oneiir).*gradPrk);
  AsqdelTdela=-(kron(T,onefir).*delAsqdela) ...
              -(kron(((2*AR2)+BRcosphiZ).*delphiZdelw,onefir).*delAdela) ...
              -(kron(ARcosphiZ.*delphiZdelw,onefir).*delBdela) ...
              -(kron(AsinphiZ.*delRrkdelw,onefir).*delBdela) ...
              -(kron(BsinphiZ.*delRrkdelw,onefir).*delAdela) ...
              -(kron(RsinphiZ.*delAdelw,onefir).*delBdela) ...
              +(kron(RsinphiZ.*delBdelw,onefir).*delAdela) ...
              +(kron(ARsinphiZ,onefir).*graddelBdelw) ...
              -(kron(BRsinphiZ,onefir).*graddelAdelw);
  gradT=[AsqdelTdelr,AsqdelTdela]./kron(Asq,[oneiir,onefir]);
  
endfunction  
