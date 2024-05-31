function [Esq,gradEsq,diagHessEsq,hessEsq]=...
  schurOneMPAlatticeDoublyPipelinedEsq ...
    (A1k,A2k,difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
% [Esq,gradEsq,diagHessEsq,hessEsq]= ...
%   schurOneMPAlatticeDoublyPipelinedEsq ...
%    (A1k,A2k,A2p,difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
% Inputs:
%   A1k,A2k - one-multiplier allpass section denominator multiplier coefficients
%   difference - return the response for the difference of the all-pass filters
%   wa - angular frequencies of desired amplitude-squared response in [0,pi]
%   Asqd - desired amplitude-squared response
%   Wa - amplitude-squared weight vector
%   wt - angular frequencies of desired delay response in [0,pi
%   Td - desired pass-band delay response
%   Wt - delay weight vector
%   wp - angular frequencies of desired phase response in [0,pi]
%   Pd - desired pass-band phase response
%   Wp - phase weight vector
%   
% Outputs:
%   Esq - the squared error value at the coefficients, x
%   gradEsq - gradient of the squared error value at x
%   diagHessEsq - diagonal of the Hessian of the squared error value at x
%   hessEsq - Hessian of the squared error value at x

% Copyright (C) 2024 Robert G. Jenssen
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

  if (nargout>4) || ((nargin~=6) && (nargin~=9) && (nargin~=12))
    print_usage("[Esq,gradEsq,diagHessEsq,hessEsq] = ...\n\
      schurOneMPAlatticeDoublyPipelinedEsq ...\n\
        (A1k,A2k,difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)");
  endif

  if nargin<=6
    wt=[];Td=[];Wt=[];
  endif
  if nargin<=9
    wp=[];Pd=[];Wp=[];
  endif
  
  NA1k=length(A1k);
  NA2k=length(A2k);
  
  if nargout==1
    if isempty(wa)
      EsqAsq = 0;
    else
      EsqAsq=schurOneMPAlatticeDoublyPipelinedXError ...
               (@schurOneMPAlatticeDoublyPipelinedAsq, ...
                A1k,A2k,difference,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
    else
      EsqT=schurOneMPAlatticeDoublyPipelinedXError ...
             (@schurOneMPAlatticeDoublyPipelinedT, ...
              A1k,A2k,difference,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
    else
      EsqP=schurOneMPAlatticeDoublyPipelinedXError ...
             (@schurOneMPAlatticeDoublyPipelinedP, ...
              A1k,A2k,difference,wp,Pd,Wp);
    endif
    Esq = EsqAsq+EsqT+EsqP;
  elseif nargout==2
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,NA1k+NA2k);
    else
      [EsqAsq,gradEsqAsq]=schurOneMPAlatticeDoublyPipelinedXError ...
                            (@schurOneMPAlatticeDoublyPipelinedAsq,...
                             A1k,A2k, ...
                             difference,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqT = zeros(1,NA1k+NA2k);
    else
      [EsqT,gradEsqT]=schurOneMPAlatticeDoublyPipelinedXError ...
                        (@schurOneMPAlatticeDoublyPipelinedT,...
                         A1k,A2k, ...
                         difference,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
      gradEsqP = zeros(1,NA1k+NA2k);
    else
      [EsqP,gradEsqP]=schurOneMPAlatticeDoublyPipelinedXError ...
                        (@schurOneMPAlatticeDoublyPipelinedP,...
                         A1k,A2k, ...
                         difference,wp,Pd,Wp);
    endif
    Esq = EsqAsq+EsqT+EsqP;
    gradEsq = gradEsqAsq + gradEsqT + gradEsqP;
  elseif nargout==3
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,NA1k+NA2k);
      diagHessEsqAsq = zeros(1,NA1k+NA2k);
    else
      [EsqAsq,gradEsqAsq,diagHessEsqAsq] =...
          schurOneMPAlatticeDoublyPipelinedXError ...
            (@schurOneMPAlatticeDoublyPipelinedAsq,
             A1k,A2k,difference,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqPT = zeros(1,NA1k+NA2k);
      diagHessEsqT = zeros(1,NA1k+NA2k);
    else
      [EsqT,gradEsqT,diagHessEsqT] =...
          schurOneMPAlatticeDoublyPipelinedXError ...
            (@schurOneMPAlatticeDoublyPipelinedT,
             A1k,A2k,difference,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
      gradEsqP = zeros(1,NA1k+NA2k);
      diagHessEsqP = zeros(1,NA1k+NA2k);
    else
      [EsqP,gradEsqP,diagHessEsqP] =...
          schurOneMPAlatticeDoublyPipelinedXError ...
            (@schurOneMPAlatticeDoublyPipelinedP,
             A1k,A2k,difference,wp,Pd,Wp);
    endif
    Esq = EsqAsq+EsqT+EsqP;
    gradEsq = gradEsqAsq+gradEsqT+gradEsqP;
    diagHessEsq = diagHessEsqAsq+diagHessEsqT+diagHessEsqP;
  elseif nargout==4
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,NA1k+NA2k);
      diagHessEsqAsq = zeros(1,NA1k+NA2k);
      hessEsqAsq = zeros(NA1k+NA2k,NA1k+NA2k);
    else
      [EsqAsq,gradEsqAsq,diagHessEsqAsq,hessEsqAsq] =...
          schurOneMPAlatticeDoublyPipelinedXError ...
            (@schurOneMPAlatticeDoublyPipelinedAsq,
             A1k,A2k,difference,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqT = zeros(1,NA1k+NA2k);
      diagHessEsqP = zeros(1,NA1k+NA2k);
      hessEsqT = zeros(NA1k+NA2k,NA1k+NA2k);
    else
      [EsqT,gradEsqT,diagHessEsqT,hessEsqT] =...
          schurOneMPAlatticeDoublyPipelinedXError ...
            (@schurOneMPAlatticeDoublyPipelinedT,
             A1k,A2k,difference,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
      gradEsqP = zeros(1,NA1k+NA2k);
      diagHessEsqP = zeros(1,NA1k+NA2k);
      hessEsqP = zeros(NA1k+NA2k,NA1k+NA2k);
    else
      [EsqP,gradEsqP,diagHessEsqP,hessEsqP] =...
          schurOneMPAlatticeDoublyPipelinedXError ...
            (@schurOneMPAlatticeDoublyPipelinedP,
             A1k,A2k,difference,wp,Pd,Wp);
    endif
    Esq = EsqAsq+EsqT+EsqP;
    gradEsq = gradEsqAsq+gradEsqT+gradEsqP;
    diagHessEsq = diagHessEsqAsq+diagHessEsqT+diagHessEsqP;
    hessEsq = hessEsqAsq+hessEsqT+hessEsqP;
  endif

endfunction

function [ErrorX,gradErrorX,diagHessErrorX,hessErrorX] = ...
         schurOneMPAlatticeDoublyPipelinedXError(pfX,A1k,A2k, ...
                                                 difference,wx,Xd,Wx)

  if nargin~=7 || nargout>4
    print_usage("[ErrorX,gradErrorX,diagHessErrorX,hessErrorX] = ...\n\
    schurOneMPAlatticeDoublyPipelinedXError(pfX,A1k,A2k,difference,wx,Xd,Wx)");
  endif

  % Make row vectors with a single column, 
  % since by default, sum() adds over first dimension
  A1k=A1k(:);
  NA1k=length(A1k);
  A2k=A2k(:);
  NA2k=length(A2k);
  NA12k=NA1k+NA2k;
  wx=wx(:);
  Xd=Xd(:);
  Wx=Wx(:);

  % Sanity checks
  Nw = length(wx);
  if Nw<2
    error("Nw<2");
  endif
  if length(Xd) ~= Nw
    error("length(wx)~=length(Xd)");
  endif
  if length(Wx) ~= Nw
    error("length(wx)~=length(Wx)");
  endif
  
  % X response at wx
  if nargout==1
    X=pfX(wx,A1k,A2k,difference);
  elseif nargout==2
    [X,gradX]=pfX(wx,A1k,A2k,difference);
  elseif nargout==3
    [X,gradX,diagHessX]=pfX(wx,A1k,A2k,difference); 
  elseif nargout==4
    [X,gradX,diagHessX,hessX]=pfX(wx,A1k,A2k,difference);
  endif

  % Sanity check
  Xnf=find(any(~isfinite(X)));
  X(Xnf)=Xd(Xnf);
  gradX(Xnf,:)=0;

  % X response error with trapezoidal integration.
  dwx = diff(wx);
  ErrX=Wx.*(X-Xd);
  sqErrX=ErrX.*(X-Xd);
  ErrorX=sum(dwx.*(sqErrX(1:(Nw-1))+sqErrX(2:Nw)))/2;
  if nargout==1
    return;
  endif

  % Gradient of response error  
  kErrX=kron(ErrX,ones(1,NA12k));
  kErrXGradX=((kErrX(1:(Nw-1),:).*gradX(1:(Nw-1),:)) + ...
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
  diagHessErrorX=sum(kdwx.*(dHessXInt(1:(Nw-1),:)+dHessXInt(2:Nw,:)),1);
  if nargout==3
    return
  endif

  % Hessian of the error
  rkdwx=reshape(kron(ones(NA12k*NA12k,1),dwx),Nw-1,NA12k,NA12k);
  rkErrX=reshape(kron(ones(NA12k*NA12k,1),ErrX),Nw,NA12k,NA12k);
  rkWx=reshape(kron(ones(NA12k*NA12k,1),Wx),Nw,NA12k,NA12k);

  rkgradX_r=reshape(transpose(kron(gradX,ones(1,NA12k))),NA12k,NA12k,Nw);
  rkgradX_c=reshape(transpose(kron(gradX,ones(NA12k,1))),NA12k,NA12k,Nw);
  rkgradX_2=rkgradX_r.*rkgradX_c;
  rkgradX_2=permute(rkgradX_2,[3,1,2]);

  hessErrorX=(2*rkErrX.*hessX) + (2*rkWx.*rkgradX_2);
  hessErrorX=sum(rkdwx.*(hessErrorX(1:(Nw-1),:,:)+hessErrorX(2:Nw,:,:)),1)/2;
  hessErrorX=squeeze(hessErrorX);
  
endfunction
