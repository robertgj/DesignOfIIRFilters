function [Esq,gradEsq]=directFIRnonsymmetricEsq(h,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
% [Esq,gradEsq]=directFIRnonsymmetricEsq(h,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
% Inputs:
%   h - coefficients of a nonsymmetric FIR filter polynomial
%   wa - angular frequencies of the squared amplitude
%   Asqd - desired squared amplitude response
%   Wa - squared amplitude weighting function
%   wt - angular frequencies of the group delay
%   Td - desired group delay response
%   Wt - group delay weighting function
%   wp - angular frequencies of the phase
%   Pd - desired phase response
%   Wp - phase weighting function
%
% Outputs:
%   Esq - the squared error value at h, a scalar
%   gradEsq - gradient of the squared error value at h, a row vector
  
% Copyright (C) 2021 Robert G. Jenssen
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

  if (nargout > 2) || ((nargin ~= 4) && (nargin ~= 7) && (nargin ~= 10))
    print_usage ...
      ("[Esq,gradEsq]=directFIRnonsymmetricEsq(h,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)");
  endif

  if isempty(h)
    Esq=[];gradEsq=[];
    return;
  endif
  
  if nargout==1
    EsqAsq=directFIRnonsymmetricXError(@directFIRnonsymmetricAsq,h,wa,Asqd,Wa);
    EsqT=directFIRnonsymmetricXError(@directFIRnonsymmetricT,h,wt,Td,Wt);
    EsqP=directFIRnonsymmetricXError(@directFIRnonsymmetricP,h,wp,Pd,Wp);
    Esq = EsqAsq + EsqT + EsqP;
  else
    [EsqAsq,gradEsqAsq] = ...
      directFIRnonsymmetricXError(@directFIRnonsymmetricAsq,h,wa,Asqd,Wa);
    [EsqT,gradEsqT] = ...
      directFIRnonsymmetricXError(@directFIRnonsymmetricT,h,wt,Td,Wt);
    [EsqP,gradEsqP] = ...
      directFIRnonsymmetricXError(@directFIRnonsymmetricP,h,wp,Pd,Wp);
    Esq = EsqAsq + EsqT + EsqP;
    gradEsq = gradEsqAsq + gradEsqT + gradEsqP;
  endif

endfunction

function [ErrorX,gradErrorX] = directFIRnonsymmetricXError(pfX,h,wx,Xd,Wx)

  if nargin~=5 || nargout>2 
    print_usage ...
      ("[ErrorX,gradErrorX]=directFIRnonsymmetricXError(pfX,h,wx,Xd,Wx)");
  endif

  if isempty(wx)
    ErrorX=0;
    gradErrorX=zeros(1,length(h));
    return;
  endif
  
  % Sanity checks
  Nx = length(wx);
  if length(Xd) ~= Nx
    error("length(wx)~=length(Xd)");
  endif
  if length(Wx) ~= Nx
    error("length(wx)~=length(Wx)");
  endif
  
  N=length(h)-1;
  h=h(:)';
  wx=wx(:);
  Xd=Xd(:);
  Wx=Wx(:);

  % X response at wx
  if nargout==1
    X=pfX(wx,h);
    gradX=zeros(Nx,N+1);
  elseif nargout==2
    [X,gradX]=pfX(wx,h);
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
  kErrX=kron(ErrX,ones(1,N+1));
  kErrXGradX=((kErrX(1:(Nx-1),:).*gradX(1:(Nx-1),:)) + ...
              (kErrX(2:end,:).*gradX(2:end,:)))/2;
  kdwx=kron(dwx,ones(1,N+1));
  kdwxErrXGradX=2*kdwx.*kErrXGradX;
  gradErrorX=sum(kdwxErrXGradX,1);
  
endfunction
