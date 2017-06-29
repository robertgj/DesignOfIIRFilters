function [Esq,gradEsq,diagHessEsq]=...
           schurOneMlatticeEsq(k,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
% [Esq,gradEsq,diagHessEsq]= ...
%   schurOneMlatticeEsq(k,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
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
%   
% Outputs:
%   Esq - the squared error value at x
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

  if nargout>3 || ((nargin!=7)&&(nargin!=10)&&(nargin!=13))
    print_usage("[Esq,gradEsq,diagHessEsq] = ...\n\
      schurOneMlatticeEsq(k,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)");
  endif

  Nk=length(k);
  Nc=length(c);
  if Nc ~= (Nk+1)
    error("Expected length(k)+1==length(c)!");
  endif
  if nargin==7
    wt=[];
    wp=[];
  elseif nargin==10
    wp=[];    
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
    Esq = EsqAsq + EsqT + EsqP;
  elseif nargout==2
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,Nk+Nc);
    else
      [EsqAsq,gradEsqAsq] = schurOneMlatticeXError(@schurOneMlatticeAsq,...
                                                   k,epsilon,p,c,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqT = zeros(1,Nk+Nc);
    else
      [EsqT,gradEsqT] = schurOneMlatticeXError(@schurOneMlatticeT,...
                                               k,epsilon,p,c,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
      gradEsqP = zeros(1,Nk+Nc);
    else
      [EsqP,gradEsqP] = schurOneMlatticeXError(@schurOneMlatticeP,...
                                               k,epsilon,p,c,wp,Pd,Wp);
    endif
    Esq = EsqAsq + EsqT + EsqP;
    gradEsq = gradEsqAsq + gradEsqT + gradEsqP;
  elseif nargout==3
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,Nk+Nc);
      diagHessEsqAsq = zeros(1,Nk+Nc);
    else
      [EsqAsq,gradEsqAsq,diagHessEsqAsq] = ...
        schurOneMlatticeXError(@schurOneMlatticeAsq,k,epsilon,p,c,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqT = zeros(1,Nk+Nc);
      diagHessEsqT = zeros(1,Nk+Nc);
    else
      [EsqT,gradEsqT,diagHessEsqT] = ...
        schurOneMlatticeXError(@schurOneMlatticeT,k,epsilon,p,c,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
      gradEsqP = zeros(1,Nk+Nc);
      diagHessEsqP = zeros(1,Nk+Nc);
    else
      [EsqP,gradEsqP,diagHessEsqP] = ...
        schurOneMlatticeXError(@schurOneMlatticeP,k,epsilon,p,c,wp,Pd,Wp);
    endif
    Esq = EsqAsq + EsqT + EsqP;
    gradEsq = gradEsqAsq + gradEsqT + gradEsqP;
    diagHessEsq = diagHessEsqAsq + diagHessEsqT + diagHessEsqP;
  endif
  
endfunction

function [ErrorX,gradErrorX,diagHessErrorX] = ...
           schurOneMlatticeXError(pfX,k,epsilon,p,c,wx,Xd,Wx)

  if nargin~=8 || nargout>3 
    print_usage("[ErrorX,gradErrorX,diagHessErrorX] = ...\n\
      schurOneMlatticeXError(pfX,k,epsilon,p,c,wx,Xd,Wx)");
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
  Nx = length(wx);
  if length(Xd) ~= Nx
    error("length(wx)~=length(Xd)");
  endif
  if length(Wx) ~= Nx
    error("length(wx)~=length(Wx)");
  endif
  Nk=length(k);
  Nc=length(c);
  if Nc ~= Nk+1
    error("Nc ~= Nk+1");
  endif
  
  % X response at wx
  if nargout==1
    X=pfX(wx,k,epsilon,p,c);
    gradX=zeros(Nx,Nk+Nc);
    diagHessX=zeros(Nx,Nk+Nc);
  elseif nargout==2
    [X,gradX]=pfX(wx,k,epsilon,p,c);
    diagHessX=zeros(Nx,Nk+Nc);
  elseif nargout==3
    [X,gradX,diagHessX]=pfX(wx,k,epsilon,p,c);
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
  kErrX=kron(ErrX,ones(1,Nk+Nc));
  kErrXGradX=((kErrX(1:(Nx-1),:).*gradX(1:(Nx-1),:)) + ...
                  (kErrX(2:end,:).*gradX(2:end,:)))/2;
  kdwx=kron(dwx,ones(1,Nk+Nc));
  kdwxErrXGradX=2*kdwx.*kErrXGradX;
  gradErrorX=sum(kdwxErrXGradX,1);
  if nargout==2
    return
  endif

  % We only want the diagonal of the Hessian of the error.
  % Recall that the derivative of integralof(2*Wx*(X-Xd)'*gradX) is
  % integralof(2*Wx*gradX'*gradX + 2*Wx*(X-Xd)'*diagHessX). 
  dHessXInt=(kron(Wx,ones(1,Nk+Nc)).*(gradX.^2))+(kErrX.*diagHessX);
  diagHessErrorX=sum(kdwx.*(dHessXInt(1:(Nx-1),:)+dHessXInt(2:Nx,:)),1);

endfunction
