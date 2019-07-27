function [Esq,gradEsq,diagHessEsq]=...
           johanssonOneMlatticeEsq(fM,k0,epsilon0,k1,epsilon1,wa,Ad,Wa)
% [Esq,gradEsq,diagHessEsq]= ...
%   johanssonOneMlatticeEsq(fM,k0,epsilon0,k1,epsilon1,wa,Ad,Wa)
% Inputs:
%   fM - distinct FIR coefficients, [fM_0,...,fM_M]
%   k0,k1 - one-multiplier allpass section denominator multiplier coefficients
%   epsilon0,epsilon1 - one-multiplier allpass section sign (+1 or -1)
%   wa - angular frequencies of desired pass-band amplitude response in [0,pi]
%   Ad - desired pass-band magnitude response
%   Wa - pass-band amplitude weight vector
%   
% Outputs:
%   Esq - the squared error value at x
%   gradEsq - gradient of the squared error value at x
%   diagHessEsq - diagonal of the Hessian of the squared error value at x.

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

  if nargout>3 || (nargin~=8)
    print_usage("[Esq,gradEsq,diagHessEsq] = ...\n\
      johanssonOneMlatticeEsq(fM,k0,epsilon0,k1,epsilon1,wa,Ad,Wa);");
  endif

  if length(k0) ~= length(epsilon0)
    error("length(k0)~=length(epsilon0)!");
  endif
  if length(k1) ~= length(epsilon1)
    error("length(k1)~=length(epsilon1)!");
  endif
  if length(wa) ~= length(Ad)
    error("length(wa)~=length(Ad)!");
  endif
  if length(wa) ~= length(Wa)
    error("length(wa)~=length(Wa)!");
  endif

  if isempty(wa)
    Esq=0;
    gradEsq=zeros(1,length(fM)+length(k0)+length(k1));
    diagHessEsq=gradEsq;
  endif
  
  if nargout==1
    Esq= ...
      johanssonOneMlatticeXError(@johanssonOneMlatticeAzp, ...
                                 fM,k0,epsilon0,k1,epsilon1,wa,Ad,Wa);
  elseif nargout==2
    [Esq,gradEsq]= ...
      johanssonOneMlatticeXError(@johanssonOneMlatticeAzp, ...
                                 fM,k0,epsilon0,k1,epsilon1,wa,Ad,Wa);
  elseif nargout==3
    [Esq,gradEsq,diagHessEsq] = ...
      johanssonOneMlatticeXError(@johanssonOneMlatticeAzp, ...
                                 fM,k0,epsilon0,k1,epsilon1,wa,Ad,Wa);
  endif
  
endfunction

function [ErrorX,gradErrorX,diagHessErrorX] = ...
           johanssonOneMlatticeXError(pfX,fM,k0,epsilon0,k1,epsilon1,wx,Xd,Wx)

  if nargin~=9 || nargout>3 
    print_usage("[ErrorX,gradErrorX,diagHessErrorX] = ...\n\
      johanssonOneMlatticeXError(pfX,fM,k0,epsilon0,k1,epsilon1,wx,Xd,Wx)");
  endif

  % Sanity checks
  if length(k0) ~= length(epsilon0)
    error("length(k0)~=length(epsilon0)");
  endif
  if length(k1) ~= length(epsilon1)
    error("length(k1)~=length(epsilon1)");
  endif
  if length(wx) ~= length(Xd)
    error("length(wx)~=length(Xd)");
  endif
  if length(wx) ~= length(Wx)
    error("length(wx)~=length(Wx)");
  endif
  
  % Make row vectors with a single column, 
  % since by default, sum() adds over first dimension
  fM=fM(:)';
  k0=k0(:)';
  epsilon0=epsilon0(:)';
  k1=k1(:)';
  epsilon1=epsilon1(:)';
  wx=wx(:);
  Xd=Xd(:);
  Wx=Wx(:);

  % X response at wx
  if nargout==1
    X=pfX(wx,fM,k0,epsilon0,k1,epsilon1);
  elseif nargout==2
    [X,gradX]=pfX(wx,fM,k0,epsilon0,k1,epsilon1);
  elseif nargout==3
    [X,gradX,diagHessX]=pfX(wx,fM,k0,epsilon0,k1,epsilon1);
  endif

  % For convenience
  onesNfk0k1=ones(1,length(fM)+length(k0)+length(k1));
  Nx=length(wx);
  
  % X response error with trapezoidal integration.
  dwx = diff(wx);
  ErrX=Wx.*(X-Xd);
  sqErrX=ErrX.*(X-Xd);
  ErrorX=sum(dwx.*(sqErrX(1:(Nx-1))+sqErrX(2:Nx)))/2;
  if nargout==1
    return;
  endif

  % Gradient of response error  
  kErrX=kron(ErrX,onesNfk0k1);
  kErrXGradX=((kErrX(1:(Nx-1),:).*gradX(1:(Nx-1),:)) + ...
              (kErrX(2:end,:).*gradX(2:end,:)))/2;
  kdwx=kron(dwx,onesNfk0k1);
  kdwxErrXGradX=2*kdwx.*kErrXGradX;
  gradErrorX=sum(kdwxErrXGradX,1);
  if nargout==2
    return
  endif

  % We only want the diagonal of the Hessian of the error.
  % Recall that the derivative of integralof(2*Wx*(X-Xd)'*gradX) is
  % integralof(2*Wx*gradX'*gradX + 2*Wx*(X-Xd)'*diagHessX). 
  dHessXInt=(kron(Wx,onesNfk0k1).*(gradX.^2))+(kErrX.*diagHessX);
  diagHessErrorX=sum(kdwx.*(dHessXInt(1:(Nx-1),:)+dHessXInt(2:Nx,:)),1);

endfunction
