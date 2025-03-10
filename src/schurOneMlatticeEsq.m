function [Esq,gradEsq,diagHessEsq,hessEsq]=...
         schurOneMlatticeEsq(k,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd)
% [Esq,gradEsq,diagHessEsq,hessEsq]= ...
%   schurOneMlatticeEsq(k,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd)
%
% Calculate the weighted response error with trapezoidal integration.
%
% Inputs:
%   k - one-multiplier allpass section denominator multiplier coefficients
%   epsilon - one-multiplier allpass section sign coefficients (+1 or -1)
%   p - internal state scaling factors
%   c - numerator all-pass filter tap coefficients 
%   wa - angular frequencies of desired pass-band amplitude response in [0,pi]
%   Asqd - desired pass-band magnitude-squared response
%   Wa - pass-band amplitude weight vector
%   wt - angular frequencies of the desired group delay response
%   Td - desired group delay response 
%   Wt - group delay weight vector
%   wp - angular frequencies of the desired phase response
%   Pd - desired phase response 
%   Wp - phase weight vector
%   wp - angular frequencies of the desired phase response
%   wd - angular frequencies of the desired derivative of squared-amplitude
%        response
%   Dd - desired derivative of the squared-amplitude response wrt w
%   Wd - derivative of squared-amplitude weight vector
%   
% Outputs:
%   Esq - the squared error value at x
%   gradEsq - gradient of the squared error value at x
%   diagHessEsq - diagonal of the Hessian of the squared error value at x.
%   hessEsq - Hessian of the squared error value at x.

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

  if nargout>4 || ((nargin~=7)&&(nargin~=10)&&(nargin~=13)&&(nargin~=16))
    print_usage(["[Esq,gradEsq,diagHessEsq,hessEsq] = ...\n", ...
 "      schurOneMlatticeEsq(k,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd)"]);
  endif

  Nk=length(k);
  Nc=length(c);
  Nx=Nk+Nc;
  if Nc ~= (Nk+1)
    error("Expected length(k)+1==length(c)!");
  endif
  if nargin==7
    wt=[];
    wp=[];
    wd=[];
  elseif nargin==10
    wp=[];
    wd=[];
  elseif nargin==13
    wd=[];
  endif
  
  if nargout==1
    if isempty(wa)
      EsqAsq = 0;
    else
      EsqAsq=schurOneMlatticeXError(@schurOneMlatticeAsq,...
                                    k,epsilon,p,c,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
    else
      EsqT = schurOneMlatticeXError(@schurOneMlatticeT,...
                                    k,epsilon,p,c,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
    else
      EsqP = schurOneMlatticeXError(@schurOneMlatticeP,...
                                    k,epsilon,p,c,wp,Pd,Wp);
    endif
    if isempty(wd)
      EsqD = 0;
    else
      EsqD = schurOneMlatticeXError(@schurOneMlatticedAsqdw,...
                                    k,epsilon,p,c,wd,Dd,Wd);
    endif
    Esq = EsqAsq + EsqT + EsqP + EsqD;
  elseif nargout==2
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,Nx);
    else
      [EsqAsq,gradEsqAsq] = schurOneMlatticeXError(@schurOneMlatticeAsq,...
                                                   k,epsilon,p,c,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqT = zeros(1,Nx);
    else
      [EsqT,gradEsqT] = schurOneMlatticeXError(@schurOneMlatticeT,...
                                               k,epsilon,p,c,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
      gradEsqP = zeros(1,Nx);
    else
      [EsqP,gradEsqP] = schurOneMlatticeXError(@schurOneMlatticeP,...
                                               k,epsilon,p,c,wp,Pd,Wp);
    endif
    if isempty(wd)
      EsqD = 0;
      gradEsqD = zeros(1,Nx);
    else
      [EsqD,gradEsqD] = schurOneMlatticeXError(@schurOneMlatticedAsqdw,...
                                               k,epsilon,p,c,wd,Dd,Wd);
    endif
    Esq = EsqAsq + EsqT + EsqP + EsqD;
    gradEsq = gradEsqAsq + gradEsqT + gradEsqP + gradEsqD;
  elseif nargout==3
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,Nx);
      diagHessEsqAsq = zeros(1,Nx);
    else
      [EsqAsq,gradEsqAsq,diagHessEsqAsq] = ...
        schurOneMlatticeXError(@schurOneMlatticeAsq,k,epsilon,p,c,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqT = zeros(1,Nx);
      diagHessEsqT = zeros(1,Nx);
    else
      [EsqT,gradEsqT,diagHessEsqT] = ...
        schurOneMlatticeXError(@schurOneMlatticeT,k,epsilon,p,c,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
      gradEsqP = zeros(1,Nx);
      diagHessEsqP = zeros(1,Nx);
    else
      [EsqP,gradEsqP,diagHessEsqP] = ...
        schurOneMlatticeXError(@schurOneMlatticeP,k,epsilon,p,c,wp,Pd,Wp);
    endif
    if isempty(wd)
      EsqD = 0;
      gradEsqD = zeros(1,Nx);
      diagHessEsqD = zeros(1,Nx);
    else
      [EsqD,gradEsqD,diagHessEsqD] = ...
        schurOneMlatticeXError(@schurOneMlatticedAsqdw,k,epsilon,p,c,wd,Dd,Wd);
    endif
    Esq = EsqAsq + EsqT + EsqP + EsqD;
    gradEsq = gradEsqAsq + gradEsqT + gradEsqP + gradEsqD;
    diagHessEsq = diagHessEsqAsq + diagHessEsqT + diagHessEsqP + diagHessEsqD;
  elseif nargout==4
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,Nx);
      diagHessEsqAsq = zeros(1,Nx);
      hessEsqAsq = zeros(Nx,Nx);
    else
      [EsqAsq,gradEsqAsq,diagHessEsqAsq,hessEsqAsq] = ...
          schurOneMlatticeXError(@schurOneMlatticeAsq,k,epsilon,p,c,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqT = zeros(1,Nx);
      diagHessEsqT = zeros(1,Nx);
      hessEsqT = zeros(Nx,Nx);
    else
      [EsqT,gradEsqT,diagHessEsqT,hessEsqT] = ...
          schurOneMlatticeXError(@schurOneMlatticeT,k,epsilon,p,c,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
      gradEsqP = zeros(1,Nx);
      diagHessEsqP = zeros(1,Nx);
      hessEsqP = zeros(Nx,Nx);
    else
      [EsqP,gradEsqP,diagHessEsqP,hessEsqP] = ...
          schurOneMlatticeXError(@schurOneMlatticeP,k,epsilon,p,c,wp,Pd,Wp);
    endif
    if isempty(wd)
      EsqD = 0;
      gradEsqD = zeros(1,Nx);
      diagHessEsqD = zeros(1,Nx);
      hessEsqD = zeros(Nx,Nx);
    else
      [EsqD,gradEsqD,diagHessEsqD,hessEsqD] = ...
          schurOneMlatticeXError(@schurOneMlatticedAsqdw,k,epsilon,p,c,wd,Dd,Wd);
    endif
    Esq = EsqAsq + EsqT + EsqP + EsqD;
    gradEsq = gradEsqAsq + gradEsqT + gradEsqP + gradEsqD;
    diagHessEsq = diagHessEsqAsq + diagHessEsqT + diagHessEsqP + diagHessEsqD;
    hessEsq = hessEsqAsq + hessEsqT + hessEsqP + hessEsqD;
    if ~issymmetric(hessEsq,10*eps)
      error("hessEsq is not symmetric!");
    endif 
    hessEsq=(hessEsq+(hessEsq.'))/2;
  endif
  
endfunction

function [ErrorX,gradErrorX,diagHessErrorX,hessErrorX] = ...
           schurOneMlatticeXError(pfX,k,epsilon,p,c,wx,Xd,Wx)

  if nargin~=8 || nargout>4
    print_usage(["[ErrorX,gradErrorX,diagHessErrorX,hessErrorX] = ...\n", ...
 "      schurOneMlatticeXError(pfX,k,epsilon,p,c,wx,Xd,Wx)"]);
  endif

  % Make row vectors with a single column, 
  % since by default, sum() adds over first dimension
  k=k(:);
  epsilon=epsilon(:);
  p=p(:);
  c=c(:);
  wx=wx(:);
  Xd=Xd(:);
  Wx=Wx(:);

  % Sanity checks
  Nw = length(wx);
  if length(Xd) ~= Nw
    error("length(wx)~=length(Xd)");
  endif
  if length(Wx) ~= Nw
    error("length(wx)~=length(Wx)");
  endif
  Nk=length(k);
  Nc=length(c);
  Nx=Nk+Nc;
  if Nc ~= Nk+1
    error("Nc ~= Nk+1");
  endif
  
  % X response at wx
  if nargout==1
    X=pfX(wx,k,epsilon,p,c);
    gradX=zeros(Nw,Nx);
    diagHessX=zeros(Nw,Nx);
  elseif nargout==2
    [X,gradX]=pfX(wx,k,epsilon,p,c);
    diagHessX=zeros(Nw,Nx);
  elseif nargout==3
    [X,gradX,diagHessX]=pfX(wx,k,epsilon,p,c);
  elseif nargout==4
    [X,gradX,diagHessX,hessX]=pfX(wx,k,epsilon,p,c);
  endif

  % Sanity check
  Xnf=find(any(~isfinite(X)));
  X(Xnf)=Xd(Xnf);
  gradX(Xnf,:)=0;

  % X response squared-error with trapezoidal integration.
  dwx = diff(wx);
  ErrX=Wx.*(X-Xd);
  sqErrX=ErrX.*(X-Xd);
  ErrorX=sum(dwx.*(sqErrX(1:(Nw-1))+sqErrX(2:Nw)))/2;
  if nargout==1
    return;
  endif

  % Gradient of response squared-error  
  kErrX=kron(ErrX,ones(1,Nx));
  kErrXGradX=((kErrX(1:(Nw-1),:).*gradX(1:(Nw-1),:)) + ...
                  (kErrX(2:end,:).*gradX(2:end,:)))/2;
  kdwx=kron(dwx,ones(1,Nx));
  kdwxErrXGradX=2*kdwx.*kErrXGradX;
  gradErrorX=sum(kdwxErrXGradX,1);
  if nargout==2
    return
  endif

  % For diagHessX and hessX
  %   derivativeof integralof(2*Wx*(X-Xd)'*gradX)
  % is
  %   integralof(2*Wx*gradX'*gradX + 2*Wx*(X-Xd)'*hessX). 

  % Diagonal of the Hessian of the squared-error.
  dHessXInt=(kron(Wx,ones(1,Nx)).*(gradX.^2))+(kErrX.*diagHessX);
  diagHessErrorX=sum(kdwx.*(dHessXInt(1:(Nw-1),:)+dHessXInt(2:Nw,:)),1);
  if nargout==3
    return
  endif

  % Hessian of the squared-error
  % Construct the 1st term
  WxKgradX=kron(ones(1,Nx),Wx).*gradX;
  WgradXbyRow=permute(reshape(kron(WxKgradX',ones(1,Nx)),Nx,Nx,Nw),[3,1,2]);
   gradXbyCol=permute(reshape(kron(   gradX',ones(Nx,1)),Nx,Nx,Nw),[3,1,2]);

  % Construct 2nd term
  % Create an Nw-by-Nx-by-Nx array.
  % Each element of the l'th Nx-by-Nx subarray is ErrX(l).
  hkErrX=permute(reshape(kron(ErrX',ones(Nx,Nx)),Nx,Nx,Nw),[3,1,2]);

  % Integrand
  hXint=(WgradXbyRow.*gradXbyCol)+(hkErrX.*hessX);

  % Trapezoidal integration
  kdwx=permute(reshape(kron(dwx',ones(Nx,Nx)),Nx,Nx,Nw-1),[3,1,2]);
  hessErrorX=2*reshape(sum(kdwx.*(hXint(1:(Nw-1),:,:) + ...
                                  hXint(2:Nw,:,:))/2,1),Nx,Nx);
  
endfunction
