function [Asq,gradAsq,diagHessAsq,hessAsq]=H2Asq(H,dHdx,diagd2Hdx2,d2Hdydx)
% [Asq,gradAsq,diagHessAsq,hessAsq]=H2Asq(H,dHdx,diagd2Hdx2,d2Hdydx)
% A helper function that calculates the squared-magnitude response and
% gradients of a filter with the complex response, H, and gradients, dHdx,
% and diagonal of the Hessian of H, diagd2Hdx2, found by functions like
% schurOneMlattice2H.
% 
% Inputs:
%   H - complex frequency response over angular frequency, w
%   dHdx - gradient of complex frequency response wrt the coefficients, x
%   diagd2Hdx2 - diagonal of the Hessian of H wrt x
%   d2Hdydx - Hessian of H wrt x and y at w
%
% Outputs:
%   Asq - the squared magnitude response at w
%   gradAsq - the gradients of Asq with respect to x
%   diagHessAsq - diagonal of the Hessian of Asq with respect to x
%   hessAsq - Hessian of Asq

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
  if (nargout==0)               || ...
     ((nargout==1)&&(nargin<1)) || ...
     ((nargout==2)&&(nargin<2)) || ...
     ((nargout==3)&&(nargin<3)) || ...
     ((nargout==4)&&(nargin<4)) || ...
     (nargout>4)
    print_usage ...
      ("[Asq,gradAsq,diagHessAsq,hessAsq]=H2Asq(H,dHdx,diagd2Hdx2,d2Hdydx)");
  endif
  Nw=length(H);
  if (nargin >= 1) && (Nw ~= rows(H))
    error("Nw ~= rows(H)");
  endif
  if (nargin >= 2) && (Nw ~= rows(dHdx))
    error("Nw ~= rows(dHdx)");
  endif
  if (nargin >= 3) && (Nw ~= rows(diagd2Hdx2))
    error("Nw ~= rows(diagd2Hdx2)");
  endif
  if (nargin >= 3) && (columns(dHdx) ~= columns(diagd2Hdx2))
    error("columns(dHdx) ~= columns(diagd2Hdx2)");
  endif
  if nargin == 4
    sz_d2Hdydx = size(d2Hdydx);
    if length(sz_d2Hdydx) ~= 3
      error("Expected size(d2Hdydx)==[Nw,Nx,Nx]");
    endif
    if Nw ~= sz_d2Hdydx(1)
      error("Nw ~= sz_d2Hdydx(1)");
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
  
  if Nw == 0
    Asq=[]; gradAsq=[]; diagHessAsq=[]; hessAsq=[];
    return;
  endif

  H=H(:);
  
  % Find Asq
  Asq=H.*conj(H);
  if nargout==1
    return;
  endif

  % Find gradAsq
  Nx=columns(dHdx);
  krH=kron(real(H),ones(1,Nx));
  kiH=kron(imag(H),ones(1,Nx));
  rdHdx=real(dHdx);
  idHdx=imag(dHdx);
  gradAsq=2*((kiH.*idHdx)+(krH.*rdHdx));
  if nargout==2
    return;
  endif

  % Find diagHessAsq
  diagHessAsq=2*((abs(dHdx).^2)+(krH.*real(diagd2Hdx2))+(kiH.*imag(diagd2Hdx2)));
  if nargout==3
    return;
  endif

  % Find hessAsq
  kkiH=reshape(kron(kiH,ones(1,Nx)),sz_d2Hdydx);
  kkrH=reshape(kron(krH,ones(1,Nx)),sz_d2Hdydx);
  kidHdx=reshape(kron(idHdx,ones(1,Nx)),sz_d2Hdydx);
  kidHdx_t=reshape(kron(ones(1,Nx),idHdx),sz_d2Hdydx);
  krdHdx=reshape(kron(rdHdx,ones(1,Nx)),sz_d2Hdydx);
  krdHdx_t=reshape(kron(ones(1,Nx),rdHdx),sz_d2Hdydx);
  hessAsq=2*((kidHdx.*kidHdx_t) + (kkiH.*imag(d2Hdydx)) + ...
             (krdHdx.*krdHdx_t) + (kkrH.*real(d2Hdydx)));
  
  for l=1:Nw,
    if ~issymmetric(squeeze(hessAsq(l,:,:)),10*eps)
      error("hessAsq is not symmetric at l=%d",l);
    endif 
    hessAsq(l,:,:)=(squeeze(hessAsq(l,:,:))+(squeeze(hessAsq(l,:,:)).'))/2;
  endfor

endfunction
