function [Asq,T,gradAsq,gradT] = ...
         iir_frm_parallel_allpass(w,xk,Vr,Qr,Vs,Qs,na,nc,Mmodel)
% [Asq,T,gradAsq,gradT]=iir_frm_parallel_allpass(w,xk,Vr,Qr,Vs,Qs,na,nc,Mmodel)
% Calculate the squared-magnitude and group delay responses and gradients of
% an FRM filter with a parallel allpass model filter and FIR masking filters.
%
% Inputs:
%  w - vector of angular frequencies at which to calculate the response
%  xk,Vr,Qr,Vs,Qs,na,nc - xk is a vector with Vr+Qr real and complex allpass
%    pole coefficients,Vs+Qs real and complex allpass pole coefficients, na
%    FIR masking filter coefficients and nc FIR complementary masking filter
%    coefficients
%  Mmodel - model filter decimation factor
%
% Outputs:
%  Asq - the squared-magnitude response of the FRM filter
%  T - the group delay response of the FRM filter
%  gradAsq - the gradient of Asq with respect to the coefficients
%  gradT - the gradient of T with respect to the coefficients

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
  if nargin ~= 9
    print_usage("[Asq,T,gradAsq,gradT]=\
iir_frm_parallel_allpass(w,xk,Vr,Qr,Vs,Qs,na,nc,Mmodel)");
  endif
  if length(xk) ~= (Vr+Qr+Vs+Qs+na+nc)
    error("Expected length(xk) == (Vr+Qr+Vs+Qs+na+nc)");
  endif

  % Do nothing
  if isempty(w) || (nargout == 0)
    Asq=[];T=[];gradAsq=[];gradT=[];
    return;
  endif
  
  % Initialise
  w=w(:);
  Nw=length(w);
  xk=xk(:);
  Nxk=length(xk);
  rk=xk(1:(Vr+Qr));
  sk=xk((Vr+Qr+1):(Vr+Qr+Vs+Qs));
  aak=xk((Vr+Qr+Vs+Qs+1):(Vr+Qr+Vs+Qs+na));
  ack=xk((Vr+Qr+Vs+Qs+na+1):end);

  % Zero pad FIR masking filters
  if na > nc
    ack=[ack(:);zeros(na-nc,1)];
  elseif na<nc
    aak=[aak(:);zeros(nc-na,1)];
  else
    aak=aak(:);
    ack=ack(:);
  endif

  % Allpass filter responses
  if nargout == 1
    Pr = allpassP(w,rk,Vr,Qr,Mmodel);
    Ps = allpassP(w,sk,Vs,Qs,Mmodel);
  elseif nargout == 2
    Pr = allpassP(w,rk,Vr,Qr,Mmodel);
    Ps = allpassP(w,sk,Vs,Qs,Mmodel);
    Tr = allpassT(w,rk,Vr,Qr,Mmodel);
    Ts = allpassT(w,sk,Vs,Qs,Mmodel);
  elseif nargout == 3
    [Pr,gradPr] = allpassP(w,rk,Vr,Qr,Mmodel);
    [Ps,gradPs] = allpassP(w,sk,Vs,Qs,Mmodel);
    Tr = allpassT(w,rk,Vr,Qr,Mmodel);
    Ts = allpassT(w,sk,Vs,Qs,Mmodel);
  else
    [Pr,gradPr] = allpassP(w,rk,Vr,Qr,Mmodel);
    [Ps,gradPs] = allpassP(w,sk,Vs,Qs,Mmodel);
    [Tr,gradTr] = allpassT(w,rk,Vr,Qr,Mmodel);
    [Ts,gradTs] = allpassT(w,sk,Vs,Qs,Mmodel);
  endif

  % Initialise masking filter response vectors
  ak=(aak+ack)/2;
  bk=(aak-ack)/2;
  nm=max(na,nc);
  vk=(0:(nm-1));
  vw=kron(ones(Nw,1),vk).*kron(w,ones(1,nm));
  vwPr=vw-kron(Pr,ones(1,nm));
  vwPs=vw-kron(Ps,ones(1,nm));
  cR=cos(vwPr);
  cS=cos(vwPs);
  sR=sin(vwPr);
  sS=sin(vwPs);
  cRa=cR*ak;
  cSb=cS*bk; 
  sRa=sR*ak;
  sSb=sS*bk;
  cRaPcSb=cRa+cSb;
  sRaPsSb=sRa+sSb;
 
  % Squared-magnitude response
  Asq=(cRaPcSb.^2)+(sRaPsSb.^2);
  if nargout == 1
    return;
  endif

  % Group delay response
  vTr=kron(ones(Nw,1),vk)+kron(Tr,ones(1,nm));
  vTs=kron(ones(Nw,1),vk)+kron(Ts,ones(1,nm));
  delcRdelw=-(vTr.*sR);
  delcSdelw=-(vTs.*sS);
  delsRdelw= (vTr.*cR);
  delsSdelw= (vTs.*cS);
  delcRdelwa=delcRdelw*ak;
  delcSdelwb=delcSdelw*bk;
  delsRdelwa=delsRdelw*ak;
  delsSdelwb=delsSdelw*bk;
  delcRdelwaPdelcSdelwb=(delcRdelwa+delcSdelwb);
  delsRdelwaPdelsSdelwb=(delsRdelwa+delsSdelwb);
  AsqT=(cRaPcSb.*delsRdelwaPdelsSdelwb)-(sRaPsSb.*delcRdelwaPdelcSdelwb);
  T=AsqT./Asq;
  if nargout == 2
    return;
  endif
  
  % Squared-magnitude response gradients
  delAsqdelr= 2*kron((cSb.*sRa)-(sSb.*cRa),ones(1,Vr+Qr)).*gradPr;
  delAsqdels=-2*kron((cSb.*sRa)-(sSb.*cRa),ones(1,Vs+Qs)).*gradPs;
  delAsqdela=2*((kron(cRaPcSb,ones(1,nm)).*cR)+(kron(sRaPsSb,ones(1,nm)).*sR));
  delAsqdelb=2*((kron(cRaPcSb,ones(1,nm)).*cS)+(kron(sRaPsSb,ones(1,nm)).*sS));
  delAsqdelaa=delAsqdela+delAsqdelb;
  delAsqdelaa=delAsqdelaa(:,1:na)/2;
  delAsqdelac=delAsqdela-delAsqdelb;
  delAsqdelac=delAsqdelac(:,1:nc)/2;
  gradAsq=[delAsqdelr,delAsqdels,delAsqdelaa,delAsqdelac];
  if nargout ==3
    return;
  endif
  
  % Group delay response gradients
  del2cRdelrdelwa=-(kron(sRa,ones(1,Vr+Qr)).*gradTr) ...
                  +(kron(delsRdelwa,ones(1,Vr+Qr)).*gradPr);
  del2cSdelsdelwb=-(kron(sSb,ones(1,Vs+Qs)).*gradTs) ...
                  +(kron(delsSdelwb,ones(1,Vs+Qs)).*gradPs);
  del2sRdelrdelwa= (kron(cRa,ones(1,Vr+Qr)).*gradTr) ...
                  -(kron(delcRdelwa,ones(1,Vr+Qr)).*gradPr);
  del2sSdelsdelwb= (kron(cSb,ones(1,Vs+Qs)).*gradTs) ...
                  -(kron(delcSdelwb,ones(1,Vs+Qs)).*gradPs);
  delTdelr= (kron(sRa.*delsRdelwaPdelsSdelwb,ones(1,Vr+Qr)).*gradPr) ...
           +(kron(cRaPcSb,ones(1,Vr+Qr)).*del2sRdelrdelwa) ...
           +(kron(cRa.*delcRdelwaPdelcSdelwb,ones(1,Vr+Qr)).*gradPr) ...
           -(kron(sRaPsSb,ones(1,Vr+Qr)).*del2cRdelrdelwa);
  delTdels= (kron(sSb.*delsRdelwaPdelsSdelwb,ones(1,Vs+Qs)).*gradPs) ...
           +(kron(cRaPcSb,ones(1,Vs+Qs)).*del2sSdelsdelwb) ...
           +(kron(cSb.*delcRdelwaPdelcSdelwb,ones(1,Vs+Qs)).*gradPs) ...
           -(kron(sRaPsSb,ones(1,Vs+Qs)).*del2cSdelsdelwb);
  delTdela= (kron(delsRdelwaPdelsSdelwb,ones(1,nm)).*cR) ...
           +(kron(cRaPcSb,ones(1,nm)).*delsRdelw) ...
           -(kron(delcRdelwaPdelcSdelwb,ones(1,nm)).*sR) ...
           -(kron(sRaPsSb,ones(1,nm)).*delcRdelw);
  delTdelb= (kron(delsRdelwaPdelsSdelwb,ones(1,nm)).*cS) ...
           +(kron(cRaPcSb,ones(1,nm)).*delsSdelw) ...
           -(kron(delcRdelwaPdelcSdelwb,ones(1,nm)).*sS) ...
           -(kron(sRaPsSb,ones(1,nm)).*delcSdelw);
  delTdelaa=delTdela+delTdelb;
  delTdelaa=delTdelaa(:,1:na)/2;
  delTdelac=delTdela-delTdelb;
  delTdelac=delTdelac(:,1:nc)/2;
  gradT=[delTdelr,delTdels,delTdelaa,delTdelac];
  gradT=gradT-(gradAsq.*kron(T,ones(1,Nxk)));
  gradT=gradT./kron(Asq,ones(1,Nxk));
  
endfunction
