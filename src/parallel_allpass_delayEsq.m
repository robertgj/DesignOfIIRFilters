function [Esq,gradEsq,diagHessEsq]=...
           parallel_allpass_delayEsq(a,V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt)
% [Esq,gradEsq,diagHessEsq]=
%   parallel_allpass_delayEsq(a,V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt)
% Inputs:
%   a - coefficient vector in the form:
%         [ Rp(1:V) rp(1:(Q/2)) thetap(1:(Q/2)) ]
%         where Rp are the radiuses of the real poles of the allpass
%         filter and {rp,thetap} the polar coordinates of a pair
%         of complex conjugate poles of the allpass filter.
%   V - number of real poles of the allpass filter 
%   Q - number of complex poles of the allpass filter
%   R - decimation factor. The poles, pk, are roots of [z^R-pk].
%   DD - samples of delay in the delay branch
%   wa - angular frequencies of desired pass-band squared amplitude response
%        in [0,pi]. 
%   Asqd - desired pass-band squared amplitude response
%   Wa - pass-band squared amplitude response weight at each frequency
%   wt - angular frequencies of desired pass-band group delay response
%        in [0,pi]. 
%   Td - desired pass-band group delay response
%   Wt - pass-band group delay response weight at each frequency
%   
% Outputs:
%   Esq - the squared error value at a
%   gradEsq - gradient of the squared error value at a
%   diagHessEsq - diagonal of the Hessian of the squared error value at a

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

  if nargout>3 || ((nargin!=8)&&(nargin!=11))
    print_usage("[Esq,gradEsq,diagHessEsq] = ...\n\
      parallel_allpass_delayEsq(a,V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt)");
  endif

  Na=length(a);
  if Na ~= (V+Q)
    error("Expected length(a)==V+Q!");
  endif
  if nargin==8
    wt=[];
  endif
  
  if nargout==1
    if isempty(wa)
      EsqAsq = 0;
    else
      EsqAsq=parallel_allpass_delayXError(@parallel_allpass_delayAsq,...
                                    a,V,Q,R,DD,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
    else
      EsqT = parallel_allpass_delayXError(@parallel_allpass_delayT,...
                                    a,V,Q,R,DD,wt,Td,Wt);
    endif
    Esq = EsqAsq + EsqT;
  elseif nargout==2
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,Na);
    else
      [EsqAsq,gradEsqAsq] = ...
        parallel_allpass_delayXError(@parallel_allpass_delayAsq, ...
                                     a,V,Q,R,DD,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqT = zeros(1,Na);
    else
      [EsqT,gradEsqT] = ...
        parallel_allpass_delayXError(@parallel_allpass_delayT, ...
                                     a,V,Q,R,DD,wt,Td,Wt);
    endif
    Esq = EsqAsq + EsqT;
    gradEsq = gradEsqAsq + gradEsqT;
  elseif nargout==3
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,Na);
      diagHessEsqAsq = zeros(1,Na);
    else
      [EsqAsq,gradEsqAsq,diagHessEsqAsq] = ...
        parallel_allpass_delayXError(@parallel_allpass_delayAsq, ...
                                     a,V,Q,R,DD,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqT = zeros(1,Na);
      diagHessEsqT = zeros(1,Na);
    else
      [EsqT,gradEsqT,diagHessEsqT] = ...
        parallel_allpass_delayXError(@parallel_allpass_delayT, ...
                                     a,V,Q,R,DD,wt,Td,Wt);
    endif
    Esq = EsqAsq + EsqT;
    gradEsq = gradEsqAsq + gradEsqT;
    diagHessEsq = diagHessEsqAsq + diagHessEsqT;
  endif
  
endfunction

function [ErrorX,gradErrorX,diagHessErrorX] = ...
           parallel_allpass_delayXError(pfX,a,V,Q,R,DD,wx,Xd,Wx)

  if nargin~=9 || nargout>3 
    print_usage("[ErrorX,gradErrorX,diagHessErrorX] = ...\n\
      parallel_allpass_delayXError(pfX,a,V,Q,R,DD,wx,Xd,Wx)");
  endif

  % Make row vectors with a single column, 
  % since by default, sum() adds over first dimension
  a=a(:);
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
  Na=length(a);
  if Na ~= V+Q
    error("Na ~= V+Q");
  endif
  
  % X response at wx
  if nargout==1
    X=pfX(wx,a,V,Q,R,DD);
    gradX=zeros(Na,Na);
    diagHessX=zeros(Na,Na);
  elseif nargout==2
    [X,gradX]=pfX(wx,a,V,Q,R,DD);
    diagHessX=zeros(Na,Na);
  elseif nargout==3
    [X,gradX,diagHessX]=pfX(wx,a,V,Q,R,DD);
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
  kErrX=kron(ErrX,ones(1,Na));
  kErrXGradX=((kErrX(1:(Nx-1),:).*gradX(1:(Nx-1),:)) + ...
                  (kErrX(2:end,:).*gradX(2:end,:)))/2;
  kdwx=kron(dwx,ones(1,Na));
  kdwxErrXGradX=2*kdwx.*kErrXGradX;
  gradErrorX=sum(kdwxErrXGradX,1);
  if nargout==2
    return
  endif

  % We only want the diagonal of the Hessian of the error.
  % Recall that the derivative of integralof(2*Wx*(X-Xd)'*gradX) is
  % integralof(2*Wx*gradX'*gradX + 2*Wx*(X-Xd)'*diagHessX). 
  dHessXInt=(kron(Wx,ones(1,Na)).*(gradX.^2))+(kErrX.*diagHessX);
  diagHessErrorX=sum(kdwx.*(dHessXInt(1:(Nx-1),:)+dHessXInt(2:Nx,:)),1);

endfunction
