function [Esq,gradEsq]=...
           complementaryFIRlatticeEsq(k,khat,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
% [Esq,gradEsq]=complementaryFIRlatticeEsq(k,khat,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
% Calculate the squared error response and gradients of a complementary
% FIR lattice filter. If the order of the filter polynomial is N, then there
% are N+1 lattice k and khat coefficients. This function only considers the
% response and gradients at the filter output and not the response at the
% complementary filter output.
%
% Inputs:
%   k,khat - complementary FIR lattice filter coefficients
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
%   Esq - the squared error value for k and khat
%   gradEsq - gradient of the squared error value for k and khat

% Copyright (C) 2017,2018 Robert G. Jenssen
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

  if nargout>2 || ((nargin~=5)&&(nargin~=8)&&(nargin~=11))
    print_usage("[Esq,gradEsq] = ...\n\
      complementaryFIRlatticeEsq(k,khat,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)");
  endif

  Nk=length(k);
  if length(k) ~= length(khat)
    error("length(k)~=length(khat)");
  endif
  if nargin==5
    wt=[];
    wp=[];
  elseif nargin==8
    wp=[];    
  endif
  
  if nargout==1
    if isempty(wa)
      EsqAsq = 0;
    else
      EsqAsq=complementaryFIRlatticeXError(@complementaryFIRlatticeAsq,...
                                           k,khat,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
    else
      EsqT = complementaryFIRlatticeXError(@complementaryFIRlatticeT,...
                                           k,khat,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
    else
      EsqP = complementaryFIRlatticeXError(@complementaryFIRlatticeP,...
                                           k,khat,wp,Pd,Wp);
    endif
    Esq = EsqAsq + EsqT + EsqP;
  elseif nargout==2
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,2*Nk);
    else
      [EsqAsq,gradEsqAsq] = complementaryFIRlatticeXError...
                              (@complementaryFIRlatticeAsq,k,khat,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqT = zeros(1,2*Nk);
    else
      [EsqT,gradEsqT] = complementaryFIRlatticeXError...
                          (@complementaryFIRlatticeT,k,khat,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
      gradEsqP = zeros(1,2*Nk);
    else
      [EsqP,gradEsqP] = complementaryFIRlatticeXError...
                          (@complementaryFIRlatticeP,k,khat,wp,Pd,Wp);
    endif
    Esq = EsqAsq + EsqT + EsqP;
    gradEsq = gradEsqAsq + gradEsqT + gradEsqP;
  endif
  
endfunction

function [ErrorX,gradErrorX] = ...
           complementaryFIRlatticeXError(pfX,k,khat,wx,Xd,Wx)

  if nargin~=6 || nargout>2 
    print_usage("[ErrorX,gradErrorX] = ...\n\
      complementaryFIRlatticeXError(pfX,k,khat,wx,Xd,Wx)");
  endif

  % Make row vectors with a single column, 
  % since by default, sum() adds over first dimension
  k=k(:);
  khat=khat(:);
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
  if length(k) ~= length(khat)
    error("length(k) ~= length(khat)");
  endif
  
  % X response at wx
  if nargout==1
    X=pfX(wx,k,khat);
    gradX=zeros(Nx,2*Nk);
    diagHessX=zeros(Nx,2*Nk);
  elseif nargout==2
    [X,gradX]=pfX(wx,k,khat);
    diagHessX=zeros(Nx,2*Nk);
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
  kErrX=kron(ErrX,ones(1,2*Nk));
  kErrXGradX=((kErrX(1:(Nx-1),:).*gradX(1:(Nx-1),:)) + ...
                  (kErrX(2:end,:).*gradX(2:end,:)))/2;
  kdwx=kron(dwx,ones(1,2*Nk));
  kdwxErrXGradX=2*kdwx.*kErrXGradX;
  gradErrorX=sum(kdwxErrXGradX,1);

endfunction
