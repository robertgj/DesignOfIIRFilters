function [Esq,gradEsq,diagHessEsq]=...
  schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
                      difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
% [Esq,gradEsq,diagHessEsq]=...
%   schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
%                       difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
% Inputs:
%   A1s20,A1s00,A1s02,A1s22 - filter 1 Schur all-pass normalised-scaled lattice 
%   A2s20,A2s00,A2s02,A2s22 - filter 2 Schur all-pass normalised-scaled lattice 
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

% Outputs:
%   Esq - the squared error value at x
%   gradEsq - gradient of the squared error value at x
%   diagHessEsq - diagonal of the Hessian of the squared error value at x.

% Copyright (C) 2022-2025 Robert G. Jenssen
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

  if nargout>3 || ((nargin~=12)&&(nargin~=15)&&(nargin~=18))
    print_usage(["[Esq,gradEsq,diagHessEsq] = ...\n", ...
 "      schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...\n", ...
 "                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp) \n", ...
 "[Esq,gradEsq,diagHessEsq] = ...\n", ...
 "      schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...\n", ...
 "                          difference,wa,Asqd,Wa,wt,Td) \n", ...
 "[Esq,gradEsq,diagHessEsq] = ...\n", ...
 "      schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...\n", ...
 "                          difference,wa,Asqd,Wa)"]);
  endif

  if length(A1s20) ~= length(A1s00)
    error("length(A1s20) ~= length(A1s00)");
  endif
  if length(A1s20) ~= length(A1s02)
    error("length(A1s20) ~= length(A1s02)");
  endif
  if length(A1s20) ~= length(A1s22)
    error("length(A1s20) ~= length(A1s22)");
  endif
  if length(A2s20) ~= length(A2s00)
    error("length(A2s20) ~= length(A2s00)");
  endif
  if length(A2s20) ~= length(A2s02)
    error("length(A2s20) ~= length(A2s02)");
  endif
  if length(A2s20) ~= length(A2s22)
    error("length(A2s20) ~= length(A2s22)");
  endif
  
  if nargin==12
    wt=[];
    wp=[];
  elseif nargin==15
    wp=[];    
  endif

  A1Ns=length(A1s20);
  A2Ns=length(A2s20);
  NA=A1Ns+A2Ns;
  
  if nargout==1
    if (isempty(wa))
      EsqAsq = 0;
    else
      EsqAsq=schurNSPAlatticeErrorX ...
               (@schurNSPAlatticeAsq, ...
                A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,...
                difference,wa,Asqd,Wa);
    endif
    if (isempty(wt))
      EsqT=0;
    else
      EsqT=schurNSPAlatticeErrorX ...
               (@schurNSPAlatticeT, ...
                A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,...
                difference,wt,Td,Wt);
    endif
    if (isempty(wp))
      EsqP=0;
    else
      EsqP=schurNSPAlatticeErrorX ...
               (@schurNSPAlatticeP, ...
                A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,...
                difference,wp,Pd,Wp);
    endif
    Esq=EsqAsq + EsqT + EsqP;
  elseif nargout==2
    if (isempty(wa))
      EsqAsq=0;
      gradEsqAsq=zeros(1,4*NA);
    else
      [EsqAsq,gradEsqAsq]=schurNSPAlatticeErrorX ...
               (@schurNSPAlatticeAsq, ...
                A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,...
                difference,wa,Asqd,Wa);
    endif
    if (isempty(wt))
      EsqT=0;
      gradEsqT=zeros(1,4*NA);
    else
      [EsqT,gradEsqT]=schurNSPAlatticeErrorX ...
               (@schurNSPAlatticeT, ...
                A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,...
                difference,wt,Td,Wt);
    endif
    if (isempty(wp))
      EsqP=0;
      gradEsqP=zeros(1,4*NA);
    else
      [EsqP,gradEsqP]=schurNSPAlatticeErrorX ...
               (@schurNSPAlatticeP, ...
                A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,...
                difference,wp,Pd,Wp);
    endif
    Esq=EsqAsq + EsqT + EsqP;
    gradEsq=gradEsqAsq + gradEsqT + gradEsqP;
  elseif nargout==3
    if isempty(wa)
      EsqAsq=0;
      gradEsqAsq=zeros(1,4*NA);
      diagHessEsqAsq=zeros(1,4*NA);
    else
      [EsqAsq,gradEsqAsq,diagHessEsqAsq]=schurNSPAlatticeErrorX ...
               (@schurNSPAlatticeAsq, ...
                A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,...
                difference,wa,Asqd,Wa);
    endif
    if (isempty(wt))
      EsqT=0;
      gradEsqT=zeros(1,4*NA);
      diagHessEsqT=zeros(1,4*NA);
    else
      [EsqT,gradEsqT,diagHessEsqT]=schurNSPAlatticeErrorX ...
               (@schurNSPAlatticeT, ...
                A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,...
                difference,wt,Td,Wt);
    endif 
    if (isempty(wp))
      EsqP=0;
      gradEsqP=zeros(1,4*NA);
      diagHessEsqP=zeros(1,4*NA);
    else
      [EsqP,gradEsqP,diagHessEsqP]=schurNSPAlatticeErrorX ...
               (@schurNSPAlatticeP, ...
                A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,...
                difference,wp,Pd,Wp);
    endif
    Esq=EsqAsq + EsqT + EsqP;
    gradEsq=gradEsqAsq + gradEsqT + gradEsqP;
    diagHessEsq=diagHessEsqAsq + diagHessEsqT + diagHessEsqP;
  endif

endfunction

function [ErrorX,gradErrorX,diagHessErrorX]=schurNSPAlatticeErrorX ...
  (pfX,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,difference,wx,Xd,Wx)

  if nargin~=13 || nargout>3 
    print_usage ...
      (["[ErrorX,gradErrorX,diagHessErrorX]=schurNSPAlatticeErrorX ...\n", ...
 "  (pfX,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,difference,wx,Xd,Wx)"]);
  endif

  % Make row vectors with a single column, 
  % since by default, sum() adds over first dimension
  A1s20=A1s20(:);A1s00=A1s00(:);A1s02=A1s02(:);A1s22=A1s22(:);
  A2s20=A2s20(:);A2s00=A2s00(:);A2s02=A2s02(:);A2s22=A2s22(:);
  wx=wx(:);Xd=Xd(:);Wx=Wx(:);

  % Sanity checks
  A1Ns=length(A1s20);
  A2Ns=length(A2s20);
  NA=A1Ns+A2Ns;
  Nx=length(wx);
  if length(Xd) ~= Nx
    error("length(wx)~=length(Xd)");
  endif
  if length(Wx) ~= Nx
    error("length(wx)~=length(Wx)");
  endif
  
  % X response at wx
  if nargout==1
    X=pfX(wx,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,difference);
    gradX=zeros(Nx,4*NA);
    diagHessX=zeros(Nx,4*NA);
  elseif nargout==2
    [X,gradX]= ...
      pfX(wx,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,difference);
    diagHessX=zeros(Nx,4*NA);
  elseif nargout==3
    [X,gradX,diagHessX]= ...
      pfX(wx,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,difference);
  endif

  % Sanity check
  Xnf=find(any(~isfinite(X)));
  X(Xnf)=Xd(Xnf);
  gradX(Xnf,:)=0;

  % X response error with trapezoidal integration.
  dwx=diff(wx);
  ErrX=Wx.*(X-Xd);
  sqErrX=ErrX.*(X-Xd);
  ErrorX=sum(dwx.*(sqErrX(1:(Nx-1))+sqErrX(2:Nx)))/2;
  if nargout==1
    return;
  endif

  % Gradient of response error  
  kErrX=kron(ErrX,ones(1,4*NA));
  kErrXGradX=((kErrX(1:(Nx-1),:).*gradX(1:(Nx-1),:)) + ...
              (kErrX(2:end,:).*gradX(2:end,:)))/2;
  kdwx=kron(dwx,ones(1,4*NA));
  kdwxErrXGradX=2*kdwx.*kErrXGradX;
  gradErrorX=sum(kdwxErrXGradX,1);
  if nargout==2
    return
  endif

  % We only want the diagonal of the Hessian of the error.
  % Recall that the derivative of integralof(2*Wx*(X-Xd)'*gradX) is
  % integralof(2*Wx*gradX'*gradX + 2*Wx*(X-Xd)'*diagHessX). 
  dHessXInt=(kron(Wx,ones(1,4*NA)).*(gradX.^2))+(kErrX.*diagHessX);
  diagHessErrorX=sum(kdwx.*(dHessXInt(1:(Nx-1),:)+dHessXInt(2:Nx,:)),1);
endfunction
