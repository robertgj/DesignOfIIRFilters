function [T,gradT,diagHessT]=H2T(H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2)
% [T,gradT,diagHessT]=H2T(H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2)
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
%
% Outputs:
%   T - the group delay response at w
%   gradT - the gradients of T with respect to x
%   diagHessT - diagonal of the Hessian of T with respect to x

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

  %
  % Sanity checks
  %
  if (nargout>3) || ((nargout==1) && (nargin<2)) || ...
     ((nargout==2) && (nargin<4)) || ((nargout==3) && (nargin<6))
    print_usage...
      ("[T,gradT,diagHessT]=H2T(H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2)");
  endif
  if (nargin == 2) && (length(H) ~= rows(dHdw))
    error("length(H) ~= length(dHdw)");
  endif
  if (nargin == 3) && (length(H) ~= rows(dHdx))
    error("length(H) ~= rows(dHdx)");
  endif
  if (nargin == 4) && (length(H) ~= rows(d2Hdwdx))
    error("length(H) ~= rows(d2Hdwdx)");
  endif
  if (nargin == 5) && (length(H) ~= rows(diagd2Hdx2))
    error("length(H) ~= rows(diagd2Hdx2)");
  endif
  if (nargin == 6) && (length(H) ~= rows(diagd3Hdwdx2))
    error("length(H) ~= rows(diagd3Hdwdx2)");
  endif
  if (nargin == 4) && (columns(dHdx) ~= columns(d2Hdwdx))
    error("columns(dHdx) ~= columns(d2Hdwdx)");
  endif
  if (nargin == 5) && (columns(dHdx) ~= columns(diagd2Hdx2))
    error("columns(dHdx) ~= columns(diagd2Hdx2)");
  endif
  if (nargin == 6) && (columns(dHdx) ~= columns(diagd3Hdwdx2))
    error("columns(dHdx) ~= columns(diagd3Hdwdx2)");
  endif
  if length(H) == 0
    T=[]; gradT=[]; diagHessT=[];
    return;
  endif

  % Find T
  Hsq=H.*conj(H);
  rH=real(H);
  iH=imag(H);
  rdHdw=real(dHdw);
  idHdw=imag(dHdw);
  T=-((rH.*idHdw)-(iH.*rdHdw))./Hsq;
  if nargout==1
    return;
  endif

  % Find gradT
  Nx=columns(dHdx);
  rdHdx=real(dHdx);
  idHdx=imag(dHdx);
  kHsq=kron(Hsq,ones(1,Nx));
  krH=kron(rH,ones(1,Nx));
  kiH=kron(iH,ones(1,Nx));
  kT=kron(T,ones(1,Nx));
  krdHdw=kron(rdHdw,ones(1,Nx));
  kidHdw=kron(idHdw,ones(1,Nx));
  rd2Hdwdx=real(d2Hdwdx);
  id2Hdwdx=imag(d2Hdwdx);
  gradT=-((rdHdx.*kidHdw)+(krH.*id2Hdwdx)-(idHdx.*krdHdw)-(kiH.*rd2Hdwdx));
  gradT=gradT-(2*kT.*((krH.*rdHdx)+(kiH.*idHdx)));
  gradT=gradT./kHsq;
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
             +(idHdx.*rd2Hdwdx)+(kiH.*rd3Hdwdx2))./kron(Hsq,ones(1,Nx));
 
endfunction
