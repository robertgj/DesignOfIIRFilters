function [Esq,gradEsq]=schurOneMAPlattice_frm_halfbandEsq ...
                         (k,epsilon,p,u,v,Mmodel,Dmodel,wa,Asqd,Wa,wt,Td,Wt)
% [Esq,gradEsq,diagHessEsq]=schurOneMAPlattice_frm_halfbandEsq ...
%   (k,epsilon,p,u,v,Mmodel,Dmodel,wa,Asqd,Wa,wt,Td,Wt)
% Calculate the weighted error response and gradients with respect to the
% coefficients of an FRM half-band filter with a model filter implemented
% as an all-pass Schur one-multiplier lattice.
%
% Inputs:
%   k - one-multiplier allpass section denominator multiplier coefficients
%   epsilon - one-multiplier allpass section sign coefficients (+1 or -1)
%   p - internal state scaling factors
%   u,v - unique FIR masking filter coefficients 
%   Mmodel - FRM model filter decimation
%   Dmodel - model filter nominal group delay
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

  if (nargout > 2) || ((nargin != 10) && (nargin != 13))
    print_usage("[Esq,gradEsq] = schurOneMAPlattice_frm_halfbandEsq ...\n\
      (k,epsilon,p,u,v,Mmodel,Dmodel,wa,Asqd,Wa,wt,Td,Wt)");
  endif

  Nk=length(k);
  Nu=length(u);
  Nv=length(v);
  Nkuv=Nk+Nu+Nv;
  if Nu ~= (Nv+1)
    error("Expected length(v)+1==length(u)!");
  endif
  if nargin==10
    wt=[];
  endif
  
  if nargout==1
    if isempty(wa)
      EsqAsq = 0;
    else
      EsqAsq=schurOneMAPlattice_frm_halfbandXError ...
               (@schurOneMAPlattice_frm_halfbandAsq, ...
                k,epsilon,p,u,v,Mmodel,Dmodel,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
    else
      EsqT=schurOneMAPlattice_frm_halfbandXError ...
             (@schurOneMAPlattice_frm_halfbandT, ...
              k,epsilon,p,u,v,Mmodel,Dmodel,wt,Td,Wt);
    endif
    Esq = EsqAsq + EsqT;
  else
    if isempty(wa)
      EsqAsq = 0;
      gradEsqAsq = zeros(1,Nkuv);
    else
      [EsqAsq,gradEsqAsq]=schurOneMAPlattice_frm_halfbandXError ...
                            (@schurOneMAPlattice_frm_halfbandAsq,...
                             k,epsilon,p,u,v,Mmodel,Dmodel,wa,Asqd,Wa);
    endif
    if isempty(wt)
      EsqT = 0;
      gradEsqT = zeros(1,Nkuv);
    else
      [EsqT,gradEsqT]=schurOneMAPlattice_frm_halfbandXError ...
                        (@schurOneMAPlattice_frm_halfbandT,...
                         k,epsilon,p,u,v,Mmodel,Dmodel,wt,Td,Wt);
    endif
    Esq = EsqAsq + EsqT;
    gradEsq = gradEsqAsq + gradEsqT;
  endif
  
endfunction

function [ErrorX,gradErrorX]=schurOneMAPlattice_frm_halfbandXError ...
                               (pfX,k,epsilon,p,u,v,Mmodel,Dmodel,wx,Xd,Wx)

  if nargin~=11 || nargout>2 
    print_usage("[ErrorX,gradErrorX]=schurOneMAPlattice_frm_halfbandXError...\n\
    (pfX,k,epsilon,p,u,v,Mmodel,Dmodel,wx,Xd,Wx)");
  endif

  % Make row vectors with a single column, 
  % since by default, sum() adds over first dimension
  k=k(:);
  epsilon=epsilon(:);
  p=p(:);
  u=u(:);
  v=v(:);
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
  Nu=length(u);
  Nv=length(v);
  Nkuv=Nk+Nu+Nv;
  if Nu ~= Nv+1
    error("Nu ~= Nv+1");
  endif
  
  % X response at wx
  if nargout==1
    X=pfX(wx,k,epsilon,p,u,v,Mmodel,Dmodel);
    gradX=zeros(Nx,Nkuv);
  else
    [X,gradX]=pfX(wx,k,epsilon,p,u,v,Mmodel,Dmodel);
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
  kErrX=kron(ErrX,ones(1,Nkuv));
  kErrXGradX=((kErrX(1:(Nx-1),:).*gradX(1:(Nx-1),:)) + ...
                  (kErrX(2:end,:).*gradX(2:end,:)))/2;
  kdwx=kron(dwx,ones(1,Nkuv));
  kdwxErrXGradX=2*kdwx.*kErrXGradX;
  gradErrorX=sum(kdwxErrXGradX,1);

endfunction
