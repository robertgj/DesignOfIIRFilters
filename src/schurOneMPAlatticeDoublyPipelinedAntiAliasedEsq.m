function [Esq,gradEsq,diagHessEsq,hessEsq]=...
  schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
    (A1k,A2k,difference,B1k,B2k,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd)
% [Esq,gradEsq,diagHessEsq,hessEsq]= ...
%   schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
%    (A1k,A2k,A2p,difference,B1k,B2k,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd)
% Inputs:
%   A1k,A2k - one-multiplier doubly-pipelined all-pass lattice coefficients
%   difference - return the response for the difference of the all-pass filters
%   B1k,B2k - anti-aliasing one-multiplier allpass lattice coefficients
%   wa - angular frequencies of desired amplitude-squared response in [0,pi]
%   Asqd - desired amplitude-squared response
%   Wa - amplitude-squared weight vector
%   wt - angular frequencies of desired delay response in [0,pi
%   Td - desired delay response
%   Wt - delay weight vector
%   wp - angular frequencies of desired phase response in [0,pi]
%   Pd - desired phase response
%   Wp - phase weight vector
%   wd - angular frequencies of desired dAsqdw response in [0,pi]
%   Dd - desired dAsqdw response
%   Wd - dAsqdw weight vector
%   
% Outputs:
%   Esq - the squared error value wrt the coefficients, k=[Alk,A2k,B1k,B2k]
%   gradEsq - gradient of Esq wrt k
%   diagHessEsq - diagonal of the Hessian of Esq wrt k
%   hessEsq - Hessian of Esq wrt k

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

  if (nargout>4) || ((nargin~=8) && (nargin~=11) && (nargin~=14) && (nargin~=17))
    print_usage("[Esq,gradEsq,diagHessEsq,hessEsq] = ...\n\
      schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...\n\
        (A1k,A2k,difference,B1k,B2k,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd)");
  endif

  if nargin<=6
    wt=[];Td=[];Wt=[];
  endif
  if nargin<=9
    wp=[];Pd=[];Wp=[];
  endif
  if nargin<=12
    wd=[];Dd=[];Wd=[];
  endif
  
  A1k=A1k(:);
  A2k=A2k(:);
  B1k=B1k(:);
  B2k=B2k(:);
  NA1k=length(A1k);
  NA2k=length(A2k); 
  NB1k=length(B1k);
  NB2k=length(B2k);
  NAk=NA1k+NA2k;
  NBk=NB1k+NB2k;
  Nk=NAk+NBk;

  if nargout==1
    if isempty(wa)
      EsqAsq = 0;
    else
      EsqAsq=schurOneMPAlatticeDoublyPipelinedAntiAliasedXError ...
               (@schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq, ...
                A1k,A2k,difference,B1k,B2k,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
    else
      EsqT=schurOneMPAlatticeDoublyPipelinedAntiAliasedXError ...
             (@schurOneMPAlatticeDoublyPipelinedAntiAliasedT, ...
              A1k,A2k,difference,B1k,B2k,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
    else
      EsqP=schurOneMPAlatticeDoublyPipelinedAntiAliasedXError ...
             (@schurOneMPAlatticeDoublyPipelinedAntiAliasedP, ...
              A1k,A2k,difference,B1k,B2k,wp,Pd,Wp);
    endif
    if isempty(wd)
      EsqD = 0;
    else
      EsqD=schurOneMPAlatticeDoublyPipelinedAntiAliasedXError ...
             (@schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw, ...
              A1k,A2k,difference,B1k,B2k,wd,Dd,Wd);
    endif
    Esq = EsqAsq+EsqT+EsqP+EsqD;
  elseif nargout==2
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,Nk);
    else
      [EsqAsq,gradEsqAsq]=schurOneMPAlatticeDoublyPipelinedAntiAliasedXError ...
                            (@schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq,...
                             A1k,A2k,difference,B1k,B2k,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqT = zeros(1,Nk);
    else
      [EsqT,gradEsqT]=schurOneMPAlatticeDoublyPipelinedAntiAliasedXError ...
                        (@schurOneMPAlatticeDoublyPipelinedAntiAliasedT,...
                         A1k,A2k,difference,B1k,B2k,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
      gradEsqP = zeros(1,Nk);
    else
      [EsqP,gradEsqP]=schurOneMPAlatticeDoublyPipelinedAntiAliasedXError ...
                        (@schurOneMPAlatticeDoublyPipelinedAntiAliasedP,...
                         A1k,A2k,difference,B1k,B2k,wp,Pd,Wp);
    endif
    if isempty(wd)
      EsqD = 0;
      gradEsqD = zeros(1,Nk);
    else
      [EsqD,gradEsqD]=schurOneMPAlatticeDoublyPipelinedAntiAliasedXError ...
                        (@schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw,...
                         A1k,A2k,difference,B1k,B2k,wd,Dd,Wd);
    endif
    Esq = EsqAsq+EsqT+EsqP+EsqD;
    gradEsq = gradEsqAsq + gradEsqT + gradEsqP + gradEsqD;
  elseif nargout==3
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,Nk);
      diagHessEsqAsq = zeros(1,Nk);
    else
      [EsqAsq,gradEsqAsq,diagHessEsqAsq] =...
          schurOneMPAlatticeDoublyPipelinedAntiAliasedXError ...
            (@schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq,
             A1k,A2k,difference,B1k,B2k,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqT = zeros(1,Nk);
      diagHessEsqT = zeros(1,Nk);
    else
      [EsqT,gradEsqT,diagHessEsqT] =...
          schurOneMPAlatticeDoublyPipelinedAntiAliasedXError ...
            (@schurOneMPAlatticeDoublyPipelinedAntiAliasedT,
             A1k,A2k,difference,B1k,B2k,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
      gradEsqP = zeros(1,Nk);
      diagHessEsqP = zeros(1,Nk);
    else
      [EsqP,gradEsqP,diagHessEsqP] =...
          schurOneMPAlatticeDoublyPipelinedAntiAliasedXError ...
            (@schurOneMPAlatticeDoublyPipelinedAntiAliasedP,
             A1k,A2k,difference,B1k,B2k,wp,Pd,Wp);
    endif
    if isempty(wd)
      EsqD = 0;
      gradEsqD = zeros(1,Nk);
      diagHessEsqD = zeros(1,Nk);
    else
      [EsqD,gradEsqD,diagHessEsqD] =...
          schurOneMPAlatticeDoublyPipelinedAntiAliasedXError ...
            (@schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw,
             A1k,A2k,difference,B1k,B2k,wd,Dd,Wd);
    endif
    Esq = EsqAsq+EsqT+EsqP+EsqD;
    gradEsq = gradEsqAsq+gradEsqT+gradEsqP+gradEsqD;
    diagHessEsq = diagHessEsqAsq+diagHessEsqT+diagHessEsqP+diagHessEsqD;
  elseif nargout==4
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,Nk);
      diagHessEsqAsq = zeros(1,Nk);
      hessEsqAsq = zeros(Nk,Nk);
    else
      [EsqAsq,gradEsqAsq,diagHessEsqAsq,hessEsqAsq] =...
          schurOneMPAlatticeDoublyPipelinedAntiAliasedXError ...
            (@schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq,
             A1k,A2k,difference,B1k,B2k,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqT = zeros(1,Nk);
      diagHessEsqT = zeros(1,Nk);
      hessEsqT = zeros(Nk,Nk);
    else
      [EsqT,gradEsqT,diagHessEsqT,hessEsqT] =...
          schurOneMPAlatticeDoublyPipelinedAntiAliasedXError ...
            (@schurOneMPAlatticeDoublyPipelinedAntiAliasedT,
             A1k,A2k,difference,B1k,B2k,wt,Td,Wt);
    endif
    if isempty(wp)
      EsqP = 0;
      gradEsqP = zeros(1,Nk);
      diagHessEsqP = zeros(1,Nk);
      hessEsqP = zeros(Nk,Nk);
    else
      [EsqP,gradEsqP,diagHessEsqP,hessEsqP] =...
          schurOneMPAlatticeDoublyPipelinedAntiAliasedXError ...
            (@schurOneMPAlatticeDoublyPipelinedAntiAliasedP,
             A1k,A2k,difference,B1k,B2k,wp,Pd,Wp);
    endif
    if isempty(wd)
      EsqD = 0;
      gradEsqD = zeros(1,Nk);
      diagHessEsqD = zeros(1,Nk);
      hessEsqD = zeros(Nk,Nk);
    else
      [EsqD,gradEsqD,diagHessEsqD,hessEsqD] =...
          schurOneMPAlatticeDoublyPipelinedAntiAliasedXError ...
            (@schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw,
             A1k,A2k,difference,B1k,B2k,wd,Dd,Wd);
    endif
    Esq = EsqAsq+EsqT+EsqP+EsqD;
    gradEsq = gradEsqAsq+gradEsqT+gradEsqP+gradEsqD;
    diagHessEsq = diagHessEsqAsq+diagHessEsqT+diagHessEsqP+diagHessEsqD;
    hessEsq = hessEsqAsq+hessEsqT+hessEsqP+hessEsqD;
  endif

endfunction

function [ErrorX,gradErrorX,diagHessErrorX,hessErrorX] = ...
  schurOneMPAlatticeDoublyPipelinedAntiAliasedXError ...
    (pfX,A1k,A2k,difference,B1k,B2k,wx,Xd,Wx)

  if nargin~=9 || nargout>4
    print_usage("[ErrorX,gradErrorX,diagHessErrorX,hessErrorX] = ...\n\
    schurOneMPAlatticeDoublyPipelinedAntiAliasedXError ...\n\
      (pfX,A1k,A2k,difference,B1k,B2k,wx,Xd,Wx)");
  endif

  % Make row vectors with a single column, 
  % since by default, sum() adds over first dimension
  A1k=A1k(:);
  A2k=A2k(:);
  B1k=B1k(:);
  B2k=B2k(:);
  NA1k=length(A1k);
  NA2k=length(A2k); 
  NB1k=length(B1k);
  NB2k=length(B2k);
  NAk=NA1k+NA2k;
  NBk=NB1k+NB2k;
  Nk=NAk+NBk;
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
    X=pfX(wx,A1k,A2k,difference,B1k,B2k);
  elseif nargout==2
    [X,gradX]=pfX(wx,A1k,A2k,difference,B1k,B2k);
  elseif nargout==3
    [X,gradX,diagHessX]=pfX(wx,A1k,A2k,difference,B1k,B2k); 
  elseif nargout==4
    [X,gradX,diagHessX,hessX]=pfX(wx,A1k,A2k,difference,B1k,B2k);
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
  kErrX=kron(ErrX,ones(1,Nk));
  kErrXGradX=((kErrX(1:(Nw-1),:).*gradX(1:(Nw-1),:)) + ...
                  (kErrX(2:end,:).*gradX(2:end,:)))/2;
  kdwx=kron(dwx,ones(1,Nk));
  kdwxErrXGradX=2*kdwx.*kErrXGradX;
  gradErrorX=sum(kdwxErrXGradX,1);
  if nargout==2
    return
  endif

  % We only want the diagonal of the Hessian of the squared-error.
  % Recall that the derivative of integralof(2*Wx*(X-Xd)'*gradX) is
  % integralof(2*Wx*gradX'*gradX + 2*Wx*(X-Xd)'*diagHessX). 
  dHessXInt=(kron(Wx,ones(1,Nk)).*(gradX.^2))+(kErrX.*diagHessX);
  diagHessErrorX=sum(kdwx.*(dHessXInt(1:(Nw-1),:)+dHessXInt(2:Nw,:)),1);
  if nargout==3
    return
  endif

  % Hessian of the squared-error
  rkdwx=reshape(kron(ones(Nk*Nk,1),dwx),Nw-1,Nk,Nk);
  rkErrX=reshape(kron(ones(Nk*Nk,1),ErrX),Nw,Nk,Nk);
  rkWx=reshape(kron(ones(Nk*Nk,1),Wx),Nw,Nk,Nk);

  rkgradX_r=reshape(transpose(kron(gradX,ones(1,Nk))),Nk,Nk,Nw);
  rkgradX_c=reshape(transpose(kron(gradX,ones(Nk,1))),Nk,Nk,Nw);
  rkgradX_2=rkgradX_r.*rkgradX_c;
  rkgradX_2=permute(rkgradX_2,[3,1,2]);

  hessErrorX=(2*rkErrX.*hessX) + (2*rkWx.*rkgradX_2);
  hessErrorX=sum(rkdwx.*(hessErrorX(1:(Nw-1),:,:)+hessErrorX(2:Nw,:,:)),1)/2;
  hessErrorX=squeeze(hessErrorX);

  hessErrorX(1:NAk,(NAk+1):Nk)=0;
  hessErrorX((NAk+1):Nk,1:NAk)=0;
  
endfunction
