function [T,gradT,diagHessT,hessT]= ...
  H2T(H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx,d3Hdwdydx)
% [T,gradT,diagHessT,hessT]= ...
%  H2T(H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx,d3Hdwdydx)
% A helper function that calculates the group delay response and
% gradients of a filter with the complex response, H, and gradients, dHdw,
% etc. found by functions like schurOneMlattice2H.
% 
% Inputs:
%   H - complex frequency response over angular frequency, w
%   dHdw - gradient of the complex frequency response wrt w
%   dHdx - gradients of complex frequency response wrt x
%   d2Hdwdx - gradients of dHdw wrt to x
%   diagd2Hdx2 - diagonal of the Hessian of H wrt to x
%   diagd3Hdwdx2 - diagonal of the gradient of the Hessian of H wrt to w
%   d2Hdydx - Hessian of H wrt to x and y
%   d3Hdwdydx - gradient of the Hessian of H wrt to w
%
% Outputs:
%   T - the group delay response at w
%   gradT - the gradients of T with respect to x
%   diagHessT - diagonal of the Hessian of T with respect to x
%   hessT - Hessian of T with respect to x and y

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

  %
  % Sanity checks
  %
  if (nargout==0)                 || ...
     ((nargout==1) && (nargin<2)) || ...
     ((nargout==2) && (nargin<4)) || ...
     ((nargout==3) && (nargin<6)) || ...
     ((nargout==4) && (nargin<8)) || ...
     (nargout>4)
    print_usage("[T,gradT,diagHessT,hessT]= ...\n\
      H2T(H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx,d3Hdwdydx)");
  endif
  Nw=length(H);
  if (nargin >= 1) && (Nw ~= rows(H))
    error("Nw ~= length(H)");
  endif
  if (nargin >= 2) && (Nw ~= rows(dHdw))
    error("Nw ~= length(dHdw)");
  endif
  if (nargin >= 3) && (Nw ~= rows(dHdx))
    error("Nw ~= rows(dHdx)");
  endif
  if (nargin >= 4) && (Nw ~= rows(d2Hdwdx))
    error("Nw ~= rows(d2Hdwdx)");
  endif
  if (nargin >= 5) && (Nw ~= rows(diagd2Hdx2))
    error("Nw ~= rows(diagd2Hdx2)");
  endif
  if (nargin >= 6) && (Nw ~= rows(diagd3Hdwdx2))
    error("Nw ~= rows(diagd3Hdwdx2)");
  endif
  if (nargin >= 4) && (columns(dHdx) ~= columns(d2Hdwdx))
    error("columns(dHdx) ~= columns(d2Hdwdx)");
  endif
  if (nargin >= 5) && (columns(dHdx) ~= columns(diagd2Hdx2))
    error("columns(dHdx) ~= columns(diagd2Hdx2)");
  endif
  if (nargin >= 6) && (columns(dHdx) ~= columns(diagd3Hdwdx2))
    error("columns(dHdx) ~= columns(diagd3Hdwdx2)");
  endif
  if nargin >= 7
    sz_d2Hdydx=size(d2Hdydx);
    if Nw ~= sz_d2Hdydx(1)
      error("Nw ~= sz_d2Hdydx(1)");
    endif
    if columns(dHdx) ~= sz_d2Hdydx(2)
      error("columns(dHdx) ~= sz_d2Hdydx(2)");
    endif
    if columns(dHdx) ~= sz_d2Hdydx(3)
      error("columns(dHdx) ~= sz_d2Hdydx(3)");
    endif
  endif
  if nargin >= 8
    sz_d3Hdwdydx=size(d3Hdwdydx);
    if Nw ~= sz_d3Hdwdydx(1)
      error("Nw ~= sz_d3Hdwdydx(1)");
    endif
    if columns(dHdx) ~= sz_d3Hdwdydx(2)
      error("columns(dHdx) ~= sz_d3Hdwdydx(2)");
    endif
    if columns(dHdx) ~= sz_d3Hdwdydx(3)
      error("columns(dHdx) ~= sz_d3Hdwdydx(3)");
    endif
  endif

  if Nw == 0
    T=[]; gradT=[]; diagHessT=[]; hessT=[];
    return;
  endif

  % Find T
  Asq=H.*conj(H);
  rH=real(H);
  iH=imag(H);
  rdHdw=real(dHdw);
  idHdw=imag(dHdw);
  
  T=-((rH.*idHdw)-(iH.*rdHdw))./Asq;

  if nargout==1
    return;
  endif

  % Find gradT
  Nx=columns(dHdx);
  rdHdx=real(dHdx);
  idHdx=imag(dHdx);
  kAsq=kron(Asq,ones(1,Nx));
  krH=kron(rH,ones(1,Nx));
  kiH=kron(iH,ones(1,Nx));
  kT=kron(T,ones(1,Nx));
  krdHdw=kron(rdHdw,ones(1,Nx));
  kidHdw=kron(idHdw,ones(1,Nx));
  rd2Hdwdx=real(d2Hdwdx);
  id2Hdwdx=imag(d2Hdwdx);
  
  gradT=-((rdHdx.*kidHdw)+(krH.*id2Hdwdx)-(idHdx.*krdHdw)-(kiH.*rd2Hdwdx));
  gradT=gradT-(2*kT.*((krH.*rdHdx)+(kiH.*idHdx)));
  gradT=gradT./kAsq;

  if nargout==2
    return;
  endif

  % Find diagHessT
  gradAsq=2*((kiH.*idHdx)+(krH.*rdHdx));
  rd2Hdx2=real(diagd2Hdx2);
  id2Hdx2=imag(diagd2Hdx2);
  rd3Hdwdx2=real(diagd3Hdwdx2);
  id3Hdwdx2=imag(diagd3Hdwdx2);
  diagHessAsq=2*((abs(dHdx).^2)+(krH.*rd2Hdx2)+(kiH.*id2Hdx2));
  
  diagHessT=(-(diagHessAsq.*kT)-(2*gradAsq.*gradT) ...
             -(rd2Hdx2.*kidHdw)-(rdHdx.*id2Hdwdx) ...
             -(rdHdx.*id2Hdwdx)-(krH.*id3Hdwdx2) ...
             +(id2Hdx2.*krdHdw)+(idHdx.*rd2Hdwdx) ...
             +(idHdx.*rd2Hdwdx)+(kiH.*rd3Hdwdx2))./kAsq;
 
  if nargout==3
    return;
  endif

  % Find hessT
  kkAsq=reshape(kron(kAsq,ones(1,Nx)),sz_d2Hdydx);
  
  gradAsq=2*((kiH.*idHdx)+(krH.*rdHdx));
  kgradAsq=reshape(kron(gradAsq,ones(1,Nx)),sz_d2Hdydx);
  kgradAsq_t=reshape(kron(ones(1,Nx),gradAsq),sz_d2Hdydx);
  
  kkiH=reshape(kron(kiH,ones(1,Nx)),sz_d2Hdydx);
  kkrH=reshape(kron(krH,ones(1,Nx)),sz_d2Hdydx);
  kidHdx=reshape(kron(idHdx,ones(1,Nx)),sz_d2Hdydx);
  kidHdx_t=reshape(kron(ones(1,Nx),idHdx),sz_d2Hdydx);
  krdHdx=reshape(kron(rdHdx,ones(1,Nx)),sz_d2Hdydx);
  krdHdx_t=reshape(kron(ones(1,Nx),rdHdx),sz_d2Hdydx);
  hessAsq=2*((kidHdx.*kidHdx_t) + (kkiH.*imag(d2Hdydx)) + ...
             (krdHdx.*krdHdx_t) + (kkrH.*real(d2Hdydx)));

  kkT=reshape(kron(kT,ones(1,Nx)),sz_d2Hdydx);
  kgradT=reshape(kron(gradT,ones(1,Nx)),sz_d2Hdydx);
  kgradT_t=reshape(kron(ones(1,Nx),gradT),sz_d2Hdydx);
  
  kkrdHdw=reshape(kron(krdHdw,ones(1,Nx)),sz_d2Hdydx);
  kkidHdw=reshape(kron(kidHdw,ones(1,Nx)),sz_d2Hdydx);
  krd2Hdwdx=reshape(kron(rd2Hdwdx,ones(1,Nx)),sz_d2Hdydx);
  krd2Hdwdx_t=reshape(kron(ones(1,Nx),rd2Hdwdx),sz_d2Hdydx);
  kid2Hdwdx=reshape(kron(id2Hdwdx,ones(1,Nx)),sz_d2Hdydx);
  kid2Hdwdx_t=reshape(kron(ones(1,Nx),id2Hdwdx),sz_d2Hdydx);
  rd2Hdydx=real(d2Hdydx);
  id2Hdydx=imag(d2Hdydx);
  rd3Hdwdydx=real(d3Hdwdydx);
  id3Hdwdydx=imag(d3Hdwdydx);
  
  hessT=(-(hessAsq.*kkT)-(kgradAsq.*kgradT_t)-(kgradAsq_t.*kgradT) ...
         -(rd2Hdydx.*kkidHdw)-(krdHdx.*kid2Hdwdx_t) ...
         -(krdHdx_t.*kid2Hdwdx)-(kkrH.*id3Hdwdydx) ...
         +(id2Hdydx.*kkrdHdw)+(kidHdx.*krd2Hdwdx_t) ...
         +(kidHdx_t.*krd2Hdwdx)+(kkiH.*rd3Hdwdydx))./kkAsq;
  
  for l=1:Nw,
    if ~issymmetric(squeeze(hessT(l,:,:)),1e-10)
      error("hessT is not symmetric(%g) at l=%d",
            max(max(abs(squeeze(hessT(l,:,:))-squeeze(hessT(l,:,:))')/2)),l);
    endif 
    hessT(l,:,:)=(squeeze(hessT(l,:,:))+(squeeze(hessT(l,:,:)).'))/2;
  endfor
  
endfunction
