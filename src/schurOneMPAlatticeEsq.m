function [Esq,gradEsq,diagHessEsq,hessEsq]=...
         schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference,...
                               wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd)
% [Esq,gradEsq,diagHessEsq,hessEsq]= ...
%   schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference,...
%                         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd)
% Inputs:
%   A1k,A2k - one-multiplier allpass section denominator multiplier coefficients
%   A1epsilon,A2epsilon - one-multiplier allpass section sign coefficients
%   A1p,A2p - internal state scaling factors
%   difference - return the response for the difference of the all-pass filters
%   wa - angular frequencies of desired pass-band amplitude response in [0,pi]
%   Asqd - desired pass-band magnitude-squared response
%   Wa - pass-band amplitude weight vector
%   wt - angular frequencies of the desired group delay response
%   Td - desired group delay response 
%   Wt - group delay weight vector
%   wp - angular frequencies of the desired phase response
%   Pd - desired phase response 
%   Wp - phase weight vector
%   wd - angular frequencies of the desired derivative of squared-amplitude
%        response
%   Dd - desired derivative of the squared-amplitude response wrt w
%   Wd - derivative of squared-amplitude weight vector
%   
% Outputs:
%   Esq - the squared error value at the coefficients, x
%   gradEsq - gradient of the squared error value at x
%   diagHessEsq - diagonal of the Hessian of the squared error value at x.
%   hessEsq - Hessian of the squared error value at x.

% Copyright (C) 2017-2024 Robert G. Jenssen
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

  if nargout>4 || ((nargin~=10)&&(nargin~=13)&&(nargin~=16)&&(nargin~=19))
    print_usage("[Esq,gradEsq,diagHessEsq,hessEsq] = ...\n\
      schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...\n\
                            difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd) \n\
[Esq,gradEsq,diagHessEsq,hessEsq] = ...\n\
      schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...\n\
                            difference,wa,Asqd,Wa,wt,Td,Wt) \n\
[Esq,gradEsq,diagHessEsq,hessEsq] = ...\n\
      schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...\n\
                            difference,wa,Asqd,Wa)");
  endif
  
  if nargin==10
    wt=[];
    wp=[];
    wd=[];
  elseif nargin==13
    wp=[];    
    wd=[];
  elseif nargin==16
    wd=[];
  endif

  NA1k=length(A1k);
  NA2k=length(A2k);
  NA12k=NA1k+NA2k;
  
  if nargout==1
    if isempty(wa)
      EsqAsq = 0;
    else
      EsqAsq=schurOneMPAlatticeXError(@schurOneMPAlatticeAsq,...
                                      A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                      difference,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
    else
      EsqT = schurOneMPAlatticeXError(@schurOneMPAlatticeT,...
                                      A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                      difference,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
    else
      EsqP = schurOneMPAlatticeXError(@schurOneMPAlatticeP,...
                                      A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                      difference,wp,Pd,Wp);
    endif
    if isempty(wd)
      EsqD = 0;
    else
      EsqD = schurOneMPAlatticeXError(@schurOneMPAlatticedAsqdw,...
                                      A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                      difference,wd,Dd,Wd);
    endif
    Esq = EsqAsq + EsqT + EsqP + EsqD;

  elseif nargout==2
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,NA12k);
    else
      [EsqAsq,gradEsqAsq] = ...
        schurOneMPAlatticeXError(@schurOneMPAlatticeAsq,...
                                 A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                 difference,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqT = zeros(1,NA12k);
    else
      [EsqT,gradEsqT] = ...
        schurOneMPAlatticeXError(@schurOneMPAlatticeT,...
                                 A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                 difference,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
      gradEsqP = zeros(1,NA12k);
    else
      [EsqP,gradEsqP] = ...
        schurOneMPAlatticeXError(@schurOneMPAlatticeP,...
                                 A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                 difference,wp,Pd,Wp); 
    endif
    if isempty(wd)
      EsqD = 0;
      gradEsqD = zeros(1,NA12k);
    else
      [EsqD,gradEsqD] = ...
        schurOneMPAlatticeXError(@schurOneMPAlatticedAsqdw, ...
                                 A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                 difference,wd,Dd,Wd);
    endif
    Esq = EsqAsq + EsqT + EsqP + EsqD;
    gradEsq = gradEsqAsq + gradEsqT + gradEsqP + gradEsqD;
    
  elseif nargout==3
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,NA12k);
      diagHessEsqAsq = zeros(1,NA12k);
    else
      [EsqAsq,gradEsqAsq,diagHessEsqAsq] = ...
        schurOneMPAlatticeXError(@schurOneMPAlatticeAsq, ...
                                 A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                 difference,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqT = zeros(1,NA12k);
      diagHessEsqT = zeros(1,NA12k);
    else
      [EsqT,gradEsqT,diagHessEsqT] = ...
        schurOneMPAlatticeXError(@schurOneMPAlatticeT, ...
                                 A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                 difference,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
      gradEsqP = zeros(1,NA12k);
      diagHessEsqP = zeros(1,NA12k);
    else
      [EsqP,gradEsqP,diagHessEsqP] = ...
        schurOneMPAlatticeXError(@schurOneMPAlatticeP, ...
                                 A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                 difference,wp,Pd,Wp);
    endif
    if isempty(wd)
      EsqD = 0;
      gradEsqD = zeros(1,NA12k);
      diagHessEsqD = zeros(1,NA12k);
    else
      [EsqD,gradEsqD,diagHessEsqD] = ...
          schurOneMPAlatticeXError(@schurOneMPAlatticedAsqdw,...
                                   A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                   difference,wd,Dd,Wd);
    endif
    Esq = EsqAsq + EsqT + EsqP + EsqD;
    gradEsq = gradEsqAsq + gradEsqT + gradEsqP + gradEsqD;
    diagHessEsq = diagHessEsqAsq + diagHessEsqT + diagHessEsqP + diagHessEsqD;
    
  elseif nargout==4
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,NA12k);
      diagHessEsqAsq = zeros(1,NA12k);
      hessEsqAsq = zeros(NA12k,NA12k);
    else
      [EsqAsq,gradEsqAsq,diagHessEsqAsq,hessEsqAsq] = ...
        schurOneMPAlatticeXError(@schurOneMPAlatticeAsq, ...
                                 A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                 difference,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqT = zeros(1,NA12k);
      diagHessEsqT = zeros(1,NA12k);
      hessEsqT = zeros(NA12k,NA12k);
    else
      [EsqT,gradEsqT,diagHessEsqT,hessEsqT] = ...
        schurOneMPAlatticeXError(@schurOneMPAlatticeT, ...
                                 A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                 difference,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
      gradEsqP = zeros(1,NA12k);
      diagHessEsqP = zeros(1,NA12k);
      hessEsqP = zeros(NA12k,NA12k);
    else
      [EsqP,gradEsqP,diagHessEsqP,hessEsqP] = ...
        schurOneMPAlatticeXError(@schurOneMPAlatticeP, ...
                                 A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                 difference,wp,Pd,Wp);
    endif
    if isempty(wd)
      EsqD = 0;
      gradEsqD = zeros(1,NA12k);
      diagHessEsqD = zeros(1,NA12k);
      hessEsqD = zeros(NA12k,NA12k);
    else
      [EsqD,gradEsqD,diagHessEsqD,hessEsqD] = ...
          schurOneMPAlatticeXError(@schurOneMPAlatticedAsqdw,...
                                   A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                   difference,wd,Dd,Wd);
    endif
    Esq = EsqAsq + EsqT + EsqP + EsqD;
    gradEsq = gradEsqAsq + gradEsqT + gradEsqP + gradEsqD;
    diagHessEsq = diagHessEsqAsq + diagHessEsqT + diagHessEsqP + diagHessEsqD;
    hessEsq = hessEsqAsq + hessEsqT + hessEsqP + hessEsqD;
  endif

endfunction

function [ErrorX,gradErrorX,diagHessErrorX,hessErrorX] = ...
         schurOneMPAlatticeXError(pfX,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                  difference,wx,Xd,Wx)

  if nargin~=11 || nargout>4
    print_usage("[ErrorX,gradErrorX,diagHessErrorX,hessErrorX] = ...\n\
    schurOneMPAlatticeXError(pfX,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...\n\
                             difference,wx,Xd,Wx)");
  endif

  % Make row vectors with a single column, 
  % since by default, sum() adds over first dimension
  A1k=A1k(:);
  NA1k=length(A1k);
  A1epsilon=A1epsilon(:);
  A1p=A1p(:);
  A2k=A2k(:);
  NA2k=length(A2k);
  A2epsilon=A2epsilon(:);
  A2p=A2p(:);
  wx=wx(:);
  Xd=Xd(:);
  Wx=Wx(:);
  NA12k=NA1k+NA2k;

  % Sanity checks
  Nx = length(wx);
  if length(Xd) ~= Nx
    error("length(wx)~=length(Xd)");
  endif
  if length(Wx) ~= Nx
    error("length(wx)~=length(Wx)");
  endif
  
  % X response at wx
  if nargout==1
    X=pfX(wx,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
    gradX=zeros(Nx,NA12k);
    diagHessX=zeros(Nx,NA12k);
  elseif nargout==2
    [X,gradX]=pfX(wx,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
    diagHessX=zeros(Nx,NA12k);
  elseif nargout==3
    [X,gradX,diagHessX]=pfX(wx,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
  elseif nargout==4
    [X,gradX,diagHessX,hessX] = ...
      pfX(wx,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
  endif

  % Sanity check
  Xnf=find(any(~isfinite(X)));
  X(Xnf)=Xd(Xnf);
  gradX(Xnf,:)=0;

  % X response error with trapezoidal integration.
  dwx = diff(wx);
  ErrX=Wx.*(X-Xd);
  sqErrX=ErrX.*(X-Xd);
  ErrorX=sum(dwx.*(sqErrX(1:(Nx-1))+sqErrX(2:Nx)))/2;
  if nargout==1
    return;
  endif

  % Gradient of response error  
  kErrX=kron(ErrX,ones(1,NA12k));
  kErrXGradX=((kErrX(1:(Nx-1),:).*gradX(1:(Nx-1),:)) + ...
                  (kErrX(2:end,:).*gradX(2:end,:)))/2;
  kdwx=kron(dwx,ones(1,NA12k));
  kdwxErrXGradX=2*kdwx.*kErrXGradX;
  gradErrorX=sum(kdwxErrXGradX,1);
  if nargout==2
    return
  endif

  % We only want the diagonal of the Hessian of the error.
  % Recall that the derivative of integralof(2*Wx*(X-Xd)'*gradX) is
  % integralof(2*Wx*gradX'*gradX + 2*Wx*(X-Xd)'*diagHessX). 
  dHessXInt=(kron(Wx,ones(1,NA12k)).*(gradX.^2))+(kErrX.*diagHessX);
  diagHessErrorX=sum(kdwx.*(dHessXInt(1:(Nx-1),:)+dHessXInt(2:Nx,:)),1);
  if nargout==3
    return
  endif

  % Hessian of the squared-error
  % Construct the 1st term
  WxKgradX=kron(ones(1,NA12k),Wx).*gradX;
  WgradXbyRow = ...
    permute(reshape(kron(WxKgradX',ones(1,NA12k)),NA12k,NA12k,Nx),[3,1,2]);
  gradXbyCol = ...
    permute(reshape(kron(gradX',ones(NA12k,1)),NA12k,NA12k,Nx),[3,1,2]);

  % Construct 2nd term
  % Create an Nx-by-NA12k-by-NA12k array.
  % Each element of the l'th NA12k-by-NA12k subarray is ErrX(l).
  hkErrX=permute(reshape(kron(ErrX',ones(NA12k,NA12k)),NA12k,NA12k,Nx),[3,1,2]);

  % Integrand
  hXint=(WgradXbyRow.*gradXbyCol)+(hkErrX.*hessX);

  % Trapezoidal integration
  kdwx=permute(reshape(kron(dwx',ones(NA12k,NA12k)),NA12k,NA12k,Nx-1),[3,1,2]);
  hessErrorX=2*reshape(sum(kdwx.*(hXint(1:(Nx-1),:,:) + ...
                                  hXint(2:Nx,:,:))/2,1),NA12k,NA12k);

endfunction
