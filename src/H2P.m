function [P,gradP,diagHessP,hessP]=H2P(H,dHdx,diagd2Hdx2,d2Hdydx)
% [P,gradP,diagHessP,hessP]=H2P(H,dHdx,diagd2Hdx2,d2Hdydx)
% A helper function that calculates the phase response and gradients of
% a filter with the complex response, H, and gradients, dHdw, etc. found by
% functions like schurOneMlattice2H.
% 
% Inputs:
%   H - complex frequency response over angular frequency, w
%   dHdx - gradients of complex frequency response wrt x
%   diagd2Hdx2 - diagonal of the Hessian of H wrt to x
%   d2Hdydx - Hessian of H wrt x and y at w
%
% Outputs:
%   P - the phase response at w
%   gradP - the gradients of P with respect to x
%   diagHessP - diagonal of the Hessian of P with respect to x
%   hessP - Hessian of P

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

  %
  % Sanity checks
  %
  if ((nargout==1)&&(nargin<1)) || ...
     ((nargout==2)&&(nargin<2)) || ...
     ((nargout==3)&&(nargin<3)) || ...
     ((nargout==4)&&(nargin<4)) || ...
     (nargout>4)
    print_usage ...
      ("[P,gradP,diagHessP,hessP]=H2P(H,dHdx,diagd2Hdx2,d2Hdydx)");
  endif
  if (nargin>=1) && (length(H) == 0)
    P=[]; gradP=[]; diagHessP=[]; hessP=[];
    return;
  endif
  if (nargin == 2) && (length(H) ~= rows(dHdx))
    error("length(H) ~= rows(dHdx)");
  endif
  if (nargin == 3) && (length(H) ~= rows(diagd2Hdx2))
    error("length(H) ~= rows(diagd2Hdx2)");
  endif
  if (nargin == 3) && (columns(dHdx) ~= columns(diagd2Hdx2))
    error("columns(dHdx) ~= columns(diagd2Hdx2)");
  endif
  if nargin == 4
    sz_d2Hdydx = size(d2Hdydx);
    if length(sz_d2Hdydx) ~= 3
      error("Expected size(d2Hdydx)==[Nw,Nx,Nx]");
    endif
    if length(H) ~= sz_d2Hdydx(1)
      error("length(H) ~= sz_d2Hdydx(1)");
    endif
    if rows(dHdx) ~= sz_d2Hdydx(1)
      error("rows(dHdx) ~= sz_d2Hdydx(1)");
    endif
    if columns(dHdx) ~= sz_d2Hdydx(2)
      error("columns(dHdx) ~= sz_d2Hdydx(2)");
    endif
    if sz_d2Hdydx(2) ~= sz_d2Hdydx(3)
      error("sz_d2Hdydx(2) ~= sz_d2Hdydx(3)");
    endif
  endif

  % Find P
  H=H(:);
  rH=real(H);
  iH=imag(H);
  P=unwrap(atan2(iH,rH));
  if nargout==1
    return;
  endif

  % Find gradP
  Nx=columns(dHdx);
  Asq=H.*conj(H);
  kAsq=kron(Asq,ones(1,Nx));
  krH=kron(rH,ones(1,Nx));
  kiH=kron(iH,ones(1,Nx));
  rdHdx=real(dHdx);
  idHdx=imag(dHdx);
  gradP=((krH.*idHdx)-(kiH.*rdHdx))./kAsq;
  if nargout==2
    return;
  endif

  % Find diagHessP
  gradAsq=2*((kiH.*idHdx)+(krH.*rdHdx));
  rd2Hdx2=real(diagd2Hdx2);
  id2Hdx2=imag(diagd2Hdx2);
  diagHessP=(((krH.*id2Hdx2)-(kiH.*rd2Hdx2))-(gradAsq.*gradP))./kAsq;
  if nargout==3
    return;
  endif
  
  % Find hessP
  kkAsq=reshape(kron(kAsq,ones(1,Nx)),sz_d2Hdydx);
  kgradAsq_t=reshape(kron(ones(1,Nx),gradAsq),sz_d2Hdydx);
  kgradP=reshape(kron(gradP,ones(1,Nx)),sz_d2Hdydx);
  kkiH=reshape(kron(kiH,ones(1,Nx)),sz_d2Hdydx);
  kkrH=reshape(kron(krH,ones(1,Nx)),sz_d2Hdydx);
  kidHdx=reshape(kron(idHdx,ones(1,Nx)),sz_d2Hdydx);
  kidHdx_t=reshape(kron(ones(1,Nx),idHdx),sz_d2Hdydx);
  krdHdx=reshape(kron(rdHdx,ones(1,Nx)),sz_d2Hdydx);
  krdHdx_t=reshape(kron(ones(1,Nx),rdHdx),sz_d2Hdydx);
  hessP=((krdHdx_t.*kidHdx) - (kidHdx_t.*krdHdx) + ...
         (kkrH.*imag(d2Hdydx)) - (kkiH.*real(d2Hdydx)) - ...
         (kgradAsq_t.*kgradP))./kkAsq;

endfunction
