function [Esq,gradEsq,diagHessEsq]=...
         schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                               wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
% [Esq,gradEsq,diagHessEsq]= ...
%   schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
%                         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
% Inputs:
%   A1k,A2k - one-multiplier allpass section denominator multiplier coefficients
%   A1epsilon,A2epsion - one-multiplier allpass section sign coefficients
%   A1p,A2p - internal state scaling factors
%   wa - angular frequencies of desired pass-band amplitude response in [0,pi]
%   Asqd - desired pass-band magnitude-squared response
%   Wa - pass-band amplitude weight vector
%   wt - angular frequencies of the desired group delay response
%   Td - desired group delay response 
%   Wt - group delay weight vector
%   wp - angular frequencies of the desired phase response
%   Pd - desired phase response 
%   Wp - phase weight vector
%   
% Outputs:
%   Esq - the squared error value at the coefficients, x
%   gradEsq - gradient of the squared error value at x
%   diagHessEsq - diagonal of the Hessian of the squared error value at x.

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

  if nargout>3 || ((nargin!=9)&&(nargin!=12)&&(nargin!=15))
    print_usage("[Esq,gradEsq,diagHessEsq] = ...\n\
      schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...\n\
                            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)");
  endif

  NA1k=length(A1k);
  NA2k=length(A2k);
  if nargin==9
    wt=[];
    wp=[];
  elseif nargin==12
    wp=[];    
  endif
  
  if nargout==1
    if isempty(wa)
      EsqAsq = 0;
    else
      EsqAsq=schurOneMPAlatticeXError(@schurOneMPAlatticeAsq,...
                                      A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                      wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
    else
      EsqT = schurOneMPAlatticeXError(@schurOneMPAlatticeT,...
                                      A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                      wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
    else
      EsqP = schurOneMPAlatticeXError(@schurOneMPAlatticeP,...
                                      A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                      wp,Pd,Wp);
    endif
    Esq = EsqAsq + EsqT + EsqP;
  elseif nargout==2
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,NA1k+NA2k);
    else
      [EsqAsq,gradEsqAsq] = ...
        schurOneMPAlatticeXError(@schurOneMPAlatticeAsq,...
                                 A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqT = zeros(1,NA1k+NA2k);
    else
      [EsqT,gradEsqT] = ...
        schurOneMPAlatticeXError(@schurOneMPAlatticeT,...
                                 A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
      gradEsqP = zeros(1,NA1k+NA2k);
    else
      [EsqP,gradEsqP] = ...
        schurOneMPAlatticeXError(@schurOneMPAlatticeP,...
                                 A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,wp,Pd,Wp);
    endif
    Esq = EsqAsq + EsqT + EsqP;
    gradEsq = gradEsqAsq + gradEsqT + gradEsqP;
  elseif nargout==3
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,NA1k+NA2k);
      diagHessEsqAsq = zeros(1,NA1k+NA2k);
    else
      [EsqAsq,gradEsqAsq,diagHessEsqAsq] = ...
        schurOneMPAlatticeXError(@schurOneMPAlatticeAsq, ...
                                 A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqT = zeros(1,NA1k+NA2k);
      diagHessEsqT = zeros(1,NA1k+NA2k);
    else
      [EsqT,gradEsqT,diagHessEsqT] = ...
        schurOneMPAlatticeXError(@schurOneMPAlatticeT, ...
                                 A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
      gradEsqP = zeros(1,NA1k+NA2k);
      diagHessEsqP = zeros(1,NA1k+NA2k);
    else
      [EsqP,gradEsqP,diagHessEsqP] = ...
        schurOneMPAlatticeXError(@schurOneMPAlatticeP, ...
                                 A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,wp,Pd,Wp);
    endif
    Esq = EsqAsq + EsqT + EsqP;
    gradEsq = gradEsqAsq + gradEsqT + gradEsqP;
    diagHessEsq = diagHessEsqAsq + diagHessEsqT + diagHessEsqP;
  endif
  
endfunction

function [ErrorX,gradErrorX,diagHessErrorX] = ...
  schurOneMPAlatticeXError(pfX,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,wx,Xd,Wx)

  if nargin~=10 || nargout>3 
    print_usage("[ErrorX,gradErrorX,diagHessErrorX] = ...\n\
    schurOneMPAlatticeXError(pfX,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,wx,Xd,Wx)");
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
    X=pfX(wx,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p);
    gradX=zeros(Nx,NA1k+NA2k);
    diagHessX=zeros(Nx,NA1k+NA2k);
  elseif nargout==2
    [X,gradX]=pfX(wx,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p);
    diagHessX=zeros(Nx,NA1k+NA2k);
  elseif nargout==3
    [X,gradX,diagHessX]=pfX(wx,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p);
  endif

  % X response error with trapezoidal integration.
  dwx = diff(wx);
  ErrX=Wx.*(X-Xd);
  sqErrX=ErrX.*(X-Xd);
  ErrorX=sum(dwx.*(sqErrX(1:(Nx-1))+sqErrX(2:Nx)))/2;
  if nargout==1
    return;
  endif

  % Gradient of response error  
  kErrX=kron(ErrX,ones(1,NA1k+NA2k));
  kErrXGradX=((kErrX(1:(Nx-1),:).*gradX(1:(Nx-1),:)) + ...
                  (kErrX(2:end,:).*gradX(2:end,:)))/2;
  kdwx=kron(dwx,ones(1,NA1k+NA2k));
  kdwxErrXGradX=2*kdwx.*kErrXGradX;
  gradErrorX=sum(kdwxErrXGradX,1);
  if nargout==2
    return
  endif

  % We only want the diagonal of the Hessian of the error.
  % Recall that the derivative of integralof(2*Wx*(X-Xd)'*gradX) is
  % integralof(2*Wx*gradX'*gradX + 2*Wx*(X-Xd)'*diagHessX). 
  dHessXInt=(kron(Wx,ones(1,NA1k+NA2k)).*(gradX.^2))+(kErrX.*diagHessX);
  diagHessErrorX=sum(kdwx.*(dHessXInt(1:(Nx-1),:)+dHessXInt(2:Nx,:)),1);

endfunction
