function [Esq,gradEsq,diagHessEsq]=...
         schurNSlatticeEsq(s10,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt)
% [Esq,gradEsq,diagHessEsq]=...
%   schurNSlatticeEsq(s10,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt)
% Inputs:
%   s10,s11,s20,s00,s02,s22 - Schur normalised-scaled lattice coefficients
%   wa - angular frequencies of desired pass-band amplitude response in [0,pi]
%   Asqd - desired pass-band magnitude-squared response
%   Wa - pass-band amplitude weight vector
%   wt - angular frequencies of the desired group delay response
%   Td - desired group delay response 
%   Wt - group delay weight vector
%   
% Outputs:
%   Esq - the squared error value at x
%   gradEsq - gradient of the squared error value at x
%   diagHessEsq - diagonal of the Hessian of the squared error value at x.

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

  if nargout>3 || nargin~=12
    print_usage("[Esq,gradEsq,diagHessEsq] = ...\n\
      schurNSlatticeEsq(s10,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt)");
  endif
  if length(s10) ~= length(s11)
    error("length(s10) ~= length(s11)");
  endif
  if length(s10) ~= length(s20)
    error("length(s10) ~= length(s20)");
  endif
  if length(s10) ~= length(s00)
    error("length(s10) ~= length(s00)");
  endif
  if length(s10) ~= length(s02)
    error("length(s10) ~= length(s02)");
  endif
  if length(s10) ~= length(s22)
    error("length(s10) ~= length(s22)");
  endif

  Ns=length(s00);
  
  if nargout==1
    if (isempty(wa))
      EsqAsq = 0;
    else
      EsqAsq=schurNSlatticeErrorAsq(s10,s11,s20,s00,s02,s22,wa,Asqd,Wa);
    endif
    if (isempty(wt))
      EsqT=0;
    else
      EsqT=schurNSlatticeErrorT(s10,s11,s20,s00,s02,s22,wt,Td,Wt);
    endif
    Esq=EsqAsq + EsqT;
  elseif nargout==2
    if (isempty(wa))
      EsqAsq=0;
      gradEsqAsq=zeros(1,6*Ns);
    else
      [EsqAsq,gradEsqAsq]=...
        schurNSlatticeErrorAsq(s10,s11,s20,s00,s02,s22,wa,Asqd,Wa);
    endif
    if (isempty(wt))
      EsqT=0;
      gradEsqT=zeros(1,6*Ns);
    else
      [EsqT,gradEsqT]=schurNSlatticeErrorT(s10,s11,s20,s00,s02,s22,wt,Td,Wt);
    endif
    Esq=EsqAsq + EsqT;
    gradEsq=gradEsqAsq + gradEsqT;
  elseif nargout==3
    if isempty(wa)
      EsqAsq=0;
      gradEsqAsq=zeros(1,6*Ns);
      diagHessEsqAsq=zeros(1,6*Ns);
    else
      [EsqAsq,gradEsqAsq,diagHessEsqAsq]=...
        schurNSlatticeErrorAsq(s10,s11,s20,s00,s02,s22,wa,Asqd,Wa);
    endif
    if (isempty(wt))
      EsqT=0;
      gradEsqT=zeros(1,6*Ns);
      diagHessEsqT=zeros(1,6*Ns);
    else
      [EsqT,gradEsqT,diagHessEsqT]=...
        schurNSlatticeErrorT(s10,s11,s20,s00,s02,s22,wt,Td,Wt);
    endif
    Esq=EsqAsq + EsqT;
    gradEsq=gradEsqAsq + gradEsqT;
    diagHessEsq=diagHessEsqAsq + diagHessEsqT;
  endif

endfunction

function [ErrorAsq,gradErrorAsq,diagHessErrorAsq]=...
           schurNSlatticeErrorAsq(s10,s11,s20,s00,s02,s22,wa,Asqd,Wa)

  if nargin~=9 || nargout>3 
    print_usage("[ErrorAsq,gradErrorAsq,diagHessErrorAsq]=...\n\
      schurNSlatticeErrorAsq(s10,s11,s20,s00,s02,s22,wa,Asqd,Wa)");
  endif

  % Make row vectors with a single column, 
  % since by default, sum() adds over first dimension
  s10=s10(:);s11=s11(:);s20=s20(:);s00=s00(:);s02=s02(:);s22=s22(:);
  wa=wa(:);Asqd=Asqd(:);Wa=Wa(:);

  % Sanity checks
  Ns=length(s10);
  Na=length(wa);
  if length(Asqd) ~= Na
    error("length(wa)~=length(Asqd)");
  endif
  if length(Wa) ~= Na
    error("length(wa)~=length(Wa)");
  endif
  
  % Squared amplitude response at wa
  if nargout==1
    Asq=schurNSlatticeAsq(wa,s10,s11,s20,s00,s02,s22);
    gradAsq=zeros(Na,6*Ns);
    diagHessAsq=zeros(Na,6*Ns);
  elseif nargout==2
    [Asq,gradAsq]=schurNSlatticeAsq(wa,s10,s11,s20,s00,s02,s22);
    diagHessAsq=zeros(Na,6*Ns);
  elseif nargout==3
    [Asq,gradAsq,diagHessAsq]=schurNSlatticeAsq(wa,s10,s11,s20,s00,s02,s22);
  endif

  % Sanity check
  Asqnf=find(any(~isfinite(Asq)));
  Asq(Asqnf)=Asqd(Asqnf);
  gradAsq(Asqnf,:)=0;

  % Amplitude response error with trapezoidal integration.
  dwa=diff(wa);
  ErrAsq=Wa.*(Asq-Asqd);
  sqErrAsq=ErrAsq.*(Asq-Asqd);
  ErrorAsq=sum(dwa.*(sqErrAsq(1:(Na-1))+sqErrAsq(2:Na)))/2;
  if nargout==1
    return;
  endif

  % Gradient of response error  
  kErrAsq=kron(ErrAsq,ones(1,6*Ns));
  kErrAsqGradAsq=((kErrAsq(1:(Na-1),:).*gradAsq(1:(Na-1),:)) + ...
                     (kErrAsq(2:end,:).*gradAsq(2:end,:)))/2;
  kdwa=kron(dwa,ones(1,6*Ns));
  kdwaErrAsqGradAsq=2*kdwa.*kErrAsqGradAsq;
  gradErrorAsq=sum(kdwaErrAsqGradAsq,1);
  if nargout==2
    return
  endif

  % We only want the diagonal of the Hessian of the error.
  % Recall that the derivative of integralof(2*Wa*(Asq-Asqd)'*gradAsq) is
  % integralof(2*Wa*gradAsq'*gradAsq + 2*Wa*(Asq-Asqd)'*diagHessAsq). 
  dHessAsqInt=(kron(Wa,ones(1,6*Ns)).*(gradAsq.^2))+(kErrAsq.*diagHessAsq);
  diagHessErrorAsq=sum(kdwa.*(dHessAsqInt(1:(Na-1),:)+dHessAsqInt(2:Na,:)),1);

endfunction

function [ErrorT,gradErrorT,diagHessErrorT]=...
           schurNSlatticeErrorT(s10,s11,s20,s00,s02,s22,wt,Td,Wt)

  if nargin~=9 || nargout>3 
    print_usage("[ErrorT,gradErrorT,diagHessErrorT]=...\n\
      schurNSlatticeErrorT(s10,s11,s20,s00,s02,s22,wt,Td,Wt)");
  endif

  % Make row vectors with a single column, 
  % since by default, sum() adds over first dimension
  s10=s10(:);s11=s11(:);s20=s20(:);s00=s00(:);s02=s02(:);s22=s22(:);
  wt=wt(:);Td=Td(:);Wt=Wt(:);

  % Sanity checks
  Ns=length(s10);
  Nt=length(wt);
  if length(Td) ~= Nt
    error("length(wt)~=length(Td)");
  endif
  if length(Wt) ~= Nt
    error("length(wt)~=length(Wt)");
  endif
  
  % Delay response at wt
  if nargout==1
    T=schurNSlatticeT(wt,s10,s11,s20,s00,s02,s22);
    gradT=zeros(Nt,6*Ns);
    diagHessT=zeros(Nt,6*Ns);
  elseif nargout==2
    [T,gradT]=schurNSlatticeT(wt,s10,s11,s20,s00,s02,s22);
    diagHessT=zeros(Nt,6*Ns);
  elseif nargout==3
    [T,gradT,diagHessT]=schurNSlatticeT(wt,s10,s11,s20,s00,s02,s22);
  endif

  % Sanity check
  Tnf=find(any(~isfinite(T)));
  T(Tnf)=Td(Tnf);
  gradT(Tnf,:)=0;

  % Delay reponse error with trapezoidal integration.
  dwt=diff(wt);
  ErrT=Wt.*(T-Td);
  sqErrT=ErrT.*(T-Td);
  ErrorT=sum(dwt.*(sqErrT(1:(Nt-1))+sqErrT(2:Nt)))/2;
  if nargout==1
    return;
  endif

  % Gradient of response error  
  kErrT=kron(ErrT,ones(1,6*Ns));
  kErrTGradT=((kErrT(1:(Nt-1),:).*gradT(1:(Nt-1),:)) + ...
                 (kErrT(2:end,:).*gradT(2:end,:)))/2;
  kdwt=kron(dwt,ones(1,6*Ns));
  kdwtErrTGradT=2*kdwt.*kErrTGradT;
  gradErrorT=sum(kdwtErrTGradT,1);
  if nargout==2
    return
  endif

  % We only want the diagonal of the Hessian of the error.
  % Recall that the derivative of integralof(2*Wt*(T-Td)'*gradT) is
  % integralof(2*Wt*gradT'*gradT + 2*Wt*(T-Td)'*diagHessT). 
  dHessTInt=(kron(Wt,ones(1,6*Ns)).*(gradT.^2))+(kErrT.*diagHessT);
  diagHessErrorT=sum(kdwt.*(dHessTInt(1:(Nt-1),:)+dHessTInt(2:Nt,:)),1);

endfunction
